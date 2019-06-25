# Change log

## master (unreleased)

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
