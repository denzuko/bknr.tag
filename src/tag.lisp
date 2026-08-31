;;;; src/tag.lisp
;;;;
;;;; Many-to-many labeling over bknr.datastore persistent objects.
;;;; TAGGABLE is a mixin, not a wrapper: it adds a TAGS slot and
;;;; nothing else, so any persistent class can gain tags by
;;;; inheriting from it alongside whatever else it already is. A
;;;; tag is a plain string; what a tag means is entirely the
;;;; caller's business.

(defpackage :bknr.tag
  (:use :cl)
  (:export
   #:taggable
   #:object-tags
   #:add-tag
   #:remove-tag
   #:tagged-with))

(in-package :bknr.tag)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass string-hash-list-index (bknr.indices:hash-list-index) ()
    (:documentation "BKNR.INDICES:HASH-LIST-INDEX defaults to an EQL
hash-table test, which only matches identical string objects, not
equal string content. Confirmed by the same bug already found and
fixed in bknr.hashkv's own indices (denzuko/bknr.hashkv#1): a tag
string deserialized fresh after a restart is never EQL to the tag
string that indexed it originally, even with identical characters.
BKNR.INDICES ships STRING-UNIQUE-INDEX for exactly this problem on
UNIQUE-INDEX, but nothing equivalent for HASH-LIST-INDEX, so this
class exists to close that gap the same way, using EQUAL instead."))

  (defmethod initialize-instance :after ((index string-hash-list-index) &key (test #'equal))
    ;; BKNR.INDICES::SLOT-INDEX-HASH-TABLE is the real accessor
    ;; (confirmed against source: STRING-UNIQUE-INDEX itself sets the
    ;; slot directly via WITH-SLOTS rather than a public accessor,
    ;; because none is exported for this).
    (setf (bknr.indices::slot-index-hash-table index) (make-hash-table :test test))))

(bknr.datastore:defpersistent-class taggable ()
  ((tags :initarg :tags :accessor object-tags :initform nil
         :index-type string-hash-list-index
         :index-reader tagged-with))
  (:documentation "Mixin adding tags to a persistent class. TAGS
holds a plain list of strings. Setting it through the ordinary
accessor, at any point after creation, correctly reconciles
TAGGED-WITH: BKNR.INDICES:HASH-LIST-INDEX's generated slot-writer
removes stale bucket entries and adds new ones on every SETF, on the
initial unbound-to-bound transition and on every change after it."))

(defun add-tag (object tag)
  "Tags OBJECT with TAG. Adding a tag OBJECT already has is a no-op:
TAGS never holds a duplicate."
  (bknr.datastore:with-transaction ()
    (pushnew tag (object-tags object) :test #'string=)))

(defun remove-tag (object tag)
  "Removes TAG from OBJECT, if present. Returns T if a tag was
removed, NIL if OBJECT did not have that tag to begin with."
  (if (member tag (object-tags object) :test #'string=)
      (progn
        (bknr.datastore:with-transaction ()
          (setf (object-tags object) (remove tag (object-tags object) :test #'string=)))
        t)
      nil))
