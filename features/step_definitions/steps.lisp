(defpackage :bknr.tag/bdd
  (:use :cl :sunny-side)
  (:export #:run-bdd))

(in-package :bknr.tag/bdd)

(defvar *objects* (make-hash-table :test 'equal)
  "Maps a scenario-local name (a string like \"a\") to the persistent
TAGGABLE object created for it, reset each scenario by the
Background step.")

(Given! "^a fresh bknr\\.tag store$" ()
  (when (and (boundp 'bknr.datastore:*store*) bknr.datastore:*store*)
    (bknr.datastore:close-store))
  (clrhash *objects*)
  (let ((dir (merge-pathnames
              (format nil "bknr.tag-bdd-~(~36R~)-~(~36R~)/"
                      (get-universal-time) (random most-positive-fixnum))
              #P"/tmp/")))
    (make-instance 'bknr.datastore:mp-store
                    :directory dir
                    :subsystems (list (make-instance 'bknr.datastore:store-object-subsystem)))))

(When! "^I create an object called \"([^\"]*)\"$" (name)
  (setf (gethash name *objects*)
        (bknr.datastore:with-transaction ()
          (make-instance 'bknr.tag:taggable))))

(When! "^I tag \"([^\"]*)\" with \"([^\"]*)\"$" (name tag)
  (bknr.tag:add-tag (gethash name *objects*) tag))

(When! "^I untag \"([^\"]*)\" with \"([^\"]*)\"$" (name tag)
  (bknr.tag:remove-tag (gethash name *objects*) tag))

(Then! "^\"([^\"]*)\" should be findable by tag \"([^\"]*)\"$" (name tag)
  (fiveam:is (member (gethash name *objects*) (bknr.tag:tagged-with tag))))

(Then! "^\"([^\"]*)\" should not be findable by tag \"([^\"]*)\"$" (name tag)
  (fiveam:is (not (member (gethash name *objects*) (bknr.tag:tagged-with tag)))))

(Then! "^the objects tagged \"([^\"]*)\" should be \"([^\"]*)\" and \"([^\"]*)\"$" (tag name-a name-b)
  (let ((found (bknr.tag:tagged-with tag)))
    (fiveam:is (member (gethash name-a *objects*) found))
    (fiveam:is (member (gethash name-b *objects*) found))))

(Then! "^\"([^\"]*)\" should have exactly (\\d+) tag$" (name count)
  (fiveam:is (= (parse-integer count) (length (bknr.tag:object-tags (gethash name *objects*))))))

(define-feature-tests
    #.(asdf:system-relative-pathname :bknr.tag "features/bknr.tag.feature")
  :suite bknr.tag-gherkin-suite)

(defun run-bdd ()
  "Runs every Scenario in bknr.tag.feature as a FiveAM test and
returns T if every scenario passed."
  (fiveam:run! 'bknr.tag-gherkin-suite))
