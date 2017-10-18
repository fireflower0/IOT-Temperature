;; Load CFFI, Clack, cl-markup
(ql:quickload :cffi)
(ql:quickload :clack)
(ql:quickload :clack-app-route)
(ql:quickload :cl-markup)

;; Declare as a package
(defpackage cl-iot
  (:use :common-lisp
        :cffi
        :clack
        :clack.request
        :clack.app.route
        :cl-markup))
