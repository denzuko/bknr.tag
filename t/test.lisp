;;;; t/test.lisp

(defpackage :bknr.tag/tests
  (:use :cl :fiveam)
  (:export #:run-tests))

(in-package :bknr.tag/tests)

(def-suite bknr.tag-suite :description "bknr.tag labeling tests")
(in-suite bknr.tag-suite)

(defvar *test-directory* #P"/tmp/bknr.tag-test-store/")

(defun fresh-store ()
  "Deletes and reopens a scratch datastore, so each test starts isolated."
  (when (and (boundp 'bknr.datastore:*store*) bknr.datastore:*store*)
    (bknr.datastore:close-store))
  (when (probe-file *test-directory*)
    (uiop:delete-directory-tree *test-directory* :validate t))
  (make-instance 'bknr.datastore:mp-store
                  :directory *test-directory*
                  :subsystems (list (make-instance 'bknr.datastore:store-object-subsystem))))

(test add-tag-makes-object-findable
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (is (member a (bknr.tag:tagged-with "urgent"))))
  (bknr.datastore:close-store))

(test object-can-carry-more-than-one-tag
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (bknr.tag:add-tag a "billing")
    (is (member a (bknr.tag:tagged-with "urgent")))
    (is (member a (bknr.tag:tagged-with "billing"))))
  (bknr.datastore:close-store))

(test two-objects-can-share-a-tag
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable)))
        (b (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (bknr.tag:add-tag b "urgent")
    (let ((found (bknr.tag:tagged-with "urgent")))
      (is (member a found))
      (is (member b found))))
  (bknr.datastore:close-store))

(test tagged-with-returns-exactly-the-tagged-objects
  ;; The test above only checks A and B are present; this checks
  ;; TAGGED-WITH returns exactly {A, B}, no unexpected extra member,
  ;; regardless of hash-list-index's own iteration order.
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable)))
        (b (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (bknr.tag:add-tag b "urgent")
    (fiveam-matchers:assert-that
     (bknr.tag:tagged-with "urgent")
     (fiveam-matchers:contains-in-any-order
      (fiveam-matchers:equal-to a) (fiveam-matchers:equal-to b))))
  (bknr.datastore:close-store))

(test remove-tag-stops-object-being-found
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (bknr.tag:remove-tag a "urgent")
    (is (not (member a (bknr.tag:tagged-with "urgent")))))
  (bknr.datastore:close-store))

(test remove-tag-on-a-tag-never-added-returns-nil
  ;; REMOVE-TAG's own IF had never had its ELSE branch exercised
  ;; (removing a tag the object never had), even though the
  ;; docstring documents this exact return value.
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (is (eq nil (bknr.tag:remove-tag a "never-added"))))
  (bknr.datastore:close-store))

(test removing-one-tag-leaves-others-intact
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (bknr.tag:add-tag a "billing")
    (bknr.tag:remove-tag a "urgent")
    (is (not (member a (bknr.tag:tagged-with "urgent"))))
    (is (member a (bknr.tag:tagged-with "billing"))))
  (bknr.datastore:close-store))

(test adding-the-same-tag-twice-does-not-duplicate
  (fresh-store)
  (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
    (bknr.tag:add-tag a "urgent")
    (bknr.tag:add-tag a "urgent")
    (is (= 1 (length (bknr.tag:object-tags a)))))
  (bknr.datastore:close-store))

(test tags-survive-a-store-restart
  (fresh-store)
  (let (a-id)
    (let ((a (bknr.datastore:with-transaction () (make-instance 'bknr.tag:taggable))))
      (bknr.tag:add-tag a "urgent")
      (setf a-id (bknr.datastore:store-object-id a)))
    (bknr.datastore:close-store)
    (make-instance 'bknr.datastore:mp-store
                    :directory *test-directory*
                    :subsystems (list (make-instance 'bknr.datastore:store-object-subsystem)))
    (let ((a (bknr.datastore:store-object-with-id a-id)))
      (is (member a (bknr.tag:tagged-with "urgent")))))
  (bknr.datastore:close-store))

(defun run-tests ()
  "Runs the bknr.tag test suite and returns T if every test passed."
  (fiveam:run! 'bknr.tag-suite))
