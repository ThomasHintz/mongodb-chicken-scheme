(use test)
(load "mongo-client.scm")

(define (contains-oid json-result)
  (if (alist-ref 'oids json-result) #t #f))

(test-begin "all")

(test-group
 "connect"
 (test '((ok . 1) (server . "http://localhost:27017") (name . "default"))
       (mdb-connect server: "http://localhost:27017")))

(test-group
 "hello"
 (test '((ok . 1) (msg . "Uh, we had a slight weapons malfunction, but uh... everything's perfectly all right now. We're fine. We're all fine here now, thank you. How are you?"))
       (mdb-hello)))

(test-group
 "insert"
 (mdb-connect server: "http://localhost:27017")
 (database "testdatabase")
 (test #t (contains-oid (mdb-insert "test" '((name . "stuff"))))))

(test-end "all")
