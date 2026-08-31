;;;; src/docs.lisp

(defpackage :bknr.tag/docs
  (:use :cl)
  (:export #:generate))

(in-package :bknr.tag/docs)

(40ants-doc:defsection @bknr.tag-manual (:title "bknr.tag")
  "Many-to-many labeling for bknr.datastore persistent objects,
backed by a string-safe hash-list-index for O(1) tagged-with
lookups. No domain assumptions about what a tag means."
  (bknr.tag:taggable class)
  (bknr.tag:object-tags generic-function)
  (bknr.tag:add-tag function)
  (bknr.tag:remove-tag function)
  (bknr.tag:tagged-with function))

(defun generate (&optional (stream *standard-output*) (format :markdown))
  "Renders @BKNR.TAG-MANUAL to STREAM in FORMAT (:markdown or :html)."
  (write-string (40ants-doc-full/builder:render-to-string @bknr.tag-manual :format format) stream))
