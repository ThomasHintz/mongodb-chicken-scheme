(use test)
(load "mongo-client.scm")

(define (contains-oid json-result)
  (if (alist-ref 'oids json-result) #t #f))

(define test-resource "test")

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
 (test #t (contains-oid (mdb-insert test-resource '((name . "stuff"))))))

(test-group
 "remove"
 (mdb-connect server: "http://localhost:27017")
 (database "testdatabase")
 (mdb-insert test-resource '((eat . "good")))
 (test '((ok . 1)) (mdb-remove test-resource '())))

(test-group
 "find/query"
 (mdb-connect server: "http://localhost:27017")
 (database "testdatabase")

 (test-group
  "find empty"
  (mdb-remove test-resource '())
  (let ((res (mdb-find test-resource)))
    (test 1 (alist-ref 'ok res))
    (test '#() (alist-ref 'results res))))

 (test-group
  "find one"
  (mdb-remove test-resource '())
  (mdb-insert test-resource '((name . "joe")))
  (let* ((res (mdb-find test-resource))
         (items (alist-ref 'results res)))
    (test 1 (alist-ref 'ok res))
    (test 1 (vector-length items))
    (test "joe" (alist-ref 'name (vector-ref items 0)))))

 (test-group
  "find by criteria"
  (mdb-remove test-resource '())
  (let ((oid (cdadar (mdb-insert test-resource '((name . "joe"))))))
    (mdb-insert test-resource '((name . "abel")))
    (let* ((res (mdb-find test-resource criteria: '((name . "joe"))))
           (items (alist-ref 'results res)))
      (test 1 (alist-ref 'ok res))
      (test 1 (vector-length items))
      (test oid (alist-ref 'oid (vector-ref items 0)))))))


(test-end "all")
