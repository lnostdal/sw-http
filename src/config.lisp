;;;; http://nostdal.org/ ;;;;

(in-package #:sw-http)


(pushnew :sw-http *features*) ;; Tell the world we exist.


(define-constant +inline-functions-p+ nil)


(define-symbol-macro optimizations
    ;;'(optimize (speed 3) (space 0) (safety 0) (debug 0) (compilation-speed 0)))
    '(optimize (speed 0) (space 0) (safety 3) (debug 3) (compilation-speed 0)))


(define-constant +request-buffer-size+ 4096
  :documentation "
Size of chunks read in at a time.")

(define-constant +request-headers-max-size+ 81900) ;; Whot..same size as Apache's default (I think).
(define-constant +request-body-max-size+ 81900
  :documentation "
Maximum 'Content-Length' and/or buffer size for message-body part of a HTTP
request.")

(define-constant +response-buffer-size+ 4096)