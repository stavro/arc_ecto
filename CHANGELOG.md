# Changelog

## v0.4.0
* (Enhancement) Upgrade to Ecto 2.0rc-3

Upgrade instructions from 0.3.x to 0.4.x:

1. ArcEcto follows Ecto in the renaming of `Model` to `Schema`.  In your definitions, wherever you had `use Arc.Ecto.Model`, replace with `use Arc.Ecto.Schema`
2. ArcEcto follows Ecto in the usage of a singular `params` hash to `cast_attachments` rather than a set of `optional` and `required` params.  ArcEcto encourages the usage of a `cast_attachments` call followed by a `validate_required`.


## v0.3.2
* (Bugfix) Relax Arc dependency to ~> 0.2 to support 0.3.0

## v0.3.1
* (Bugfix) Allow params objects with atom keys.

## v0.3.0
* (Dependency Update) Require v0.2.0 of arc.

## v0.2.0

* (Behavior Change) `arc_ecto` will now apply all `%Ecto.Changeset{}` changes within `cast_attachments` to the root model prior to passing the model to `arc` as a scope.

## v0.1.2

* (Bugfix) Support the `:empty` value for given params

## v0.1.1

* Relax `ecto` dependency to `>= 0.10.0` to support Ecto v1.0.0
