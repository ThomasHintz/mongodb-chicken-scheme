(use test)
(load "mongo-client.scm")

(test-begin "all")

(test-group
 "->json-string"
 (test "{\"a\":\"b\"}" (->json-string '((a . "b"))))
 (test "{\"a\":{\"b\":\"c\"}}" (->json-string '((a . ((b . "c"))))))
 (test "{\"a\":[\"b\",\"c\"]}" (->json-string '((a . #("b" "c"))))))

(test-group
 "connect"
 (test '#(("ok" . 1) ("server" . "http://localhost:27017") ("name" . "default"))
       (connect server: "http://localhost:27017")))

;; (test-group
;;  "insert"
;;  (connect server: "http://localhost:27017")
;;  (database "testdatabase")
;;  (test '#(("oids" . #(("$oid" . "50bf4e8e4c860b61384fa132"))))
;;        (insert "test" '#((name . "stuff")))))

(test-end "all")
