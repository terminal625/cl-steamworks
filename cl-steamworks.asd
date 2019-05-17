#|
 This file is a part of cl-steamworks
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem cl-steamworks
  :version "1.0.0"
  :license "Artistic"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "A wrapper for the Valve SteamWorks API."
  :homepage "https://github.com/Shinmera/cl-steamworks"
  :serial T
  :components ((:file "package")
               (:file "c-support")
               (:file "toolkit")
               (:file "c-object")
               (:file "callback")
               (:file "steamworks")
               (:file "interface")
               (:file "steamclient")
               (:file "steamutils")
               (:file "steamuser")
               (:file "steamfriends")
               (:file "steamapps")
               (:file "steamworkshop")
               (:file "steamcontroller")
               (:file "steamgameserver")
               (:file "steamhtmlsurface")
               (:file "steamhttp")
               (:file "steaminventory")
               (:file "steammatchmaking")
               (:file "steammusic")
               (:file "documentation"))
  :depends-on (:documentation-utils
               :alexandria
               :trivial-features
               :trivial-garbage
               :babel
               :cffi
               (:feature :sbcl (:require :sb-posix))))
