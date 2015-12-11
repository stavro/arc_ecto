# Changelog

## v0.3.0
* (Dependency Update) Require v0.2.0 of arc.

## v0.2.0

* (Behavior Change) `arc_ecto` will now apply all `%Ecto.Changeset{}` changes within `cast_attachments` to the root model prior to passing the model to `arc` as a scope.

## v0.1.2

* (Bugfix) Support the `:empty` value for given params

## v0.1.1

* Relax `ecto` dependency to `>= 0.10.0` to support Ecto v1.0.0
