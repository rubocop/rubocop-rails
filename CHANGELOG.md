# Change log

## master (unreleased)

### Bug fixes

* [#104](https://github.com/rubocop-hq/rubocop-rails/issues/104): Exclude Rails-independent `bin/bundle` by default. ([@koic][])

## 2.3.0 (2019-08-13)

### New features

* [#78](https://github.com/rubocop-hq/rubocop-rails/issues/78): Add new `Rails/EnumHash` cop. ([@fedeagripa][], [@brunvez][], [@santib][])

### Bug fixes

* [#53](https://github.com/rubocop-hq/rubocop-rails/issues/53): Fix a false positive for `Rails/SaveBang` when implicitly return using finder method and creation method connected by `||`. ([@koic][])
* [#97](https://github.com/rubocop-hq/rubocop-rails/pull/97): Fix two false negatives for `Rails/EnumUniqueness`. 1. When `enum` name is not a literal. 2. When `enum` has multiple definitions. ([@santib][])

### Changes

* [#98](https://github.com/rubocop-hq/rubocop-rails/pull/98): Mark `Rails/ActiveRecordAliases` as `SafeAutoCorrect` false and disable autocorrect by default. ([@prathamesh-sonpatki][])
* [#101](https://github.com/rubocop-hq/rubocop-rails/pull/101): Mark `Rails/SaveBang` as `SafeAutoCorrect` false and disable autocorrect by default. ([@prathamesh-sonpatki][])
* [#102](https://github.com/rubocop-hq/rubocop-rails/pull/102): Include `create_or_find_by` in `Rails/SaveBang` cop. ([@MaximeLaurenty][])

## 2.2.1 (2019-07-13)

### Bug fixes

* [#86](https://github.com/rubocop-hq/rubocop-rails/issues/86): Fix an incorrect auto-correct for `Rails/TimeZone` when using `Time.new`. ([@koic][])

## 2.2.0 (2019-07-07)

### Bug fixes

* [#67](https://github.com/rubocop-hq/rubocop-rails/issues/67): Fix an incorrect auto-correct for `Rails/TimeZone` when using `DateTime`. ([@koic][])

## 2.1.0 (2019-06-26)

### Bug fixes

* [#43](https://github.com/rubocop-hq/rubocop-rails/issues/43): Remove `change_column_null` method from `BulkChangeTable` cop offenses. ([@anthony-robin][])
* [#79](https://github.com/rubocop-hq/rubocop-rails/issues/79): Fix `RuboCop::Cop::Rails not defined (NameError)`. ([@rmm5t][])

### Changes

* [#74](https://github.com/rubocop-hq/rubocop-rails/pull/74): Drop Rails 3 support. ([@koic][])

## 2.0.1 (2019-06-08)

### Changes

* [#68](https://github.com/rubocop-hq/rubocop-rails/pull/68): Relax rack dependency for Rails 4. ([@buehmann][])

## 2.0.0 (2019-05-22)

### New features

* Extract Rails cops from rubocop-hq/rubocop repository. ([@koic][])
* [#19](https://github.com/rubocop-hq/rubocop-rails/issues/19): Add new `Rails/HelperInstanceVariable` cop. ([@andyw8][])

[@koic]: https://github.com/koic
[@andyw8]: https://github.com/andyw8
[@buehmann]: https://github.com/buehmann
[@anthony-robin]: https://github.com/anthony-robin
[@rmm5t]: https://github.com/rmm5t
[@fedeagripa]: https://github.com/fedeagripa
[@brunvez]: https://github.com/brunvez
[@santib]: https://github.com/santib
[@prathamesh-sonpatki]: https://github.com/prathamesh-sonpatki
[@MaximeLaurenty]: https://github.com/MaximeLaurenty
