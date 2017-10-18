;; Load packages
(load "packages.lisp" :external-format :utf-8)

(in-package :cl-iot)

;; Load wrapper API
(load "libwiringPi.lisp" :external-format :utf-8)

;; I2C device address (0x48)
(defconstant +i2c-addr+ #X48)

;; i2c initial setting
(defparameter *fd* (wiringPiI2CSetup +i2c-addr+))

;; Set to register "0x03" to acquire temperature as 16-bit data
(wiringPiI2CWriteReg8 *fd* #X03 #X80)

(defun byte-swap (num-value)
  (let (str-value temp-msb temp-lsb)
    ;; Convert numeric value to character string
    (setq str-value (write-to-string num-value :base 16))
    ;; Get upper two digits (MSB)
    (setq temp-msb (subseq str-value 0 2))
    ;; Get the lower 2 digits (LSB)
    (setq temp-lsb (subseq str-value 2))
    ;; Swap to join
    (setq str-value (concatenate 'string temp-lsb temp-msb))
    ;; Convert string to numeric value
    (parse-integer str-value :radix 16)))

(defun get-temperature ()
  (* (byte-swap (wiringPiI2CReadReg16 *fd* #X00)) 0.0078))

;; Create Web page
(defun web-page ()
  (list
   (markup
    (html
     (:head
      (:meta :content "text/html" :charset "UTF-8")
      (:title "Web Application with Common Lisp and RaspberryPi"))
     (:body
      (:p "Temperature") (:br)
      (:form :method "post" :action "/post" :target "iframe"
             (:input :type "submit" :name "temperature" :value "Update"))
      (:iframe :name "iframe"))))))

;; Create index
(defun index (env)
  (declare (ignore env))
  `(200
    (:content-type "text/html")
    ,(web-page)))

;; POST process
(defun post (env)
  (declare (ignore env))
  `(200
    (:content-type "text/plain")
    ,(list
      (format nil "Temperature : ~a" (get-temperature)))))

;; Web Application Function
(defroutes app (env)
  (GET "/" #'index)                ; Call "function index" when GET is called "/"
  (POST "/post" #'post))               ; Call "function post" when POST is called "/"

;; Main function
(defun main ()
  ;; Clack UP
  (clackup #'app :port 5000 :debug t))

;; Execution
(main)
