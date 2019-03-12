#|
 This file is a part of cl-steamworks
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.fraf.steamworks)

(defvar *steamworks* NIL)
(defvar *default-interfaces*
  '(steamclient steamutils steamuser steamfriends))

(defun steamworks (&optional container)
  (if container
      (%steamworks container)
      (or *steamworks*
          (error "FIXME: steamworks is not initialised."))))

(defun most-recent-interface-version (interface)
  (let ((name (format NIL "~a~a" (remove #\- (string interface)) '#:-interface-version)))
    (symbol-value (or (find-symbol name '#:org.shirakumo.fraf.steamworks.cffi)
                      (error "FIXME: No such interface ~s" interface)))))

(defclass steamworks ()
  ((interfaces :initform (make-hash-table :test 'eq) :reader interfaces)
   (user :initform NIL :reader user)
   (pipe :initform NIL :reader pipe)))

(defmethod initialize-instance :before ((steamworks steamworks) &key app-id)
  (when *steamworks*
    (cerror "Replace the previous steamworks instance."
            "FIXME: Steamworks is already initialized."))
  (when app-id
    (setup-app-id app-id)))

(defmethod initialize-instance :after ((steamworks steamworks) &key (interfaces *default-interfaces*))
  (tg:finalize steamworks (free-handle-function steamworks NIL))
  (when (= 0 (pipe steamworks))
    (error "FIXME: could not retrieve valid steam pipe."))
  (create-interfaces steamworks interfaces)
  (setf *steamworks* steamworks))

(defmethod free ((steamworks steamworks))
  (funcall (free-handle-function steamworks NIL)))

(defmethod create-interfaces ((steamworks steamworks) interfaces)
  (flet ((maybe-create (interface)
           (destructuring-bind (interface &optional (version T)) (enlist interface)
             (unless (interface interface steamworks)
               (when (eql T version)
                 (setf version (most-recent-interface-version interface)))
               (setf (gethash interface (interfaces steamworks))
                     (make-instance interface :version version :steamworks steamworks))))))
    (maybe-create 'steamclient)
    (mapc #'maybe-create interfaces)
    (list-interfaces steamworks)))

(defmethod interface ((name symbol) (steamworks steamworks))
  (gethash name (interfaces steamworks)))

(defmethod interface (name (steamworks (eql T)))
  (interface name (steamworks)))

(defmethod list-interfaces ((steamworks steamworks))
  (alexandria:hash-table-values (interfaces steamworks)))

(defclass steamworks-client (steamworks)
  ())

(defmethod initialize-instance ((steamworks steamworks-client) &key app-id)
  (call-next-method)
  (unless (steam::init)
    (restart-case
        (error "FIXME: Failed to call INIT. Is Steam running and the app-id ready?")
      (restart (&optional (app-id app-id) (exit-code 2))
        :report "Restart the application through Steam."
        (when (steam::restart-app-if-necessary app-id)
          (quit exit-code)))))
  (setf (slot-value steamworks 'user) (steam::get-hsteam-user))
  (setf (slot-value steamworks 'pipe) (steam::get-hsteam-pipe)))

(defmethod free-handle-function ((steamworks steamworks-client) handle)
  (lambda ()
    (setf (slot-value steamworks 'user) NIL)
    (setf (slot-value steamworks 'pipe) NIL)
    (steam::shutdown)
    (setf *steamworks* NIL)))

(defmethod run-callbacks ((steamworks steamworks-client))
  (steam::run-callbacks))

(defclass steamworks-server (steamworks)
  ((ip-address :initarg :ip-address :reader ip-address)
   (port :initarg :port :reader port)
   (game-port :initarg :game-port :reader game-port)
   (query-port :initarg :query-port :reader query-port)
   (server-mode :initarg :server-mode :reader server-mode)
   (version-string :initarg :version-string :reader version-string)))

(defmethod initialize-instance ((steamworks steamworks-server) &key ip-address port game-port query-port server-mode version-string)
  (call-next-method)
  (unless (steam::game-server-init ip-address port game-port query-port server-mode version-string)
    (error "FIXME: failed to init game server."))
  (setf (slot-value steamworks 'user) (steam::game-server-get-hsteam-user))
  (setf (slot-value steamworks 'pipe) (steam::game-server-get-hsteam-pipe)))

(defmethod free-handle-function ((steamworks steamworks-server) handle)
  (let ((interfaces (interfaces steamworks)))
    (lambda ()
      (setf (slot-value steamworks 'user) NIL)
      (setf (slot-value steamworks 'pipe) NIL)
      (steam::game-server-shutdown)
      (setf *steamworks* NIL))))

(defmethod run-callbacks ((steamworks steamworks-server))
  (steam::game-server-run-callbacks))