# Change log

## master (unreleased)

### Bug fixes

* [#482](https://github.com/rubocop/rubocop-rails/pull/482): Fix a false positive for `Rails/RelativeDateConstant` when assigning (hashes/arrays/etc)-containing procs to a constant. ([@jdelStrother][])
* [#419](https://github.com/rubocop/rubocop-rails/issues/419): Fix an error for `Rails/UniqueValidationWithoutIndex` when using a unique index and `check_constraint` that has `nil` first argument. ([@koic][])

## 2.10.1 (2021-05-06)

### Bug fixes

* [#478](https://github.com/rubocop/rubocop-rails/pull/478): Fix `Rails/ReversibleMigrationMethodDefinition` cop's `Include`. ([@rhymes][])

## 2.10.0 (2021-05-05)

### New features

* [#457](https://github.com/rubocop/rubocop-rails/pull/457): Add new `Rails/ReversibleMigrationMethodDefinition` cop. ([@leonp1991][])
* [#446](https://github.com/rubocop/rubocop-rails/issues/446): Add new `Rails/RequireDependency` cop. ([@tubaxenor][])
* [#458](https://github.com/rubocop/rubocop-rails/issues/458): Add new `Rails/TimeZoneAssignment` cop. ([@olivierbuffon][])
* [#442](https://github.com/rubocop/rubocop-rails/pull/442): Add new `Rails/EnvironmentVariableAccess` cop. ([@drenmi][])

### Bug fixes

* [#421](https://github.com/rubocop/rubocop-rails/issues/421): Fix incorrect auto-correct for `Rails/LinkToBlank` when using `target: '_blank'` with hash brackets for the option. ([@koic][])
* [#436](https://github.com/rubocop/rubocop-rails/issues/436): Fix a false positive for `Rails/ContentTag` when the first argument is a splat argument. ([@koic][])
* [#435](https://github.com/rubocop/rubocop-rails/issues/435): Fix a false negative for `Rails/BelongsTo` when using `belongs_to` lambda block with `required` option. ([@koic][])
* [#451](https://github.com/rubocop/rubocop-rails/issues/451): Fix a false negative for `Rails/RelativeDateConstant` when a method is chained after a relative date method. ([@koic][])
* [#450](https://github.com/rubocop/rubocop-rails/issues/450): Fix a crash for `Rails/ContentTag` with nested content tags. ([@tejasbubane][])
* [#103](https://github.com/rubocop/rubocop-rails/issues/103): Fix a false positive for `Rails/FindEach` when not inheriting `ActiveRecord::Base` and using `all.each`. ([@koic][])
* [#466](https://github.com/rubocop/rubocop-rails/pull/466): Fix a false positive for `Rails/DynamicFindBy` when not inheriting `ApplicationRecord` and without no receiver. ([@koic][])
* [#147](https://github.com/rubocop/rubocop-rails/issues/147): Fix a false positive for `Rails/HasManyOrHasOneDependent` when specifying default `dependent: nil` strategy. ([@koic][])
* [#137](https://github.com/rubocop/rubocop-rails/issues/137): Make `Rails/HasManyOrHasOneDependent` aware of `readonly?` is `true`. ([@koic][])
* [#474](https://github.com/rubocop/rubocop-rails/pull/474): Fix a false negative for `Rails/SafeNavigation` when using `try!` without receiver. ([@koic][])
* [#126](https://github.com/rubocop/rubocop-rails/issues/126): Fix an incorrect auto-correct for `Rails/SafeNavigation` with `Style/RedndantSelf`. ([@koic][])
* [#476](https://github.com/rubocop/rubocop-rails/issues/476): Fix a false positive for `Rails/ReversibleMigration` when using `drop_table` with symbol proc. ([@koic][])

### Changes

* [#409](https://github.com/rubocop/rubocop-rails/pull/409): Deconstruct "table.column" in `Rails/WhereNot`. ([@mobilutz][])
* [#416](https://github.com/rubocop/rubocop-rails/pull/416): Make `Rails/HasManyOrHasOneDependent` accept combination of association extension and `with_options`. ([@ohbarye][])
* [#432](https://github.com/rubocop/rubocop-rails/issues/432): Exclude gemspec file by default for `Rails/TimeZone` cop. ([@koic][])
* [#440](https://github.com/rubocop/rubocop-rails/issues/440): This PR makes `Rails/TimeZone` aware of timezone specifier. ([@koic][])
* [#381](https://github.com/rubocop/rubocop-rails/pull/381): Update `IgnoredMethods` list for `Lint/NumberConversion` to allow Rails' duration methods. ([@dvandersluis][])
* [#444](https://github.com/rubocop/rubocop-rails/issues/444): Mark `Rails/Blank` as unsafe auto-correction. ([@koic][])
* [#451](https://github.com/rubocop/rubocop-rails/issues/451): Make `Rails/RelativeDateConstant` aware of `yesterday` and `tomorrow` methods. ([@koic][])
* [#454](https://github.com/rubocop/rubocop-rails/pull/454): Mark `Rails/WhereExists` as unsafe auto-correction. ([@koic][])
* [#403](https://github.com/rubocop/rubocop-rails/pull/403): Mark `Rails/WhereEquals` as unsafe auto-correction. ([@koic][])
* [#379](https://github.com/rubocop/rubocop-rails/issues/379): Mark `Rails/DynamicFindBy` as unsafe. ([@koic][])
* [#106](https://github.com/rubocop/rubocop-rails/issues/106): Mark `Rails/ReflectionClassName` as unsafe. ([@koic][])
* [#106](https://github.com/rubocop/rubocop-rails/issues/106): Make `Rails/ReflectionClassName` aware of the use of string with `to_s`. ([@koic][])
* [#456](https://github.com/rubocop/rubocop-rails/pull/456): Drop Ruby 2.4 support. ([@koic][])
* [#462](https://github.com/rubocop/rubocop-rails/pull/462): Require RuboCop 1.7 or higher. ([@koic][])

## 2.9.1 (2020-12-16)

### Bug fixes

* [#408](https://github.com/rubocop/rubocop-rails/pull/408): Fix bug in `Rails/FindEach` where config was ignored. ([@ghiculescu][])
* [#401](https://github.com/rubocop/rubocop-rails/issues/401): Fix an error for `Rails/WhereEquals` using only named placeholder template without replacement argument. ([@koic][])

### Changes

* [#404](https://github.com/rubocop/rubocop-rails/issues/404): Make `Rails/HelperInstanceVariable` accepts of instance variables when a class which inherits `ActionView::Helpers::FormBuilder`. ([@koic][])
* [#406](https://github.com/rubocop/rubocop-rails/pull/406): Deconstruct "table.column" in `Rails/WhereEquals`. ([@mobilutz][])

## 2.9.0 (2020-12-09)

### New features

* [#362](https://github.com/rubocop/rubocop-rails/pull/362): Add new `Rails/WhereEquals` cop. ([@eugeneius][])
* [#339](https://github.com/rubocop/rubocop-rails/pull/339): Add new `Rails/AttributeDefaultBlockValue` cop. ([@cilim][])
* [#344](https://github.com/rubocop/rubocop-rails/pull/344): Add new `Rails/ArelStar` cop which checks for quoted literal asterisks in `arel_table` calls. ([@flanger001][])
* [#389](https://github.com/rubocop/rubocop-rails/issues/389): Add `IgnoredMethods` config option for `Rails/FindEach` cop. ([@tejasbubane][])

### Bug fixes

* [#371](https://github.com/rubocop/rubocop-rails/pull/371): Fix an infinite loop error for `Rails/ActiveRecordCallbacksOrder` when callbacks have inline comments. ([@fatkodima][])
* [#364](https://github.com/rubocop/rubocop-rails/pull/364): Fix a problem that `Rails/UniqueValidationWithoutIndex` doesn't work in classes defined with compact style. ([@sinsoku][])
* [#384](https://github.com/rubocop/rubocop-rails/issues/384): Mark unsafe for `Rails/NegateInclude`. ([@koic][])
* [#394](https://github.com/rubocop/rubocop-rails/pull/394): Fix false offense detection of `Rails/RedundantAllowNil` when using both allow_nil and allow_blank on different helpers of the same validator`. ([@ngouy][])

### Changes

* [#383](https://github.com/rubocop/rubocop-rails/pull/383): Require RuboCop 0.90 or higher. ([@koic][])
* [#365](https://github.com/rubocop/rubocop-rails/issues/365): Mark `Rails/SquishedSQLHeredocs` unsafe for autocorrection. ([@tejasbubane][])

## 2.8.1 (2020-09-16)

### Bug fixes

* [#345](https://github.com/rubocop/rubocop-rails/issues/345): Fix error of `Rails/AfterCommitOverride` on `after_commit` with a lambda. ([@pocke][])
* [#349](https://github.com/rubocop/rubocop-rails/pull/349): Fix errors of `Rails/UniqueValidationWithoutIndex`. ([@Tietew][])
* [#338](https://github.com/rubocop/rubocop-rails/issues/338): Fix a false positive for `Rails/IndexBy` and `Rails/IndexWith` when the `each_with_object` hash is used in the transformed key or value. ([@eugeneius][])
* [#351](https://github.com/rubocop/rubocop-rails/pull/351): Add `<>` operator to `Rails/WhereNot` cop. ([@Tietew][])
* [#352](https://github.com/rubocop/rubocop-rails/pull/352): Do not register offense if given a splatted hash. ([@dvandersluis][])
* [#346](https://github.com/rubocop/rubocop-rails/pull/346): Fix a false positive for `Rails/DynamicFindBy` when any of the arguments are splat argument. ([@koic][])
* [#357](https://github.com/rubocop/rubocop-rails/issues/357): Fix a false positive for `Rails/ReversibleMigration` when keyword arguments of `change_column_default` are in the order of `to`, `from`. ([@koic][])

## 2.8.0 (2020-09-04)

### New features

* [#291](https://github.com/rubocop/rubocop-rails/pull/291): Add new `Rails/SquishedSQLHeredocs` cop. ([@mobilutz][])
* [#52](https://github.com/rubocop/rubocop-rails/issues/52): Add new `Rails/AfterCommitOverride` cop. ([@fatkodima][])
* [#323](https://github.com/rubocop/rubocop-rails/pull/323): Add new `Rails/OrderById` cop. ([@fatkodima][])
* [#274](https://github.com/rubocop/rubocop-rails/pull/274): Add new `Rails/WhereNot` cop. ([@fatkodima][])
* [#311](https://github.com/rubocop/rubocop-rails/issues/311): Make `Rails/HelperInstanceVariable` aware of memoization. ([@koic][])
* [#332](https://github.com/rubocop/rubocop-rails/issues/332): Fix `Rails/ReflectionClassName` cop false negative when relation had a scope parameter. ([@bubaflub][])

### Bug fixes

* [#315](https://github.com/rubocop/rubocop-rails/pull/315): Allow to use frozen scope for `Rails/UniqueValidationWithoutIndex`. ([@krim][])
* [#313](https://github.com/rubocop/rubocop-rails/pull/313): Fix `Rails/ActiveRecordCallbacksOrder` to preserve the original callback execution order. ([@eugeneius][])
* [#319](https://github.com/rubocop/rubocop-rails/issues/319): Fix a false positive for `Rails/Inquiry` when `#inquiry`'s receiver is a variable. ([@koic][])
* [#327](https://github.com/rubocop/rubocop-rails/pull/327): Fix `Rails/ContentTag` autocorrect to handle html5 tag names with hyphens. ([@jaredmoody][])

### Changes

* [#312](https://github.com/rubocop/rubocop-rails/pull/312): Mark `Rails/MailerName` as unsafe for auto-correct. ([@eugeneius][])
* [#294](https://github.com/rubocop/rubocop-rails/pull/294): Update `Rails/ReversibleMigration` to register offenses for `remove_columns` and `remove_index`. ([@philcoggins][])
* [#310](https://github.com/rubocop/rubocop-rails/issues/310): Add `EnforcedStyle` to `Rails/PluckInWhere`. By default, it does not register an offense if `pluck` method's receiver is a variable. ([@koic][])
* [#320](https://github.com/rubocop/rubocop-rails/pull/320): Mark `Rails/UniqBeforePluck` as unsafe auto-correction. ([@kunitoo][])
* [#324](https://github.com/rubocop/rubocop-rails/pull/324): Make `Rails/IndexBy` and `Rails/IndexWith` aware of `to_h` with block. ([@eugeneius][])
* [#341](https://github.com/rubocop/rubocop-rails/pull/341): Make `Rails/WhereExists` configurable to allow `where(...).exists?` to be the preferred style. ([@dvandersluis][])

## 2.7.1 (2020-07-26)

### Bug fixes

* [#297](https://github.com/rubocop/rubocop-rails/pull/297): Handle an upstream Ruby issue where the DidYouMean module is not available, which would break the `Rails/UnknownEnv` cop. ([@taylorthurlow][])
* [#300](https://github.com/rubocop/rubocop-rails/issues/300): Fix `Rails/RenderInline` error on variable key in render options. ([@tejasbubane][])
* [#305](https://github.com/rubocop/rubocop-rails/issues/305): Fix crash in `Rails/MatchRoute` cop when `via` option is a variable. ([@tejasbubane][])

### Changes

* [#301](https://github.com/rubocop/rubocop-rails/issues/301): Set disabled by default for `Rails/PluckId`. ([@koic][])

## 2.7.0 (2020-07-21)

### New features

* [#283](https://github.com/rubocop/rubocop-rails/pull/283): Add new `Rails/FindById` cop. ([@fatkodima][])
* [#285](https://github.com/rubocop/rubocop-rails/pull/285): Add new `Rails/ActiveRecordCallbacksOrder` cop. ([@fatkodima][])
* [#276](https://github.com/rubocop/rubocop-rails/pull/276): Add new `Rails/RenderPlainText` cop. ([@fatkodima][])
* [#76](https://github.com/rubocop/rubocop-rails/issues/76): Add new `Rails/DefaultScope` cop. ([@fatkodima][])
* [#275](https://github.com/rubocop/rubocop-rails/pull/275): Add new `Rails/MatchRoute` cop. ([@fatkodima][])
* [#286](https://github.com/rubocop/rubocop-rails/pull/286): Add new `Rails/WhereExists` cop. ([@fatkodima][])
* [#271](https://github.com/rubocop/rubocop-rails/pull/271): Add new `Rails/RenderInline` cop. ([@fatkodima][])
* [#281](https://github.com/rubocop/rubocop-rails/pull/281): Add new `Rails/MailerName` cop. ([@fatkodima][])
* [#280](https://github.com/rubocop/rubocop-rails/pull/280): Add new `Rails/ShortI18n` cop. ([@fatkodima][])
* [#282](https://github.com/rubocop/rubocop-rails/pull/282): Add new `Rails/Inquiry` cop. ([@fatkodima][])
* [#246](https://github.com/rubocop/rubocop-rails/issues/246): Add new `Rails/PluckInWhere` cop. ([@fatkodima][])
* [#17](https://github.com/rubocop/rubocop-rails/issues/17): Add new `Rails/NegateInclude` cop. ([@fatkodima][])
* [#278](https://github.com/rubocop/rubocop-rails/pull/278): Add new `Rails/Pluck` cop. ([@eugeneius][])
* [#272](https://github.com/rubocop/rubocop-rails/pull/272): Add new `Rails/PluckId` cop. ([@fatkodima][])

### Bug fixes

* [#261](https://github.com/rubocop/rubocop-rails/issues/261): Fix auto correction for `Rails/ContentTag` when `content_tag` is called with options hash and block. ([@fatkodima][])

### Changes

* [#263](https://github.com/rubocop/rubocop-rails/pull/263): Change terminology to `ForbiddenMethods` and `AllowedMethods`. ([@jcoyne][])
* [#289](https://github.com/rubocop/rubocop-rails/pull/289): Update `Rails/SkipsModelValidations` to register an offense for `insert_all`, `touch_all`, `upsert_all`, etc. ([@eugeneius][])
* [#293](https://github.com/rubocop/rubocop-rails/pull/293): Require RuboCop 0.87 or higher. ([@koic][])

## 2.6.0 (2020-06-08)

### New features

* [#51](https://github.com/rubocop/rubocop-rails/issues/51): Add allowed receiver class names option for `Rails/DynamicFindBy`. ([@tejasbubane][])
* [#211](https://github.com/rubocop/rubocop-rails/issues/211): Add autocorrect to `Rails/RakeEnvironment` cop. ([@tejasbubane][])
* [#242](https://github.com/rubocop/rubocop-rails/pull/242): Add `Rails/ContentTag` cop. ([@tabuchi0919][])
* [#249](https://github.com/rubocop/rubocop-rails/pull/249): Add new `Rails/Pick` cop. ([@eugeneius][])
* [#257](https://github.com/rubocop/rubocop-rails/pull/257): Add new `Rails/RedundantForeignKey` cop. ([@eugeneius][])

### Bug fixes

* [#12](https://github.com/rubocop/rubocop-rails/issues/12): Fix a false positive for `Rails/SkipsModelValidations` when passing a boolean literal to `touch`. ([@eugeneius][])
* [#238](https://github.com/rubocop/rubocop-rails/issues/238): Fix auto correction for `Rails/IndexBy` when the `.to_h` invocation is separated in multiple lines. ([@diogoosorio][])
* [#248](https://github.com/rubocop/rubocop-rails/pull/248): Fix a false positive for `Rails/SaveBang` when `update` is called on `ENV`. ([@eugeneius][])
* [#251](https://github.com/rubocop/rubocop-rails/pull/251): Fix a false positive for `Rails/FilePath` when the result of `Rails.root.join` is interpolated at the end of a string. ([@eugeneius][])
* [#91](https://github.com/rubocop/rubocop-rails/issues/91): Fix `Rails/UniqBeforePluck` to not recommend using `uniq` in `ActiveRecord::Relation`s anymore since it was deprecated in Rails 5.0. ([@santib][], [@ghiculescu][])

### Changes

* [#233](https://github.com/rubocop/rubocop-rails/pull/233): **(BREAKING)** Drop support for Ruby 2.3. ([@koic][])
* [#236](https://github.com/rubocop/rubocop-rails/pull/236): **(BREAKING)** Drop support for Rails 4.1 or lower. ([@koic][])
* [#210](https://github.com/rubocop/rubocop-rails/issues/210): Accept `redirecto_to(...) and return` and similar cases. ([@koic][])
* [#258](https://github.com/rubocop/rubocop-rails/pull/258): Drop support for RuboCop 0.81 or lower. ([@koic][])

## 2.5.2 (2020-04-09)

### Bug fixes

* [#227](https://github.com/rubocop/rubocop-rails/issues/227): Make `Rails/UniqueValidationWithoutIndex` aware of updating db/schema.rb. ([@koic][])

## 2.5.1 (2020-04-02)

### Bug fixes

* [#213](https://github.com/rubocop/rubocop-rails/pull/213): Fix a false positive for `Rails/UniqueValidationWithoutIndex` when using conditions. ([@sunny][])
* [#215](https://github.com/rubocop/rubocop-rails/issues/215): Fix a false positive for `Rails/UniqueValidationWithoutIndex` when using Expression Indexes. ([@koic][])
* [#214](https://github.com/rubocop/rubocop-rails/issues/214): Fix an error for `Rails/UniqueValidationWithoutIndex`when a table has no column definition. ([@koic][])
* [#221](https://github.com/rubocop/rubocop-rails/issues/221): Make `Rails/UniqueValidationWithoutIndex` aware of `add_index` in db/schema.rb. ([@koic][])

### Changes

* [#223](https://github.com/rubocop/rubocop-rails/pull/223): Mark `Rails/ApplicationController`, `Rails/ApplicationJob`, `Rails/ApplicationMailer`, and `Rails/ApplicationRecord` as unsafe autocorrect. ([@hoshinotsuyoshi][])

## 2.5.0 (2020-03-24)

### New features

* [#197](https://github.com/rubocop/rubocop-rails/pull/197): Add `Rails/UniqueValidationWithoutIndex` cop. ([@pocke][])
* [#208](https://github.com/rubocop/rubocop-rails/pull/208): Add new `Rails/IndexBy` and `Rails/IndexWith` cops. ([@djudd][], [@eugeneius][])
* [#150](https://github.com/rubocop/rubocop-rails/issues/150): Add `EnforcedStyle: refute` for `Rails/RefuteMethods` cop. ([@koic][])

### Bug fixes

* [#180](https://github.com/rubocop/rubocop-rails/issues/180): Fix a false positive for `HttpPositionalArguments` when using `get` method with `:to` option. ([@koic][])
* [#193](https://github.com/rubocop/rubocop-rails/issues/193): Make `Rails/EnvironmentComparison` aware of `Rails.env` is used in RHS or when `!=` is used for comparison. ([@koic][])
* [#205](https://github.com/rubocop/rubocop-rails/pull/205): Make `Rails/ReversibleMigration` aware of `:to_table` option of `remove_foreign_key`. ([@joshpencheon][])
* [#207](https://github.com/rubocop/rubocop-rails/pull/207): Fix a false positive for `Rails/RakeEnvironment` when using Capistrano. ([@sinsoku][])

## 2.4.2 (2020-01-26)

### Bug fixes

* [#184](https://github.com/rubocop/rubocop-rails/issues/184): Fix `Rake/Environment` to allow task with no block. ([@hanachin][])
* [#122](https://github.com/rubocop/rubocop-rails/issues/122): Fix `Exclude` paths that were not inherited. ([@koic][])
* [#187](https://github.com/rubocop/rubocop-rails/pull/187): Fix an issue that excluded files in rubocop-rails did not work. ([@sinsoku][])
* [#190](https://github.com/rubocop/rubocop-rails/issues/190): Fix `Rails/SaveBang` when return value is checked immediately. ([@jas14][])

## 2.4.1 (2019-12-25)

### Bug fixes

* [#170](https://github.com/rubocop/rubocop-rails/pull/170): Make `Rails/BulkChangeTable` not suggest combining methods with an intervening block. ([@mvz][])
* [#159](https://github.com/rubocop/rubocop-rails/issues/159): Fix autocorrect for `Rails/EnumHash` when using % arrays notations. ([@ngouy][])

### Changes

* [#166](https://github.com/rubocop/rubocop-rails/issues/166): Add db/schema.rb and bin/* to the excluded files. ([@fidalgo][])

## 2.4.0 (2019-11-27)

### New features

* [#123](https://github.com/rubocop/rubocop-rails/pull/123): Add new `Rails/ApplicationController` and `Rails/ApplicationMailer` cops. ([@eugeneius][])
* [#130](https://github.com/rubocop/rubocop-rails/pull/130): Add new `Rails/RakeEnvironment` cop. ([@pocke][])
* [#133](https://github.com/rubocop/rubocop-rails/pull/133): Add new `Rails/SafeNavigationWithBlank` cop. ([@gyfis][])

### Bug fixes

* [#120](https://github.com/rubocop/rubocop-rails/issues/120): Fix message for `Rails/SaveBang` when the save is in the body of a conditional. ([@jas14][])
* [#131](https://github.com/rubocop/rubocop-rails/pull/131): Fix an incorrect autocorrect for `Rails/Presence` when using `[]` method. ([@forresty][])
* [#142](https://github.com/rubocop/rubocop-rails/pull/142): Fix an incorrect autocorrect for `Rails/EnumHash` when using nested constants. ([@koic][])
* [#136](https://github.com/rubocop/rubocop-rails/pull/136): Fix a false positive for `Rails/ReversibleMigration` when using `change_default` with `:from` and `:to` options. ([@sinsoku][])
* [#144](https://github.com/rubocop/rubocop-rails/issues/144): Fix a false positive for `Rails/ReversibleMigration` when using `change_table_comment` or `change_column_comment` with a `:from` and `:to` hash. ([@DNA][])

### Changes

* [#156](https://github.com/rubocop/rubocop-rails/pull/156): Make `Rails/UnknownEnv` cop aware of `Rails.env == 'unknown_env'`. ([@pocke][])
* [#141](https://github.com/rubocop/rubocop-rails/pull/141): Change default of `EnforcedStyle` from `arguments` to `slashes` for `Rails/FilePath`. ([@koic][])

## 2.3.2 (2019-09-01)

### Bug fixes

* [#118](https://github.com/rubocop/rubocop-rails/issues/118): Fix an incorrect autocorrect for `Rails/Validation` when attributes are specified with array literal. ([@koic][])
* [#116](https://github.com/rubocop/rubocop-rails/issues/116): Fix an incorrect autocorrect for `Rails/Presence` when `else` branch of ternary operator is not nil. ([@koic][])

## 2.3.1 (2019-08-26)

### Bug fixes

* [#104](https://github.com/rubocop/rubocop-rails/issues/104): Exclude Rails-independent `bin/bundle` by default. ([@koic][])
* [#107](https://github.com/rubocop/rubocop-rails/issues/107): Fix style guide URLs when specifying `rubocop --display-style-guide` option. ([@koic][])
* [#111](https://github.com/rubocop/rubocop-rails/issues/111): Fix an incorrect autocorrect for `Rails/Presence` when method arguments of `else` branch is not enclosed in parentheses. ([@koic][])

## 2.3.0 (2019-08-13)

### New features

* [#78](https://github.com/rubocop/rubocop-rails/issues/78): Add new `Rails/EnumHash` cop. ([@fedeagripa][], [@brunvez][], [@santib][])

### Bug fixes

* [#53](https://github.com/rubocop/rubocop-rails/issues/53): Fix a false positive for `Rails/SaveBang` when implicitly return using finder method and creation method connected by `||`. ([@koic][])
* [#97](https://github.com/rubocop/rubocop-rails/pull/97): Fix two false negatives for `Rails/EnumUniqueness`. 1. When `enum` name is not a literal. 2. When `enum` has multiple definitions. ([@santib][])

### Changes

* [#98](https://github.com/rubocop/rubocop-rails/pull/98): Mark `Rails/ActiveRecordAliases` as `SafeAutoCorrect` false and disable autocorrect by default. ([@prathamesh-sonpatki][])
* [#101](https://github.com/rubocop/rubocop-rails/pull/101): Mark `Rails/SaveBang` as `SafeAutoCorrect` false and disable autocorrect by default. ([@prathamesh-sonpatki][])
* [#102](https://github.com/rubocop/rubocop-rails/pull/102): Include `create_or_find_by` in `Rails/SaveBang` cop. ([@MaximeLaurenty][])

## 2.2.1 (2019-07-13)

### Bug fixes

* [#86](https://github.com/rubocop/rubocop-rails/issues/86): Fix an incorrect auto-correct for `Rails/TimeZone` when using `Time.new`. ([@koic][])

## 2.2.0 (2019-07-07)

### Bug fixes

* [#67](https://github.com/rubocop/rubocop-rails/issues/67): Fix an incorrect auto-correct for `Rails/TimeZone` when using `DateTime`. ([@koic][])

## 2.1.0 (2019-06-26)

### Bug fixes

* [#43](https://github.com/rubocop/rubocop-rails/issues/43): Remove `change_column_null` method from `BulkChangeTable` cop offenses. ([@anthony-robin][])
* [#79](https://github.com/rubocop/rubocop-rails/issues/79): Fix `RuboCop::Cop::Rails not defined (NameError)`. ([@rmm5t][])

### Changes

* [#74](https://github.com/rubocop/rubocop-rails/pull/74): Drop Rails 3 support. ([@koic][])

## 2.0.1 (2019-06-08)

### Changes

* [#68](https://github.com/rubocop/rubocop-rails/pull/68): Relax rack dependency for Rails 4. ([@buehmann][])

## 2.0.0 (2019-05-22)

### New features

* Extract Rails cops from rubocop/rubocop repository. ([@koic][])
* [#19](https://github.com/rubocop/rubocop-rails/issues/19): Add new `Rails/HelperInstanceVariable` cop. ([@andyw8][])

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
[@philcoggins]: https://github.com/philcoggins
[@kunitoo]: https://github.com/kunitoo
[@jaredmoody]: https://github.com/jaredmoody
[@mobilutz]: https://github.com/mobilutz
[@bubaflub]: https://github.com/bubaflub
[@dvandersluis]: https://github.com/dvandersluis
[@Tietew]: https://github.com/Tietew
[@cilim]: https://github.com/cilim
[@flanger001]: https://github.com/flanger001
[@ohbarye]: https://github.com/ohbarye
[@tubaxenor]: https://github.com/tubaxenor
[@olivierbuffon]: https://github.com/olivierbuffon
[@leonp1991]: https://github.com/leonp1991
[@drenmi]: https://github.com/drenmi
[@rhymes]: https://github.com/rhymes
[@jdelStrother]: https://github.com/jdelStrother
