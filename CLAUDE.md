# CLAUDE.md

Hand-authored. No `dps-meta` generation attempted for this repo yet.

## Project Identity

| Field        | Value |
|--------------|-------|
| Application  | bknr.tag |
| Description  | CLOS mixin adding many-to-many labeling, backed by a string-safe hash-list-index, to any bknr.datastore persistent class |
| Type         | Common Lisp library |
| Version      | 1.0.0 |
| Branch       | develop |
| Licence      | BSD-3-Clause |
| Organisation | denzuko |

## Standards Stack

- BSD-3-Clause license
- git-flow branching, `develop` as the integration branch
- Semver: MAJOR = public API/interface break only; MINOR = new non-breaking capability; PATCH = everything else
- 40ants-doc for documentation (`bknr.tag/docs`)
- BDD-first: `features/bknr.tag.feature` written, and its step
  definitions confirmed failing against no source at all, before
  `src/tag.lisp` existed

## BDD Workflow

`features/bknr.tag.feature` plus `features/step_definitions/steps.lisp`
(system `bknr.tag/bdd`) covers every scenario: tagging, multiple tags
per object, shared tags across objects, untagging, and duplicate-tag
suppression. `t/test.lisp` (system `bknr.tag/tests`) covers the same
ground directly against the Lisp API, plus a restart-survival check.
Run `./tests.ros` directly; no `qlot` is needed for it, since
`bknr.tag` itself depends only on `bknr.datastore` and
`bknr.indices`, ordinary Quicklisp packages. `bknr.tag/bdd` is
different: it depends on `sunny-side`, not yet published to
Quicklisp, so `qlfile` resolves it as a git source and `./bdd.ros`
must run through `qlot exec`.

## Subcommands

None. This is a library with no `.ros` entry point beyond the test
and docs runners.

## Do Not

- Do not use plain `bknr.indices:hash-list-index` for a string-keyed
  slot. Its hash-table defaults to an `EQL` test, which silently
  breaks lookups for any key deserialized fresh after a restart; use
  `bknr.tag::string-hash-list-index` instead, or the same pattern
  applied elsewhere. This is the same class of bug tracked as
  `denzuko/bknr.hashkv#1`.
- Do not bake in a meaning for what a tag represents anywhere in
  `src/tag.lisp`. A tag is a plain string on purpose, so this stays
  usable across domains that have nothing else in common; see
  README's "Why its own repository" section.
- Do not assume `bknr.tag` is part of the upstream bknr project. It
  extends `bknr.datastore` from a separate repo; see README for the
  naming rationale.
