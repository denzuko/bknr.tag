# bknr.tag

bknr.tag is a CLOS mixin that adds many-to-many labeling to any
`bknr.datastore` persistent class, backed by a hash-list index for
O(1) lookups of every object carrying a given tag, for the cost of
adding it to a superclass list.

## Naming

This library extends `bknr.datastore` rather than belonging to the
bknr project itself. `bknr.indices`, `bknr.impex`, and
`bknr.datastore` are sibling systems shipped from the bknr project's
own repository, under a single upstream authority; `bknr.tag` does
not join them. It exists separately, as `denzuko/bknr.tag`, an
independently published project.

## Why its own repository

Labeling comes up in projects that have nothing else in common: a
web crawler tagging pages by topic, home automation tagging devices
by room, a container orchestrator tagging services by environment,
none of it decided here: a tag is a plain string, and what it means
is entirely the caller's business, the same reasoning `bknr.dag`
applies to what counts as a dependency being satisfied.

## String keys and the EQL default

`bknr.indices:hash-list-index`, the index type this library uses for
`tagged-with`, defaults to an `EQL` hash-table test. `EQL` on strings
only matches identical objects, not equal content, so a tag string
deserialized fresh after a restart is never `EQL` to the tag string
that indexed it originally, even with identical characters. This is
the exact bug already found and fixed in `bknr.hashkv`'s own indices
([denzuko/bknr.hashkv#1](https://github.com/denzuko/bknr.hashkv/issues/1)).
`bknr.indices` ships `string-unique-index` for this problem on
`unique-index`, but nothing equivalent for `hash-list-index`, so
`bknr.tag` defines its own `string-hash-list-index` closing the same
gap with `EQUAL`. A tag added, the store closed
and reopened, and `tagged-with` still finding the object correctly
is one of the tests in `t/test.lisp`.

## Usage

```lisp
(bknr.datastore:defpersistent-class my-thing (bknr.tag:taggable)
  ((...)))

(let ((a (make-instance 'my-thing)))
  (bknr.tag:add-tag a "urgent")
  (bknr.tag:add-tag a "billing")
  (bknr.tag:tagged-with "urgent"))    ;=> (a)
```

Adding a tag an object already has is a no-op, not a duplicate:

```lisp
(bknr.tag:add-tag a "urgent")
(bknr.tag:add-tag a "urgent")
(length (bknr.tag:object-tags a))     ;=> 1
```

Removing one tag leaves the rest of an object's tags intact:

```lisp
(bknr.tag:remove-tag a "urgent")
(bknr.tag:tagged-with "urgent")       ;=> nil
(bknr.tag:tagged-with "billing")      ;=> (a)
```

## Depending on bknr.tag from your own project

`bknr.tag` is not yet published to Quicklisp or Ultralisp, so add it
to your own project's `qlfile` as a git source. `bknr.tag` depends
only on `bknr.datastore` and `bknr.indices`, ordinary published
Quicklisp packages, so this one line is the only entry needed:

```
git bknr.tag https://github.com/denzuko/bknr.tag.git :branch develop
```

```sh
qlot install
ros -e '(ql:quickload :bknr.tag)'
```

## Documentation

```sh
./docs.ros
```

This renders `@BKNR.TAG-MANUAL`, defined in `src/docs.lisp`, through
`40ants-doc`. The keyword arguments `40ants-doc:document` accepts
have changed across that library's history, so confirming the
current signature locally before wiring this into a CI pipeline is
worth doing first.

## Testing

```sh
./tests.ros              # unit: bknr.tag/tests, exercises ADD-TAG,
                          # REMOVE-TAG, TAGGED-WITH, and tags
                          # surviving a store restart. Only depends
                          # on bknr.datastore and bknr.indices, so no
                          # qlot setup is needed.
```

```sh
qlot install               # bknr.tag/bdd depends on sunny-side, not
qlot exec ./bdd.ros         # yet published to Quicklisp; qlfile
                            # resolves it as a git source. The same
                            # scenarios as the unit suite, expressed
                            # as Gherkin.
```

Both suites run against scratch datastores under `/tmp/`, deleted and
recreated before each test.

## Consumers

No consumers yet in this repository's own history. Real, stated
intended consumers across other projects: a web crawler tagging pages
by topic, a home-automation system tagging devices by room, and a
container orchestrator tagging services by environment.

## License

BSD 3-Clause. See `LICENSE`.
