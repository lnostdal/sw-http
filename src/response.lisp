;;;; http://nostdal.org/ ;;;;

(in-package #:sw-http)


(defstruct (response (:conc-name :rs-) (:copier nil))
  (chunks (mk-queue) :type queue)
  (chunk-buffer-pos 0 :type fixnum))


(defun mk-response-status-code (status-code)
  (declare #.optimizations
           (fixnum status-code))
  (case status-code
    (200 #.(sb-ext:string-to-octets (catstr "HTTP/1.1 200 OK" +crlf+)))
    (404 #.(sb-ext:string-to-octets (catstr "HTTP/1.1 404 Not Found" +crlf+)))))
(export 'mk-response-status-code)


(defun mk-response-header-field (header-field)
  (declare #.optimizations
           (string header-field))
  (sb-ext:string-to-octets (format nil "~A~A" header-field +crlf+)
                           :external-format :ascii))
(export 'mk-response-header-field)


(defun mk-response-message-body (message-body)
  (declare #.optimizations
           (string message-body))
  (sb-ext:string-to-octets (format nil "Content-Length: ~D~A~A~A"
                                   (length message-body)
                                   +crlf+
                                   +crlf+
                                   message-body)
                           :external-format :utf-8))
(export 'mk-response-message-body)


(maybe-inline response-handle)
(defun response-handle (connection)
  "..or \"handle the response\".
Returns NIL if there is more to send."
  (declare (connection connection)
           #.optimizations)
  (let* ((response (cn-response connection))
         (chunks (rs-chunks response))
         (socket (cn-socket connection)))
    (loop-until-eagain
       (loop :for chunk = (queue-peek chunks)
          :while chunk
          :do (when (zerop (- (the fixnum (length chunk))
                              (the fixnum (incf (rs-chunk-buffer-pos response)
                                                (the fixnum (send-to socket chunk
                                                                     :start (rs-chunk-buffer-pos response)))))))
                (setf (rs-chunk-buffer-pos response) 0)
                (queue-pop chunks))
          :finally (return-from response-handle t)))))
