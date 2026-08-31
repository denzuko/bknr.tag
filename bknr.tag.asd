(asdf:defsystem "bknr.tag"
  :description "Many-to-many labeling for bknr.datastore persistent objects, backed by a string-safe hash-list-index for O(1) tagged-with lookups, with no domain assumptions about what a tag means."
  :license "BSD-3-Clause"
  :depends-on ("bknr.datastore" "bknr.indices")
  :pathname "src/"
  :components ((:file "tag")))

(asdf:defsystem "bknr.tag/docs"
  :description "40ants-doc manual definition for bknr.tag."
  :license "BSD-3-Clause"
  :depends-on ("bknr.tag" "40ants-doc" "40ants-doc-full")
  :pathname "src/"
  :components ((:file "docs")))

(asdf:defsystem "bknr.tag/tests"
  :description "FiveAM test suite for bknr.tag."
  :license "BSD-3-Clause"
  :depends-on ("bknr.tag" "fiveam" "uiop")
  :pathname "t/"
  :components ((:file "test")))

(asdf:defsystem "bknr.tag/bdd"
  :description "Gherkin/BDD suite for bknr.tag, via sunny-side, exercising the Given/When/Then scenarios in features/bknr.tag.feature."
  :license "BSD-3-Clause"
  :depends-on ("bknr.tag" "sunny-side" "fiveam")
  :pathname "features/"
  :components ((:module "step_definitions"
                :components ((:file "steps")))))
