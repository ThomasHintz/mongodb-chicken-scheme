(import chicken scheme)
(use http-client medea intarweb uri-common)

;;;;;;;;;;;;;;;; utilities ;;;;;;;;;;;;;;;;;;;;
(define (->json-string json-struct)
  (with-output-to-string (lambda () (write-json json-struct))))

;;;;;;;;;;;;;;; parameters ;;;;;;;;;;;;;;;;;;;;
(define endpoint (make-parameter "http://localhost:27080"))
(define database (make-parameter #f))
(define connection-name (make-parameter #f))
(define safe (make-parameter #f))

;;;;;;;;;;;;;;;;;; api ;;;;;;;;;;;;;;;;;;;;;;;
(define (mongo-req #!key (connection-name (connection-name))
                   (endpoint (endpoint)) parameters path (method 'GET)
                   (action ""))
  (with-input-from-request
   (make-request method: method
                 uri: (uri-reference
                       (string-append endpoint "/"
                                      (if (database) (string-append (database) "/") "")
                                      (if path (string-append path "/") "")
                                      action)))
   (if parameters
       (append (if connection-name `((name . ,connection-name)) '())
               (if (safe) '((safe . 1)) '())
               parameters)
       #f)
   read-json))
(mongo-req action: "_hello")
(define (connect #!key server connection-name)
  (parameterize
   ((database #f))
   (mongo-req path: #f connection-name: connection-name
              method: 'POST action: "_connect"
              parameters: (if server `((server . ,server)) '((nothing . nothing))))))

(define-syntax with-database
  (syntax-rules ()
    ((_ the-database body ...)
     (parameterize ((database the-database)) body ...))))

(define (insert resource document)
  (mongo-req
   path: resource action: "_insert" method: 'POST
   parameters:
   `((docs . ,(->json-string document)))))

(define (update resource document criteria)
  (mongo-req
   path: resource action: "_update" method: 'POST
   parameters:
   `((newobj . ,(->json-string document)) (criteria . ,(->json-string criteria)))))

(define (remove resource criteria)
  (mongo-req
   path: resource action: "_remove" method: 'POST
   parameters:
   `((criteria . ,(->json-string criteria)))))

(define (mongo-find resource #!key criteria fields sort skip limit explain batch-size)
  (mongo-req
   action: (string-append "_find?criteria="
                          (uri-encode-string (->json-string criteria)))
   method: 'GET path: resource))

(define (mongo-cmd resource cmd)
  (mongo-req
   path: resource method: 'POST action: "_cmd"
   parameters: `((cmd . ,(->json-string cmd)))))

;;; for testing
;(database "clienttest")
;(connect server: "http://localhost:27017")
;(insert "test" '#((name . "stuff")))
;(ensure-index "test" '#((name . 1)))
