# Change log

## master (unreleased)

### New features

* [#52](https://github.com/rubocop-hq/rubocop-rails/issues/52): Add new `Rails/AfterCommitOverride` cop. ([@fatkodima][])
* [#274](https://github.com/rubocop-hq/rubocop-rails/pull/274): Add new `Rails/WhereNot` cop. ([@fatkodima][])

### Bug fixes

* [#315](https://github.com/rubocop-hq/rubocop-rails/pull/315): Allow to use frozen scope for `Rails/UniqueValidationWithoutIndex`. ([@krim][])
* [#313](https://github.com/rubocop-hq/rubocop-rails/pull/313): Fix `Rails/ActiveRecordCallbacksOrder` to preserve the original callback execution order. ([@eugeneius][])

### Changes

* [#312](https://github.com/rubocop-hq/rubocop-rails/pull/312): Mark `Rails/MailerName` as unsafe for auto-correct. ([@eugeneius][])

## 2.7.1 (2020-07-26)

### Bug fixes

* [#297](https://github.com/rubocop-hq/rubocop-rails/pull/297): Handle an upstream Ruby issue where the DidYouMean module is not available, which would break the `Rails/UnknownEnv` cop. ([@taylorthurlow][])
* [#300](https://github.com/rubocop-hq/rubocop-rails/issues/300): Fix `Rails/RenderInline` error on variable key in render options. ([@tejasbubane][])
* [#305](https://github.com/rubocop-hq/rubocop-rails/issues/305): Fix crash in `Rails/MatchRoute` cop when `via` option is a variable. ([@tejasbubane][])

### Changes

* [#301](https://github.com/rubocop-hq/rubocop-rails/issues/301): Set disalbed by default for `Rails/PluckId`. ([@koic][])

## 2.7.0 (2020-07-21)

### New features

* [#283](https://github.com/rubocop-hq/rubocop-rails/pull/283): Add new `Rails/FindById` cop. ([@fatkodima][])
* [#285](https://github.com/rubocop-hq/rubocop-rails/pull/285): Add new `Rails/ActiveRecordCallbacksOrder` cop. ([@fatkodima][])
* [#276](https://github.com/rubocop-hq/rubocop-rails/pull/276): Add new `Rails/RenderPlainText` cop. ([@fatkodima][])
* [#76](https://github.com/rubocop-hq/rubocop-rails/issues/76): Add new `Rails/DefaultScope` cop. ([@fatkodima][])
* [#275](https://github.com/rubocop-hq/rubocop-rails/pull/275): Add new `Rails/MatchRoute` cop. ([@fatkodima][])
* [#286](https://github.com/rubocop-hq/rubocop-rails/pull/286): Add new `Rails/WhereExists` cop. ([@fatkodima][])
* [#271](https://github.com/rubocop-hq/rubocop-rails/pull/271): Add new `Rails/RenderInline` cop. ([@fatkodima][])
* [#281](https://github.com/rubocop-hq/rubocop-rails/pull/281): Add new `Rails/MailerName` cop. ([@fatkodima][])
* [#280](https://github.com/rubocop-hq/rubocop-rails/pull/280): Add new `Rails/ShortI18n` cop. ([@fatkodima][])
* [#282](https://github.com/rubocop-hq/rubocop-rails/pull/282): Add new `Rails/Inquiry` cop. ([@fatkodima][])
* [#246](https://github.com/rubocop-hq/rubocop-rails/issues/246): Add new `Rails/PluckInWhere` cop. ([@fatkodima][])
* [#17](https://github.com/rubocop-hq/rubocop-rails/issues/17): Add new `Rails/NegateInclude` cop. ([@fatkodima][])
* [#278](https://github.com/rubocop-hq/rubocop-rails/pull/278): Add new `Rails/Pluck` cop. ([@eugeneius][])
* [#272](https://github.com/rubocop-hq/rubocop-rails/pull/272): Add new `Rails/PluckId` cop. ([@fatkodima][])

### Bug fixes

* [#261](https://github.com/rubocop-hq/rubocop-rails/issues/261): Fix auto correction for `Rails/ContentTag` when `content_tag` is called with options hash and block. ([@fatkodima][])

### Changes

* [#263](https://github.com/rubocop-hq/rubocop-rails/pull/263): Change terminology to `ForbiddenMethods` and `AllowedMethods`. ([@jcoyne][])
* [#289](https://github.com/rubocop-hq/rubocop-rails/pull/289): Update `Rails/SkipsModelValidations` to register an offense for `insert_all`, `touch_all`, `upsert_all`, etc. ([@eugeneius][])
* [#293](https://github.com/rubocop-hq/rubocop-rails/pull/293): Require RuboCop 0.87 or higher. ([@koic][])

## 2.6.0 (2020-06-08)

### New features

* [#51](https://github.com/rubocop-hq/rubocop-rails/issues/51): Add allowed receiver class names option for `Rails/DynamicFindBy`. ([@tejasbubane][])
* [#211](https://github.com/rubocop-hq/rubocop-rails/issues/211): Add autocorrect to `Rails/RakeEnvironment` cop. ([@tejasbubane][])
* [#242](https://github.com/rubocop-hq/rubocop-rails/pull/242): Add `Rails/ContentTag` cop. ([@tabuchi0919][])
* [#249](https://github.com/rubocop-hq/rubocop-rails/pull/249): Add new `Rails/Pick` cop. ([@eugeneius][])
* [#257](https://github.com/rubocop-hq/rubocop-rails/pull/257): Add new `Rails/RedundantForeignKey` cop. ([@eugeneius][])

### Bug fixes

* [#12](https://github.com/rubocop-hq/rubocop-rails/issues/12): Fix a false positive for `Rails/SkipsModelValidations` when passing a boolean literal to `touch`. ([@eugeneius][])
* [#238](https://github.com/rubocop-hq/rubocop-rails/issues/238): Fix auto correction for `Rails/IndexBy` when the `.to_h` invocation is separated in multiple lines. ([@diogoosorio][])
* [#248](https://github.com/rubocop-hq/rubocop-rails/pull/248): Fix a false positive for `Rails/SaveBang` when `update` is called on `ENV`. ([@eugeneius][])
* [#251](https://github.com/rubocop-hq/rubocop-rails/pull/251): Fix a false positive for `Rails/FilePath` when the result of `Rails.root.join` is interpolated at the end of a string. ([@eugeneius][])
* [#91](https://github.com/rubocop-hq/rubocop-rails/issues/91): Fix `Rails/UniqBeforePluck` to not recommend using `uniq` in `ActiveRecord::Relation`s anymore since it was deprecated in Rails 5.0. ([@santib][], [@ghiculescu][])

### Changes

* [#233](https://github.com/rubocop-hq/rubocop-rails/pull/233): **(BREAKING)** Drop support for Ruby 2.3. ([@koic][])
* [#236](https://github.com/rubocop-hq/rubocop-rails/pull/236): **(BREAKING)** Drop support for Rails 4.1 or lower. ([@koic][])
* [#210](https://github.com/rubocop-hq/rubocop-rails/issues/210): Accept `redirecto_to(...) and return` and similar cases. ([@koic][])
* [#258](https://github.com/rubocop-hq/rubocop-rails/pull/258): Drop support for RuboCop 0.81 or lower. ([@koic][])

## 2.5.2 (2020-04-09)

### Bug fixes

* [#227](https://github.com/rubocop-hq/rubocop-rails/issues/227): Make `Rails/UniqueValidationWithoutIndex` aware of updating db/schema.rb. ([@koic][])

## 2.5.1 (2020-04-02)

### Bug fixes

* [#213](https://github.com/rubocop-hq/rubocop-rails/pull/213): Fix a false positive for `Rails/UniqueValidationWithoutIndex` when using conditions. ([@sunny][])
* [#215](https://github.com/rubocop-hq/rubocop-rails/issues/215): Fix a false positive for `Rails/UniqueValidationWithoutIndex` when using Expression Indexes. ([@koic][])
* [#214](https://github.com/rubocop-hq/rubocop-rails/issues/214): Fix an error for `Rails/UniqueValidationWithoutIndex`when a table has no column definition. ([@koic][])
* [#221](https://github.com/rubocop-hq/rubocop-rails/issues/221): Make `Rails/UniqueValidationWithoutIndex` aware of `add_index` in db/schema.rb. ([@koic][])

### Changes

* [#223](https://github.com/rubocop-hq/rubocop-rails/pull/223): Mark `Rails/ApplicationController`, `Rails/ApplicationJob`, `Rails/ApplicationMailer`, and `Rails/ApplicationRecord` as unsafe autocorrect. ([@hoshinotsuyoshi][])

## 2.5.0 (2020-03-24)

### New features

* [#197](https://github.com/rubocop-hq/rubocop-rails/pull/197): Add `Rails/UniqueValidationWithoutIndex` cop. ([@pocke][])
* [#208](https://github.com/rubocop-hq/rubocop-rails/pull/208): Add new `Rails/IndexBy` and `Rails/IndexWith` cops. ([@djudd][], [@eugeneius][])
* [#150](https://github.com/rubocop-hq/rubocop-rails/issues/150): Add `EnforcedStyle: refute` for `Rails/RefuteMethods` cop. ([@koic][])

### Bug fixes

* [#180](https://github.com/rubocop-hq/rubocop-rails/issues/180): Fix a false positive for `HttpPositionalArguments` when using `get` method with `:to` option. ([@koic][])
* [#193](https://github.com/rubocop-hq/rubocop-rails/issues/193): Make `Rails/EnvironmentComparison` aware of `Rails.env` is used in RHS or when `!=` is used for comparison. ([@koic][])
* [#205](https://github.com/rubocop-hq/rubocop-rails/pull/205): Make `Rails/ReversibleMigration` aware of `:to_table` option of `remove_foreign_key`. ([@joshpencheon][])
* [#207](https://github.com/rubocop-hq/rubocop-rails/pull/207): Fix a false positive for `Rails/RakeEnvironment` when using Capistrano. ([@sinsoku][])

## 2.4.2 (2020-01-26)

### Bug fixes

* [#184](https://github.com/rubocop-hq/rubocop-rails/issues/184): Fix `Rake/Environment` to allow task with no block. ([@hanachin][])
* [#122](https://github.com/rubocop-hq/rubocop-rails/issues/122): Fix `Exclude` paths that were not inherited. ([@koic][])
* [#187](https://github.com/rubocop-hq/rubocop-rails/pull/187): Fix an issue that excluded files in rubocop-rails did not work. ([@sinsoku][])
* [#190](https://github.com/rubocop-hq/rubocop-rails/issues/190): Fix `Rails/SaveBang` when return value is checked immediately. ([@jas14][])

## 2.4.1 (2019-12-25)

### Bug fixes

* [#170](https://github.com/rubocop-hq/rubocop-rails/pull/170): Make `Rails/BulkChangeTable` not suggest combining methods with an intervening block. ([@mvz][])
* [#159](https://github.com/rubocop-hq/rubocop-rails/issues/159): Fix autocorrect for `Rails/EnumHash` when using % arrays notations. ([@ngouy][])

### Changes

* [#166](https://github.com/rubocop-hq/rubocop-rails/issues/166): Add db/schema.rb and bin/* to the excluded files. ([@fidalgo][])

## 2.4.0 (2019-11-27)

### New features

* [#123](https://github.com/rubocop-hq/rubocop-rails/pull/123): Add new `Rails/ApplicationController` and `Rails/ApplicationMailer` cops. ([@eugeneius][])
* [#130](https://github.com/rubocop-hq/rubocop-rails/pull/130): Add new `Rails/RakeEnvironment` cop. ([@pocke][])
* [#133](https://github.com/rubocop-hq/rubocop-rails/pull/133): Add new `Rails/SafeNavigationWithBlank` cop. ([@gyfis][])

### Bug fixes

* [#120](https://github.com/rubocop-hq/rubocop-rails/issues/120): Fix message for `Rails/SaveBang` when the save is in the body of a conditional. ([@jas14][])
* [#131](https://github.com/rubocop-hq/rubocop-rails/pull/131): Fix an incorrect autocorrect for `Rails/Presence` when using `[]` method. ([@forresty][])
* [#142](https://github.com/rubocop-hq/rubocop-rails/pull/142): Fix an incorrect autocorrect for `Rails/EnumHash` when using nested constants. ([@koic][])
* [#136](https://github.com/rubocop-hq/rubocop-rails/pull/136): Fix a false positive for `Rails/ReversibleMigration` when using `change_default` with `:from` and `:to` options. ([@sinsoku][])
* [#144](https://github.com/rubocop-hq/rubocop-rails/issues/144): Fix a false positive for `Rails/ReversibleMigration` when using `change_table_comment` or `change_column_comment` with a `:from` and `:to` hash. ([@DNA][])

### Changes

* [#156](https://github.com/rubocop-hq/rubocop-rails/pull/156): Make `Rails/UnknownEnv` cop aware of `Rails.env == 'unknown_env'`. ([@pocke][])
* [#141](https://github.com/rubocop-hq/rubocop-rails/pull/141): Change default of `EnforcedStyle` from `arguments` to `slashes` for `Rails/FilePath`. ([@koic][])

## 2.3.2 (2019-09-01)

### Bug fixes

* [#118](https://github.com/rubocop-hq/rubocop-rails/issues/118): Fix an incorrect autocorrect for `Rails/Validation` when attributes are specified with array literal. ([@koic][])
* [#116](https://github.com/rubocop-hq/rubocop-rails/issues/116): Fix an incorrect autocorrect for `Rails/Presence` when `else` branch of ternary operator is not nil. ([@koic][])

## 2.3.1 (2019-08-26)

### Bug fixes

* [#104](https://github.com/rubocop-hq/rubocop-rails/issues/104): Exclude Rails-independent `bin/bundle` by default. ([@koic][])
* [#107](https://github.com/rubocop-hq/rubocop-rails/issues/107): Fix style guide URLs when specifying `rubocop --display-style-guide` option. ([@koic][])
* [#111](https://github.com/rubocop-hq/rubocop-rails/issues/111): Fix an incorrect autocorrect for `Rails/Presence` when method arguments of `else` branch is not enclosed in parentheses. ([@koic][])

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
[@eugeneius]: https://github.com/eugeneius
[@jas14]: https://github.com/jas14
[@forresty]: https://github.com/forresty
[@sinsoku]: https://github.com/sinsoku
[@pocke]: https://github.com/pocke
[@gyfis]: https:/github.com/gyfis
[@DNA]: https://github.com/DNA
[@ngouy]: https://github.com/ngouy
[@mvz]: https://github.com/mvz
[@fidalgo]: https://github.com/fidalgo
[@hanachin]: https://github.com/hanachin
[@joshpencheon]: https://github.com/joshpencheon
[@djudd]: https://github.com/djudd
[@sunny]: https://github.com/sunny
[@hoshinotsuyoshi]: https://github.com/hoshinotsuyoshi
[@tejasbubane]: https://github.com/tejasbubane
[@diogoosorio]: https://github.com/diogoosorio
[@tabuchi0919]: https://github.com/tabuchi0919
[@ghiculescu]: https://github.com/ghiculescu
[@jcoyne]: https://github.com/jcoyne
[@fatkodima]: https://github.com/fatkodima
[@taylorthurlow]: https://github.com/taylorthurlow
[@krim]: https://github.com/krim
