# Change log

<!---
  Do NOT edit this CHANGELOG.md file by hand directly, as it is automatically updated.
  Please add an entry file to the https://github.com/rubocop/rubocop-rails/blob/master/changelog/
  named `{change_type}_{change_description}.md` if the new code introduces user-observable changes.
  See https://github.com/rubocop/rubocop-rails/blob/master/CONTRIBUTING.md#changelog-entry-format for details.
-->

## master (unreleased)

## 2.23.1 (2023-12-25)

### Bug fixes

* [#1221](https://github.com/rubocop/rubocop-rails/issues/1221): Fix an exception in `Rails/WhereNot` when calling `.where` on an implicit receiver (e.g. inside model code). ([@bquorning][])

## 2.23.0 (2023-12-16)

### New features

* [#1183](https://github.com/rubocop/rubocop-rails/pull/1183): Support PostGIS adapter for PostgreSQL. ([@Dania02525][])

### Bug fixes

* [#1206](https://github.com/rubocop/rubocop-rails/issues/1206): Fix an error for `Rails/WhereMissing` where join method is called without arguments. ([@fatkodima][])
* [#1189](https://github.com/rubocop/rubocop-rails/issues/1189): Fix false negatives for `Rails/Pluck` when using safe navigation method calls. ([@koic][])
* [#1204](https://github.com/rubocop/rubocop-rails/pull/1204): Make `Rails/ActiveSupportAliases`, `Rails/FindBy`, `Rails/FindById`, `Rails/Inquiry`, `Rails/Pick` `Rails/PluckId`, `Rails/PluckInWhere`, `Rails/WhereEquals`, `Rails/WhereExists`, and `Rails/WhereNot` cops aware of safe navigation operator. ([@koic][])

### Changes

* [#1213](https://github.com/rubocop/rubocop-rails/issues/1213): Update `Rails/PluckInWhere` to check for `.ids` call. ([@fatkodima][])
* [#1181](https://github.com/rubocop/rubocop-rails/pull/1181): Support `Nokogiri::HTML.parse` and `Nokogiri::HTML5.parse` on `Rails/ResponseParsedBody`. ([@r7kamura][])
* [#1198](https://github.com/rubocop/rubocop-rails/issues/1198): Support `where.not` for `Rails/PluckInWhere`. ([@fatkodima][])

## 2.22.2 (2023-11-19)

### Bug fixes

* [#1172](https://github.com/rubocop/rubocop-rails/issues/1172): Fix an error for `Rails/UnknownEnv` when using Rails 7.1. ([@koic][])
* [#1173](https://github.com/rubocop/rubocop-rails/issues/1173): Fix an error for `Rails/RedundantActiveRecordAllMethod` cop when used with RuboCop 1.51 or lower. ([@koic][])

### Changes

* [#1171](https://github.com/rubocop/rubocop-rails/pull/1171): Change `Rails/RedundantActiveRecordAllMethod` to ignore `delete_all` and `destroy_all` when receiver is an association. ([@masato-bkn][])
* [#1178](https://github.com/rubocop/rubocop-rails/pull/1178): Require RuboCop AST 1.30.0+. ([@koic][])

## 2.22.1 (2023-10-28)

### Bug fixes

* [#1145](https://github.com/rubocop/rubocop-rails/issues/1145): Fix a false positive for `Rails/DuplicateAssociation` when using duplicate `belongs_to` associations of same class without other arguments. ([@koic][])

## 2.22.0 (2023-10-27)

### New features

* [#906](https://github.com/rubocop/rubocop-rails/pull/906): Add `Rails/EnvLocal` cop. ([@sambostock][])
* [#1128](https://github.com/rubocop/rubocop-rails/issues/1128): Make `Rails/DuplicateAssociation` aware of duplicate `class_name`. ([@koic][])
* [#1157](https://github.com/rubocop/rubocop-rails/pull/1157): Support some Rails 7.1's new querying methods for `Rails/RedundantActiveRecordAllMethod`. ([@koic][])
* [#1147](https://github.com/rubocop/rubocop-rails/issues/1147): Support the Trilogy adapter for MySQL. ([@koic][])

### Bug fixes

* [#952](https://github.com/rubocop/rubocop-rails/issues/952): Fix a false positive for `Rails/NotNullColumn` when using `null: false` for MySQL's TEXT type. ([@koic][])
* [#1041](https://github.com/rubocop/rubocop-rails/issues/1041): Fix a false positive for `Rails/Output` when output method is called with block argument. ([@koic][])
* [#1143](https://github.com/rubocop/rubocop-rails/issues/1143): Fix an error for `Rails/RedundantActiveRecordAllMethod` when using RuboCop 1.51 or lower. ([@koic][])
* [#1105](https://github.com/rubocop/rubocop-rails/issues/1105): Fix false positives for `Rails/RedundantPresenceValidationOnBelongsTo` when using `validates` with `:if` or `:unless` options. ([@koic][])
* [#1158](https://github.com/rubocop/rubocop-rails/issues/1158): `Rails/HasManyOrHasOneDependent` does not add offence when has_many or has_one is called on an explicit receiver. ([@samrjenkins][])
* [#1160](https://github.com/rubocop/rubocop-rails/issues/1160): Fix `Rails/SaveBang` to ignore parenthesis. ([@fatkodima][])

### Changes

* [#1152](https://github.com/rubocop/rubocop-rails/pull/1152): Add more dangerous column names to `Rails/DangerousColumnNames`. ([@r7kamura][])
* [#1039](https://github.com/rubocop/rubocop-rails/issues/1039): Deprecate `Rails/ActionFilter` cop; it will be disabled by default. ([@koic][])
* [#893](https://github.com/rubocop/rubocop-rails/issues/893): Support `local` as an environment for `Rails/UnknownEnv` from Rails 7.1 onward. ([@ghiculescu][])

## 2.21.2 (2023-09-30)

### Bug fixes

* [#1126](https://github.com/rubocop/rubocop-rails/pull/1126): Fix a false positive for `Rails/RedundantActiveRecordAllMethod` when using some `Enumerable`'s methods with block argument. ([@koic][])
* [#1121](https://github.com/rubocop/rubocop-rails/issues/1121): Fix an error for `Rails/SelectMap` when using `select(:column_name).map(&:column_name)` without receiver model. ([@koic][])
* [#1119](https://github.com/rubocop/rubocop-rails/issues/1119): Fix an incorrect autocorrect for `Rails/RedundantActiveRecordAllMethod`  when `all` has parentheses. ([@masato-bkn][])
* [#1130](https://github.com/rubocop/rubocop-rails/issues/1130): Fix crash for `Rails/UniqueValidationWithoutIndex` with bare validate. ([@jamiemccarthy][])
* [#1124](https://github.com/rubocop/rubocop-rails/issues/1124): Fix false positives for `Rails/RedundantActiveRecordAllMethod` when receiver is not an Active Record model. ([@koic][])

## 2.21.1 (2023-09-14)

### Bug fixes

* [#1108](https://github.com/rubocop/rubocop-rails/issues/1108): Fix an incorrect autocorrect for `Rails/TimeZone` when using `String#to_time`. ([@koic][])
* [#1109](https://github.com/rubocop/rubocop-rails/issues/1109): Fix error for `Rails/RedundantActiveRecordAllMethod` when `all` is an argument for AR methods. ([@masato-bkn][])
* [#1110](https://github.com/rubocop/rubocop-rails/issues/1110): Fix false positive for `Rails/RedundantActiveRecordAllMethod` when `all` has any parameters. ([@masato-bkn][])

## 2.21.0 (2023-09-09)

### New features

* [#1075](https://github.com/rubocop/rubocop-rails/issues/1075): Add new `Rails/SelectMap` cop that checks for uses of `select(:column_name)` with `map(&:column_name)`. ([@koic][])
* [#158](https://github.com/rubocop/rubocop-rails/issues/158): Add `Rails/DangerousColumnNames` cop. ([@r7kamura][])
* [#1072](https://github.com/rubocop/rubocop-rails/pull/1072): Add `TransactionMethods` config for `Rails/TransactionExitStatement` to detect custom transaction methods. ([@marocchino][])
* [#967](https://github.com/rubocop/rubocop-rails/issues/967): Add new `Rails/UnusedRenderContent` cop. ([@samrjenkins][])
* [#1052](https://github.com/rubocop/rubocop-rails/pull/1052): Add explicit style to `Rails/I18nLazyLookup`. ([@sunny][])
* [#1016](https://github.com/rubocop/rubocop-rails/issues/1016): Add new `Rails/RedundantActiveRecordAllMethod` cop. ([@masato-bkn][])

### Bug fixes

* [#1078](https://github.com/rubocop/rubocop-rails/issues/1078): Fix a false negative for `Rails/LexicallyScopedActionFilter` when no methods are defined. ([@vlad-pisanov][])
* [#1060](https://github.com/rubocop/rubocop-rails/issues/1060): Fix a false positive for `Rails/HttpStatus` when using symbolic value that have no numeric value mapping. ([@koic][])
* [#1004](https://github.com/rubocop/rubocop-rails/pull/1004): Fix a false-positive for `Rails/RootPathnameMethods` on Ruby 2.4 or lower. ([@r7kamura][])
* [#1066](https://github.com/rubocop/rubocop-rails/issues/1066): Fix an error for `Rails/FilePath` when string interpolated `Rails.root` is followed by a message starting with `.`. ([@koic][])
* [#1049](https://github.com/rubocop/rubocop-rails/pull/1049): Fix an incorrect autocorrect for `Rails/FilePath` when File.join with Rails.root and path starting with `/`. ([@ydah][])
* [#1045](https://github.com/rubocop/rubocop-rails/issues/1045): Fix an incorrect autocorrect for `Rails/NegateInclude` when using `Style/InverseMethods`'s autocorrection together. ([@koic][])
* [#1062](https://github.com/rubocop/rubocop-rails/issues/1062): Fix autocorrection for `Rails/RakeEnvironment` when rake task accepts arguments. ([@fastjames][])
* [#1036](https://github.com/rubocop/rubocop-rails/issues/1036): Fix an error for `UniqueValidationWithoutIndex` when `db/schema.rb` is empty. ([@fatkodima][])
* [#1042](https://github.com/rubocop/rubocop-rails/pull/1042): Fix no offences for `Rails/SchemaComment` when create_table with multi t columns. ([@nipe0324][])

### Changes

* [#1056](https://github.com/rubocop/rubocop-rails/pull/1056): Fix database adapter detection for nested config. ([@mjankowski][])
* [#1031](https://github.com/rubocop/rubocop-rails/pull/1031): Make `Lint/SafeNavigationChain` allow `presence_in`. ([@koic][])
* [#1080](https://github.com/rubocop/rubocop-rails/issues/1080): Make `Rails/HttpStatus` aware of string number status. ([@r7kamura][])
* [#1094](https://github.com/rubocop/rubocop-rails/issues/1094): Make `Rails/TimeZone` aware of `String#to_time`. ([@koic][])
* [#1015](https://github.com/rubocop/rubocop-rails/issues/1015): Make `Style/InvertibleUnlessCondition` aware of Active Support methods. ([@koic][])
* [#903](https://github.com/rubocop/rubocop-rails/pull/903): Read database config for `Rails/BulkChangeTable` from environment variable. ([@joergschiller][])
* [#1058](https://github.com/rubocop/rubocop-rails/issues/1058): Relax `Include` path for `Rails/FindBy` and `Rails/FindEach`. ([@koic][])
* [#994](https://github.com/rubocop/rubocop-rails/pull/994): Restrict DuplicateAssociation cop to ActiveRecord. ([@mjankowski][])

## 2.20.2 (2023-06-20)

### Bug fixes

* [#1028](https://github.com/rubocop/rubocop-rails/pull/1028): Fix an error for `Rails/UniqueValidationWithoutIndex` when the `presence: true` option is used alone for the `validates` method. ([@koic][])

## 2.20.1 (2023-06-19)

### Bug fixes

* [#1021](https://github.com/rubocop/rubocop-rails/pull/1021): Fix an error for `Rails/UniqueValidationWithoutIndex`. ([@ydah][])

## 2.20.0 (2023-06-18)

### New features

* [#999](https://github.com/rubocop/rubocop-rails/pull/999): Add autocorrection for `Rails/Date`. ([@r7kamura][])
* [#991](https://github.com/rubocop/rubocop-rails/pull/991): Add autocorrection for `Rails/FilePath`. ([@r7kamura][])
* [#988](https://github.com/rubocop/rubocop-rails/pull/988): Add autocorrection for `Rails/IgnoredSkipActionFilterOption`. ([@r7kamura][])

### Bug fixes

* [#1005](https://github.com/rubocop/rubocop-rails/pull/1005): Flag `break` in `with_lock` for `Rails/TransactionExitStatement`. ([@splattael][])
* [#997](https://github.com/rubocop/rubocop-rails/issues/997): Fix to Allow `NotNullColumn` to work with method calls and variables. ([@fidalgo][])
* [#989](https://github.com/rubocop/rubocop-rails/pull/989): Fix `Rails/FilePath` to detect offenses from complex string interpolation. ([@r7kamura][])
* [#1010](https://github.com/rubocop/rubocop-rails/issues/1010): Fix `Rails/ThreeStateBooleanColumn` for dynamic tables/columns. ([@fatkodima][])
* [#1008](https://github.com/rubocop/rubocop-rails/pull/1008): Fix `UniqueValidationWithoutIndex` to not detect offenses when a validation specifies `uniqueness: false`. ([@samrjenkins][])

### Changes

* [#1011](https://github.com/rubocop/rubocop-rails/pull/1011): Add `*_create_active_storage_variant_records.active_storage.rb` to `Rails/CreateTableWithTimestamps` exclude file list. ([@tka5][])
* [#995](https://github.com/rubocop/rubocop-rails/pull/995): Check for `or` method in `Rails/FindEach` cop. ([@masato-bkn][])
* [#1019](https://github.com/rubocop/rubocop-rails/pull/1019): Change db migration file pattern so that it supports multiple db. ([@r7kamura][])
* [#986](https://github.com/rubocop/rubocop-rails/pull/986): **(Breaking)** Drop Ruby 2.6 support. ([@koic][])
* [#992](https://github.com/rubocop/rubocop-rails/pull/992): Exclude `app/assets/**/*` by default. ([@r7kamura][])
* [#1014](https://github.com/rubocop/rubocop-rails/pull/1014): Make `Lint/RedundantSafeNavigation` aware of `presence` and `present?` methods. ([@koic][])
* [#1007](https://github.com/rubocop/rubocop-rails/issues/1007): Support `flash.now` for `Rails/I18nLocaleTexts`. ([@fatkodima][])

## 2.19.1 (2023-04-16)

### Bug fixes

* [#979](https://github.com/rubocop/rubocop-rails/issues/979): Fix an error for `Rails/ThreeStateBooleanColumn` when using `t.boolean` in `drop_table`. ([@koic][])

## 2.19.0 (2023-04-07)

### New features

* [#337](https://github.com/rubocop/rubocop-rails/issues/337): Add new `Rails/ThreeStateBooleanColumn` cop. ([@fatkodima][])
* [#45](https://github.com/rubocop/rubocop-rails/issues/45): Make `Rails/Delegate` aware of `self`. ([@koic][])

### Bug fixes

* [#934](https://github.com/rubocop/rubocop-rails/issues/934): Fix a false negative for `Rails/Output` when print methods without arguments. ([@koic][])
* [#99](https://github.com/rubocop/rubocop-rails/issues/99): Fix a false positive for `Rails/HttpPositionalArguments` when using `include Rack::Test::Methods`. ([@koic][])
* [#501](https://github.com/rubocop/rubocop-rails/issues/501): Fix a false positive for `Rails/OutputSafety` when using `html_safe` for `I18n` methods. ([@koic][])
* [#860](https://github.com/rubocop/rubocop-rails/issues/860): Fix a false positive for `Rails/Pluck` when using regexp literal key for `String#[]`. ([@koic][])
* [#938](https://github.com/rubocop/rubocop-rails/issues/938): Fix an error for `Rails/WhereNotWithMultipleConditions` when using `where.not.lt(condition)` as a Mongoid API'. ([@koic][])
* [#941](https://github.com/rubocop/rubocop-rails/issues/941): Remove redundant config for `Style/InverseMethods`. ([@koic][])

### Changes

* [#299](https://github.com/rubocop/rubocop-rails/pull/299): Add autocorrection for `Rails/ReflectionClassName`. ([@tejasbubane][])
* [#34](https://github.com/rubocop/rubocop-rails/issues/34): Allow `CreateTableWithTimestamps` when using `id: false` and not include `timestamps`. ([@koic][])
* [#694](https://github.com/rubocop/rubocop-rails/issues/694): Mark `Rails/FindEach` as unsafe. ([@koic][])
* [#940](https://github.com/rubocop/rubocop-rails/issues/940): Mark `Rails/ResponseParsedBody` as unsafe. ([@koic][])

## 2.18.0 (2023-02-25)

### New features

* [#863](https://github.com/rubocop/rubocop-rails/pull/863): Add `Rails/ResponseParsedBody` cop. ([@r7kamura][])

### Bug fixes

* [#824](https://github.com/rubocop/rubocop-rails/pull/824): Fix a false negative for `Rails/ActionControllerTestCase` when the class is namespaced. ([@vlad-pisanov][])
* [#909](https://github.com/rubocop/rubocop-rails/issues/909): Fix a false positive for `Rails/ActionControllerFlashBeforeRender` when using `flash` before `redirect_to` in `if` branch. ([@koic][])
* [#898](https://github.com/rubocop/rubocop-rails/issues/898): Fix a false positive for `Rails/ActiveRecordAliases` when arguments of `update_attributes` is empty. ([@koic][])
* [#920](https://github.com/rubocop/rubocop-rails/pull/920): Fix an error for `Rails/NegateInclude` when there is no receiver. ([@fatkodima][])
* [#931](https://github.com/rubocop/rubocop-rails/pull/931): Fix error in `Rails/Presence` when ternary operators are used in multiple lines. ([@r7kamura][])
* [#687](https://github.com/rubocop/rubocop-rails/issues/687): Fix `Rails/HasManyOrHasOneDependent` to correctly handle association methods with receiver. ([@fatkodima][])
* [#929](https://github.com/rubocop/rubocop-rails/issues/929): Prevent `Rails/SquishedSQLHeredocs` applying when single-line comments are present. ([@john-h-k][])
* [#887](https://github.com/rubocop/rubocop-rails/issues/887): Fix a false positive for `Rails/NotNullColumn` when adding a `:virtual` column. ([@fatkodima][])
* [#918](https://github.com/rubocop/rubocop-rails/pull/918): Fix `Rails/FreezeTime` running against Rails < 5.2 apps. ([@DRBragg][])
* [#895](https://github.com/rubocop/rubocop-rails/pull/895): Fix `Rails/UnusedIgnoredColumns` not recognizing columns added via `+=`. ([@lucthev][])

### Changes

* [#263](https://github.com/rubocop/rubocop-rails/pull/263): Accept actions defined via `alias` in `Rails/LexicallyScopedActionFilter`. ([@fatkodima][])
* [#902](https://github.com/rubocop/rubocop-rails/pull/902): Ignore `redirect` method for `Style/FormatStringToken` by default. ([@javierjulio][])
* [#935](https://github.com/rubocop/rubocop-rails/pull/935): Make `Style/InverseMethods` aware of Active Support's `present?`, `blank?`, `include?`, and `exclude?` methods. ([@koic][])
* [#914](https://github.com/rubocop/rubocop-rails/issues/914): Make `Style/InverseMethods` aware of `valid?` and `invalid?` methods. ([@koic][])
* [#826](https://github.com/rubocop/rubocop-rails/issues/826): Mark `Rails/Pluck` as unsafe. ([@fatkodima][])
* [#896](https://github.com/rubocop/rubocop-rails/pull/896): Raise severity of `Rails/ActiveRecordOverride`, `Rails/DeprecatedActiveModelErrorsMethods`, `Rails/DuplicateAssociation`, `Rails/DuplicateScope`, `Rails/TopLevelHashWithIndifferentAccess`, and `Rails/WhereNotWithMultipleConditions` cops to warning. ([@koic][])

## 2.17.4 (2022-12-25)

### Bug fixes

* [#870](https://github.com/rubocop/rubocop-rails/issues/870): Fix an error for `Rails/RootPathnameMethods` when using `Rails.env` argument within `Dir.glob`. ([@koic][])
* [#881](https://github.com/rubocop/rubocop-rails/pull/881): Fix a false positive for `Rails/ActionControllerFlashBeforeRender` when using `flash` in multiline `rescue` branch before `redirect_to`. ([@gurix][])
* [#871](https://github.com/rubocop/rubocop-rails/pull/871): Fix a false positive for `Rails/WhereMissing` when `left_joins(:foo)` and `where(foos: {id: nil})` separated by `or`, `and`. ([@ydah][])
* [#875](https://github.com/rubocop/rubocop-rails/pull/875): Make `Rails/RootPathnameMethods` aware of enforced style of `Style/StringLiterals`. ([@koic][])
* [#882](https://github.com/rubocop/rubocop-rails/pull/882): Fix false positive for `Rails/UniqueValidationWithoutIndex` with :conditions option. ([@etiennebarrie][])
* [#821](https://github.com/rubocop/rubocop-rails/issues/821): Enhance `Rails/TimeZone` to accept methods with the `:in` timezone option. ([@fatkodima][])

### Changes

* [#880](https://github.com/rubocop/rubocop-rails/pull/880): Add `Rails/I18nLocaleTexts` match for redirect_back. ([@bensheldon][])

## 2.17.3 (2022-11-20)

### Bug fixes

* [#843](https://github.com/rubocop/rubocop-rails/issues/843): Fix a false positive for `Rails/ActionControllerFlashBeforeRender` when using `flash` in multiline `if` branch before `redirect_to`. ([@koic][])
* [#841](https://github.com/rubocop/rubocop-rails/issues/841): Fix an error for `Rails/ActionOrder` when using unconventional order of multiple actions. ([@koic][])
* [#838](https://github.com/rubocop/rubocop-rails/issues/838): Fix an incorrect autocorrect for `Rails/ActionOrder` when using unconventional order of actions in conditions. ([@koic][])
* [#867](https://github.com/rubocop/rubocop-rails/pull/867): Fix autocorrection bug when `::Hash` is used on `Rails/IndexBy` and `Rails/IndexWith`. ([@r7kamura][])
* [#848](https://github.com/rubocop/rubocop-rails/issues/848): Fix a false positive for `Rails/FreezeTime` when using `travel_to` with an argument of `Time.new(...).in_time_zone`. ([@koic][])
* [#869](https://github.com/rubocop/rubocop-rails/pull/869): Fix false-positives that non Rails formats are offended on `Rails/ToSWithArgument`. ([@r7kamura][])
* [#866](https://github.com/rubocop/rubocop-rails/pull/866): Fix false-positives when constant is used with receiver on `Rails/DurationArithmetic`, `Rails/IndexBy`, `Rails/IndexWIth`, and `Rails/RequireDependency`. ([@r7kamura][])
* [#850](https://github.com/rubocop/rubocop-rails/pull/850): Fix default configuration for `Rails/I18nLazyLookup`. ([@vlad-pisanov][])
* [#837](https://github.com/rubocop/rubocop-rails/pull/837): Fix incorrect autocorrection of `Rails/ActionOrder` about comments. ([@r7kamura][])
* [#855](https://github.com/rubocop/rubocop-rails/pull/855): Fix Rails/RootPathnameMethods autocorrection for Pathname calls without parens. ([@gsamokovarov][])
* [#868](https://github.com/rubocop/rubocop-rails/pull/868): Support `::` prefixed constants on `Rails/ActionControllerFlashBeforeRender`, `Rails/ActionControllerTestCase`, `Rails/ApplicationController`, `Rails/ApplicationJob`, `Rails/ApplicationMailer`, `Rails/ApplicationRecord`, `Rails/DotSeparatedKeys`, `Rails/DynamicFindBy`, `Rails/FindEach`, `Rails/FreezeTime`, `Rails/HasManyOrHasOneDependent`, `Rails/HelperInstanceVariable`, `Rails/MailerName`, `Rails/MigrationClassName`, `Rails/Output`, `Rails/ReversibleMigrationMethodDefinition`, `Rails/ReversibleMigration`, `Rails/ShortI18n`, `Rails/SkipsModelValidations`, and `Rails/TimeZoneAssignment`. ([@r7kamura][])
* [#865](https://github.com/rubocop/rubocop-rails/pull/865): Support `::Rails` and `::File` on `Rails/FilePath` cop. ([@r7kamura][])

### Changes

* [#862](https://github.com/rubocop/rubocop-rails/pull/862): Ignore if number of arguments does not match on `Rails/DynamicFindBy`. ([@r7kamura][])

## 2.17.2 (2022-10-27)

### Bug fixes

* [#825](https://github.com/rubocop/rubocop-rails/issues/825): Fix a false positive for `Rails/ActionControllerFlashBeforeRender` when using condition before `redirect_to`. ([@koic][])
* [#833](https://github.com/rubocop/rubocop-rails/issues/833): Fix a false positive for `Rails/Pluck` when receiver is not block argument for `[]`. ([@koic][])
* [#834](https://github.com/rubocop/rubocop-rails/issues/834): Fix an error for `Rails/WhereNotWithMultipleConditions` when using `where.not` with empty hash literal. ([@koic][])
* [#833](https://github.com/rubocop/rubocop-rails/issues/833): Fix a false positive for `Rails/Pluck` when using multiple block arguments. ([@koic][])

### Changes

* [#832](https://github.com/rubocop/rubocop-rails/issues/832): Mark `Rails/ActionControllerFlashBeforeRender`, `Rails/ActionControllerTestCase`, and `Rails/RootPathnameMethods` cops as unsafe autocorrection. ([@koic][])

## 2.17.1 (2022-10-25)

### Bug fixes

* [#829](https://github.com/rubocop/rubocop-rails/pull/829): Revert "Extends `Rails/HttpStatus` cop to check `routes.rb`" introduced in 2.17.0. ([@jdufresne][])
* [#831](https://github.com/rubocop/rubocop-rails/pull/831): Fix a false positive for `Rails/Pluck` when using block argument in `[]`. ([@koic][])

## 2.17.0 (2022-10-22)

### New features

* [#547](https://github.com/rubocop/rubocop-rails/pull/547): Add new `Rails/ActionOrder` cop. ([@mollerhoj][])
* [#565](https://github.com/rubocop/rubocop-rails/issues/565): Add cop Rails/WhereNotWithMultipleConditions. ([@niklas-hasselmeyer][])
* [#771](https://github.com/rubocop/rubocop-rails/pull/771): Add new `Rails/IgnoredColumnsAssignment` cop. ([@fsateler][], [@kkitadate][])
* [#790](https://github.com/rubocop/rubocop-rails/issues/790): Make `Style/HashExcept` aware of TargetRubyVersion: 2.x because Rails has `Hash#except`. ([@koic][])

### Bug fixes

* [#786](https://github.com/rubocop/rubocop-rails/issues/786): Fix a false negative for `Rails/ActionControllerTestCase` when extending `ActionController::TestCase` and having a method definition. ([@koic][])
* [#792](https://github.com/rubocop/rubocop-rails/issues/792): Fix a false negative for `Rails/RedundantPresenceValidationOnBelongsTo` when belongs_to at least one block and one hash like `belongs_to :company, -> { where(foo: true) }, inverse_of: :employee`. ([@PedroAugustoRamalhoDuarte][])
* [#781](https://github.com/rubocop/rubocop-rails/issues/781): Make `Rails/DynamicFindBy` aware of `find_by_token_for`. ([@koic][])
* [#809](https://github.com/rubocop/rubocop-rails/issues/809): Fix an error for `Rails/FreezeTime` when using `travel_to` without argument. ([@koic][])
* [#794](https://github.com/rubocop/rubocop-rails/issues/794): Fix an error for `Rails/RedundantReceiverInWithOptions` when calling a method with a receiver in `with_options` without block arguments. ([@koic][])
* [#782](https://github.com/rubocop/rubocop-rails/issues/782): Fix an incorrect autocorrect for `Rails/EagerEvaluationLogMessage` when using `Style/MethodCallWithArgsParentheses`'s autocorrection together. ([@koic][])
* [#776](https://github.com/rubocop/rubocop-rails/issues/776): Fix an incorrect autocorrect for `Rails/Presence` when using arithmetic operation in `else` branch. ([@koic][])
* [#813](https://github.com/rubocop/rubocop-rails/pull/813): Fix errors that occur when unrelated `tag` is investigated by `Rails/ContentTag`. ([@r7kamura][])
* [#808](https://github.com/rubocop/rubocop-rails/issues/808): Fix false positive for `Rails/ActionControllerFlashBeforeRender` when `render` call precedes `flash` call. ([@americodls][])
* [#778](https://github.com/rubocop/rubocop-rails/issues/778): Fix a false positive for `Rails/DynamicFindBy` when using `page.find_by_id` as a Capybara testing API. ([@koic][])
* [#816](https://github.com/rubocop/rubocop-rails/pull/816): Fix an incorrect autocorrect for `Rails/Presence` when a right-hand side of the relational operator. ([@ydah][])

### Changes

* [#779](https://github.com/rubocop/rubocop-rails/issues/779): Add `mail` to `AllowedMethods` of `Style/SymbolProc`. ([@koic][])
* [#796](https://github.com/rubocop/rubocop-rails/issues/796): Add several directories to `Exclude` to prevent slow investigation. ([@koic][])
* [#822](https://github.com/rubocop/rubocop-rails/issues/822): Extends `Rails/HttpStatus` cop to check `routes.rb`. ([@anthony-robin][])
* [#787](https://github.com/rubocop/rubocop-rails/issues/787): Make `Rails/Pluck` aware of all keys. ([@koic][])
* [#800](https://github.com/rubocop/rubocop-rails/issues/800): Make `Rails/TimeZone` aware of timezone UTF offset. ([@inkstak][])

## 2.16.1 (2022-09-17)

### Bug fixes

* [#769](https://github.com/rubocop/rubocop-rails/issues/769): Fix a false positive for `Rails/FreezeTime` when using `travel_to` with an argument of `DateTime.new` with arguments. ([@koic][])
* [#772](https://github.com/rubocop/rubocop-rails/pull/772): Fix a false positive for `Rails/TopLevelHashWithIndifferentAccess` when using `HashWithIndifferentAccess` under namespace module. ([@koic][])
* [#762](https://github.com/rubocop/rubocop-rails/issues/762): Fix an error for `Rails/FreezeTime` when using `travel_to` with an argument of `current` method without receiver. ([@koic][])
* [#764](https://github.com/rubocop/rubocop-rails/issues/764): Fix an incorrect autocorrect for `Rails/FreezeTime` when using `travel_to` with an argument of the current time and proc argument. ([@koic][])
* [#763](https://github.com/rubocop/rubocop-rails/issues/763): Mark `Rails/RootPathnameMethods` as unsafe and fix an incorrect autocorrect when using `Dir.glob`. ([@koic][])

## 2.16.0 (2022-09-09)

### New features

* [#714](https://github.com/rubocop/rubocop-rails/pull/714): Add new `Rails/FreezeTime` cop. ([@ydah][])
* [#744](https://github.com/rubocop/rubocop-rails/pull/744): Add new `Rails/WhereMissing` cop. ([@ydah][])
* [#587](https://github.com/rubocop/rubocop-rails/pull/587): Add new `Rails/RootPathnameMethods` cop. ([@leoarnold][])
* [#752](https://github.com/rubocop/rubocop-rails/pull/752): Add `Rails/TopLevelHashWithIndifferentAccess` cop. ([@r7kamura][])
* [#759](https://github.com/rubocop/rubocop-rails/pull/759): Add new `Rails/ActionControllerFlashBeforeRender` cop. ([@americodls][])
* [#749](https://github.com/rubocop/rubocop-rails/pull/749): Add new `Rails/ActiveSupportOnLoad` cop. ([@bdewater][])
* [#747](https://github.com/rubocop/rubocop-rails/pull/747): Add `Rails/ToSWithArgument` cop. ([@r7kamura][])
* [#746](https://github.com/rubocop/rubocop-rails/pull/746): Enable `ActiveSupportExtensionsEnabled` option by default. ([@koic][])

### Bug fixes

* [#757](https://github.com/rubocop/rubocop-rails/issues/757): Fix a false positive for `Rails/ReflectionClassName` when using Ruby 3.1's hash shorthand syntax. ([@koic][])
* [#741](https://github.com/rubocop/rubocop-rails/pull/741): Fix a bad autocorrection for `errors.details[:name] << value` in Rails/DeprecatedActiveModelErrorsMethods. ([@BrianHawley][])
* [#742](https://github.com/rubocop/rubocop-rails/pull/742): Rails/DeprecatedActiveModelErrorsMethods was missing the deprecated `values`, `to_h`, and `to_xml` methods. ([@BrianHawley][])
* [#740](https://github.com/rubocop/rubocop-rails/pull/740): Fix a NoMethodError on nil for `errors.keys` in a model in Rails/DeprecatedActiveModelErrorsMethods. ([@BrianHawley][])
* [#753](https://github.com/rubocop/rubocop-rails/pull/753): Fix `Rails/CompactBlank` bug when offense is found in block. ([@r7kamura][])
* [#756](https://github.com/rubocop/rubocop-rails/pull/756): Fix incorrect documentation URLs when using `rubocop --show-docs-url`. ([@r7kamura][])
* [#754](https://github.com/rubocop/rubocop-rails/pull/754): Make `Rails/RedundantReceiverInWithOptions` and `Rails/ReversibleMigration` cops aware of numbered block parameter. ([@koic][])

### Changes

* [#750](https://github.com/rubocop/rubocop-rails/pull/750): Deprecate `IgnoredMethods` option in integrate to `AllowedMethods` and `AllowedPatterns` option. ([@koic][])
* [#729](https://github.com/rubocop/rubocop-rails/pull/729): Change the minimum required `rubocop` dependency version to 1.31.0. ([@pirj][])

## 2.15.2 (2022-07-07)

### Bug fixes

* [#712](https://github.com/rubocop/rubocop-rails/issues/712): Fix false negative in `Rails/Delegate` when preceding nested class declares private or protected methods. ([@Darhazer][])
* [#737](https://github.com/rubocop/rubocop-rails/issues/737): Fix a false positive for `Rails/DeprecatedActiveModelErrorsMethods` when using `keys` method with Rails 6.0. ([@koic][])
* [#737](https://github.com/rubocop/rubocop-rails/pull/737): Make `Rails/ExpandedDateRange` aware `beginning_of_week` with an argument. ([@koic][])
* [#731](https://github.com/rubocop/rubocop-rails/issues/731): Fix an incorrect autocorrect for `Rails/StripHeredoc`. ([@kazarin][])

## 2.15.1 (2022-06-26)

### Bug fixes

* [#723](https://github.com/rubocop/rubocop-rails/pull/723): Fix include value in `Rails/AttributeDefaultBlockValue`. ([@kkitadate][])
* [#717](https://github.com/rubocop/rubocop-rails/issues/717): Fix an error for `Rails/DeprecatedActiveModelErrorsMethods` when root receiver is a variable. ([@koic][])
* [#719](https://github.com/rubocop/rubocop-rails/issues/719): Fix a false negative for `Rails/FormattedS` when using safe navigation operator. ([@koic][])
* [#725](https://github.com/rubocop/rubocop-rails/issues/725): Fix an incorrect autocorrect for `Rails/DotSeparatedKeys` when a key starts with dot. ([@koic][])

## 2.15.0 (2022-06-14)

### New features

* [#325](https://github.com/rubocop/rubocop-rails/pull/325): Add new `Rails/DotSeparatedKeys` cop. ([@fatkodima][])
* [#704](https://github.com/rubocop/rubocop-rails/issues/704): Add new `Rails/StripHeredoc` cop. ([@koic][])
* [#691](https://github.com/rubocop/rubocop-rails/pull/691): Add new `Rails/ToFormattedS` cop. ([@koic][])
* [#588](https://github.com/rubocop/rubocop-rails/pull/588): Add new `Rails/RootPublicPath` cop. ([@leoarnold][])
* [#702](https://github.com/rubocop/rubocop-rails/pull/702): Make `keys` method aware of `Rails/DeprecatedActiveModelErrorsMethods` cop. ([@koic][])
* [#688](https://github.com/rubocop/rubocop-rails/pull/688): Support autocorrection for `Rails/DeprecatedActiveModelErrorsMethods`. ([@koic][])

### Bug fixes

* [#696](https://github.com/rubocop/rubocop-rails/pull/696): Fix a false negative for `Rails/TransactionExitStatement` when `return` is used in `rescue`. ([@koic][])
* [#700](https://github.com/rubocop/rubocop-rails/issues/700): Fix a false positive for `Rails/FilePath` when a list of paths separated by colon including Rails.root. ([@tk0miya][])
* [#680](https://github.com/rubocop/rubocop-rails/issues/680): Fix a false positive for `Rails/ReversibleMigrationMethodDefinition` when using an inner class. ([@koic][])
* [#692](https://github.com/rubocop/rubocop-rails/issues/692): Fix an error for `Rails/UnusedIgnoredColumns` when using no tables db/schema.rb. ([@koic][])
* [#707](https://github.com/rubocop/rubocop-rails/issues/707): Fix an error when a variable is passed to has_many or has_one with double splat. ([@nobuyo][])
* [#695](https://github.com/rubocop/rubocop-rails/pull/695): Fixes a false negative where the `in_rescue?` check would bypass situations where the return was inside a transaction but outside of a rescue. ([@dorkrawk][])
* [#703](https://github.com/rubocop/rubocop-rails/pull/703): Fix not autocorrected for `Rails/DuplicateAssociation`. ([@ydah][])
* [#708](https://github.com/rubocop/rubocop-rails/pull/708): Recover Ruby 2.2 code analysis using `TargetRubyVersion: 2.2`. ([@koic][])

### Changes

* [#697](https://github.com/rubocop/rubocop-rails/pull/697): **(Compatibility)** Drop Ruby 2.5 support. ([@koic][])
* [#705](https://github.com/rubocop/rubocop-rails/pull/705): Add mailers to default `filter`/`action` callbacks cops. ([@ojab][])
* [#710](https://github.com/rubocop/rubocop-rails/pull/710): Rails/TransactionExitStatement - Inspect `ActiveRecord::Locking::Pessimistic#with_lock` too, as `#with_lock` opens a transaction. ([@FunnyHector][])

## 2.14.2 (2022-03-18)

### Bug fixes

* [#660](https://github.com/rubocop/rubocop-rails/issues/660): Fix a false positive for `Rails/MigrationClassName` when defining another class. ([@koic][])
* [#664](https://github.com/rubocop/rubocop-rails/issues/664): Fix a false positive for `Rails/MigrationClassName` when `ActiveSupport::Inflector` is applied to the class name and the case is different. ([@koic][])
* [#658](https://github.com/rubocop/rubocop-rails/issues/658): Fix a false positive for `Rails/TransactionExitStatement` when `break` is used in `loop` in transactions. ([@koic][])
* [#666](https://github.com/rubocop/rubocop-rails/pull/666): Fix an error for `Rails/TransactionExitStatement` when transaction block is empty. ([@koic][])
* [#673](https://github.com/rubocop/rubocop-rails/pull/673): Fix a false negative for `Rails/TransactionExitStatement` when `return` or `throw` is used in a block in transactions. ([@Tietew][])
* [#669](https://github.com/rubocop/rubocop-rails/issues/669): Fix a false positive for `Rails/TransactionExitStatement` when `return` is used in `rescue`. ([@koic][])

## 2.14.1 (2022-03-16)

### Bug fixes

* [#656](https://github.com/rubocop/rubocop-rails/issues/656): Ignore gem name in paths for `Rails/MigrationClassName`. ([@sunny][])
* [#657](https://github.com/rubocop/rubocop-rails/pull/657): Only consider migration classes for `Rails/MigrationClassName`. ([@sunny][])

## 2.14.0 (2022-03-15)

### New features

* [#624](https://github.com/rubocop/rubocop-rails/issues/624): Add new `Rails/I18nLocaleTexts` cop. ([@fatkodima][])
* [#326](https://github.com/rubocop/rubocop-rails/pull/326): Add new `Rails/I18nLazyLookup` cop. ([@fatkodima][])
* [#644](https://github.com/rubocop/rubocop-rails/pull/644): Add new `Rails/MigrationClassName` cop. ([@johnny-miyake][])
* [#599](https://github.com/rubocop/rubocop-rails/issues/599): Add new `Rails/DuplicateAssociation` cop. ([@natematykiewicz][])
* [#427](https://github.com/rubocop/rubocop-rails/issues/427): Add `Rails/DuplicateScope` cop. ([@natematykiewicz][])
* [#642](https://github.com/rubocop/rubocop-rails/issues/642): New cop `Rails/TransactionExitStatement` to disallow `return`, `break` and `throw` in transactions. ([@teckwan][])
* [#491](https://github.com/rubocop/rubocop-rails/pull/491): New `Rails/DeprecatedActiveModelErrorsMethods` cop. ([@lulalala][])
* [#638](https://github.com/rubocop/rubocop-rails/pull/638): Add new `Rails/ActionControllerTestCase` cop. ([@gmcgibbon][])
* [#574](https://github.com/rubocop/rubocop-rails/pull/574): Add new `Rails/TableNameAssignment` cop. ([@MaximeDucheneS][])

### Bug fixes

* [#636](https://github.com/rubocop/rubocop-rails/issues/636): Fix a false positive for `Rails/ContentTag` when using `tag` method in config/puma.rb. ([@koic][])
* [#635](https://github.com/rubocop/rubocop-rails/pull/635): Handle `t.remove` with multiple columns in `Rails/BulkChangeTable`. ([@eugeneius][])

### Changes

* [#646](https://github.com/rubocop/rubocop-rails/issues/646): Exclude db/schema.rb and db/[CONFIGURATION_NAMESPACE]_schema.rb by default. ([@koic][])
* [#650](https://github.com/rubocop/rubocop-rails/issues/650): Make `Rails/CompactBlank` aware of `delete_if(&:blank)`. ([@koic][])
* [#631](https://github.com/rubocop/rubocop-rails/pull/631): Update `Rails/Pluck` to be aware of numblocks. ([@sammiya][])

## 2.13.2 (2022-01-15)

### New features

* [#614](https://github.com/rubocop/rubocop-rails/pull/614): Add `IgnoreScopes` config option for `Rails/InverseOf` cop. ([@composerinteralia][])

### Bug fixes

* [#620](https://github.com/rubocop/rubocop-rails/issues/620): Fix a false positive for `Rails/RedundantPresenceValidationOnBelongsTo` using presence with a message. ([@koic][])
* [#626](https://github.com/rubocop/rubocop-rails/issues/626): Fix a false positive for `Rails/CompactBlank` when using the receiver of `blank?` is not a block variable. ([@koic][])
* [#622](https://github.com/rubocop/rubocop-rails/pull/622): Add `month(s)` and `year(s)` to `Rails/DurationArithmetic` cop. ([@agrobbin][])
* [#623](https://github.com/rubocop/rubocop-rails/issues/623): Fix method shadowing check for `Rails/ReadWriteAttribute` cop. ([@nvasilevski][])

### Changes

* [#615](https://github.com/rubocop/rubocop-rails/issues/615): Change `Rails/RedundantPresenceValidationOnBelongsTo` to `SafeAutoCorrect: false`. ([@TonyArra][])
* [#463](https://github.com/rubocop/rubocop-rails/issues/463): Support multiple databases for `ReversibleMigration` and `ReversibleMigrationMethodDefinition` cops. ([@fatkodima][])

## 2.13.1 (2022-01-10)

### Bug fixes

* [#601](https://github.com/rubocop/rubocop-rails/pull/601): Handle ignored_columns from mixins for `Rails/UnusedIgnoredColumns` cop. ([@tachyons][])
* [#603](https://github.com/rubocop/rubocop-rails/issues/603): Fix autocorrection of multiple attributes for `Rails/RedundantPresenceValidationOnBelongsTo` cop. ([@pirj][])
* [#608](https://github.com/rubocop/rubocop-rails/issues/608): Fix autocorrection of strict validation for `Rails/RedundantPresenceValidationOnBelongsTo` cop. ([@pirj][])

### Changes

* [#585](https://github.com/rubocop/rubocop-rails/pull/585): Make `Rails/ReadWriteAttribute` cop aware of shadowing methods. ([@drenmi][])
* [#604](https://github.com/rubocop/rubocop-rails/issues/604): Remove `remove_reference` and `remove_belongs_to` methods from `Rails/ReversibleMigration` cop offenses. ([@TonyArra][])

## 2.13.0 (2021-12-25)

### New features

* [#598](https://github.com/rubocop/rubocop-rails/pull/598): Add new `Rails/CompactBlank` cop. ([@koic][])
* [#586](https://github.com/rubocop/rubocop-rails/pull/586): Add new `Rails/RootJoinChain` cop. ([@leoarnold][])
* [#571](https://github.com/rubocop/rubocop-rails/issues/571): Add `Rails/DurationArithmetic` cop. ([@pirj][])
* [#594](https://github.com/rubocop/rubocop-rails/pull/594): Add `Rails/RedundantPresenceValidationOnBelongsTo` cop. ([@pirj][])
* [#568](https://github.com/rubocop/rubocop-rails/issues/568): Add `Rails/SchemaComment` cop. ([@vitormd][])

### Changes

* [#591](https://github.com/rubocop/rubocop-rails/issues/591): Add `change_column` check to `Rails/ReversibleMigration`. ([@mattmccormick][])
* Add `remove_reference` check to `Rails/ReversibleMigration`. ([@mattmccormick][])
* [#576](https://github.com/rubocop/rubocop-rails/pull/576): Mark `Rails/TimeZone` as unsafe auto-correction from unsafe. ([@koic][])
* [#582](https://github.com/rubocop/rubocop-rails/pull/582): Unmark `AutoCorrect: false` from `Rails/RelativeDateConstant`. ([@koic][])
* [#580](https://github.com/rubocop/rubocop-rails/pull/580): Unmark `AutoCorrect: false` from `Rails/UniqBeforePluck`. ([@koic][])

## 2.12.4 (2021-10-16)

### Bug fixes

* [#573](https://github.com/rubocop/rubocop-rails/pull/573): Fix an error for `Rails/FindEach` when using `where` with no receiver. ([@koic][])

## 2.12.3 (2021-10-06)

### Bug fixes

* [#556](https://github.com/rubocop/rubocop-rails/issues/556): Fix a false positive for `Rails/ContentTag` when using using the `tag` method with 3 or more arguments. ([@koic][])
* [#551](https://github.com/rubocop/rubocop-rails/issues/551): Fix a false positive for `Rails/FindEach` when using `model.errors.where` in Rails 6.1. ([@koic][])
* [#543](https://github.com/rubocop/rubocop-rails/issues/543): Fix an error for `Rails/ContentTag` when `tag` is not a top-level method. ([@koic][])
* [#559](https://github.com/rubocop/rubocop-rails/issues/559): Fix an error for `Rails/RelativeDateConstant` when using multiple assignment. ([@koic][])
* [#553](https://github.com/rubocop/rubocop-rails/pull/553): Fix a false positive for `Rails/ReversibleMigration` when using `t.remove` with `type` option in Rails 6.1. ([@koic][])

### Changes

* [#546](https://github.com/rubocop/rubocop-rails/issues/546): Exclude `app/models` by default for `Rails/ContentTag`. ([@koic][])
* [#570](https://github.com/rubocop/rubocop-rails/pull/570): Make `Rails/CreateTableWithTimestamps` respect `active_storage_variant_records` table of `db/migrate/*_create_active_storage_tables.active_storage.rb` auto-generated by `bin/rails active_storage:install` even if `created_at` is not specified. ([@koic][])

## 2.12.2 (2021-09-11)

### Bug fixes

* [#541](https://github.com/rubocop/rubocop-rails/issues/541): Fix an error for `Rails/HasManyOrHasOneDependent` when using lambda argument and specifying `:dependent` strategy. ([@koic][])

## 2.12.1 (2021-09-10)

### Bug fixes

* [#535](https://github.com/rubocop/rubocop-rails/issues/535): Fix an error for `Rails/HasManyOrHasOneDependent` when using lambda argument and not specifying any options. ([@koic][])

## 2.12.0 (2021-09-09)

### New features

* [#521](https://github.com/rubocop/rubocop-rails/pull/521): Support auto-correction for `Rails/Output`. ([@koic][])
* [#520](https://github.com/rubocop/rubocop-rails/pull/520): Support auto-correction for `Rails/ScopeArgs`. ([@koic][])
* [#524](https://github.com/rubocop/rubocop-rails/pull/524): Add new `Rails/RedundantTravelBack` cop. ([@koic][])

### Bug fixes

* [#528](https://github.com/rubocop/rubocop-rails/issues/528): Fix a false positive for `Rails/HasManyOrHasOneDependent` when specifying `:dependent` strategy with double splat. ([@koic][])
* [#529](https://github.com/rubocop/rubocop-rails/issues/529): Fix a false positive for `Rails/LexicallyScopedActionFilter` when action method is aliased by `alias_method`. ([@koic][])
* [#532](https://github.com/rubocop/rubocop-rails/issues/532): Fix a false positive for `Rails/HttpPositionalArguments` when defining `get` in `Rails.application.routes.draw` block. ([@koic][])

### Changes

* [#260](https://github.com/rubocop/rubocop-rails/issues/260): Change target of `Rails/ContentTag` from `content_tag` method to `tag` method. ([@tabuchi0919][])

## 2.11.3 (2021-07-11)

### Bug fixes

* [#517](https://github.com/rubocop/rubocop-rails/pull/517): Fix an issue for `Rails/UniqueValidationWithoutIndex` when validating uniqueness with a polymorphic scope. ([@theunraveler][])

## 2.11.2 (2021-07-02)

### Bug fixes

* [#515](https://github.com/rubocop/rubocop-rails/issues/515): Fix an error for `Rails/BulkChangeTable` when using Psych 4.0. ([@koic][])
* [#512](https://github.com/rubocop/rubocop-rails/issues/512): Fix a false positive for `Rails/FindBy` when using `take` with arguments. ([@koic][])

## 2.11.1 (2021-06-25)

### Bug fixes

* [#509](https://github.com/rubocop/rubocop-rails/pull/509): Fix an error for `Rails/ReflectionClassName` when using `class_name: to_s`. ([@skryukov][])
* [#510](https://github.com/rubocop/rubocop-rails/pull/510): Fix an error for `Rails/FindBy` when calling `#first` or `#take` on a `Range` object. ([@johnsyweb][])
* [#507](https://github.com/rubocop/rubocop-rails/pull/507): Fix an error for `Rails/FindBy` when calling `take` after block. ([@koic][])
* [#504](https://github.com/rubocop/rubocop-rails/issues/504): Fix a false positive for `Rails/FindBy` when receiver is not an Active Record. ([@nvasilevski][])

## 2.11.0 (2021-06-21)

### New features

* [#486](https://github.com/rubocop/rubocop-rails/issues/486): Add new `Rails/ExpandedDateRange` cop. ([@koic][])
* [#494](https://github.com/rubocop/rubocop-rails/pull/494): Add new `Rails/UnusedIgnoredColumns` cop. ([@pocke][])
* [#490](https://github.com/rubocop/rubocop-rails/issues/490): Make `Rails/HttpStatus` aware of `head` method. ([@koic][])
* [#483](https://github.com/rubocop/rubocop-rails/pull/483): Add new `Rails/EagerEvaluationLogMessage` cop. ([@aesthetikx][])
* [#495](https://github.com/rubocop/rubocop-rails/issues/495): Add new `Rails/I18nLocaleAssignment` cop. ([@koic][])
* [#497](https://github.com/rubocop/rubocop-rails/issues/497): Add new `Rails/AddColumnIndex` cop. ([@dvandersluis][])

### Bug fixes

* [#482](https://github.com/rubocop/rubocop-rails/pull/482): Fix a false positive for `Rails/RelativeDateConstant` when assigning (hashes/arrays/etc)-containing procs to a constant. ([@jdelStrother][])
* [#419](https://github.com/rubocop/rubocop-rails/issues/419): Fix an error for `Rails/UniqueValidationWithoutIndex` when using a unique index and `check_constraint` that has `nil` first argument. ([@koic][])
* [#70](https://github.com/rubocop/rubocop-rails/issues/70): Fix a false positive for `Rails/TimeZone` when setting `EnforcedStyle: strict` and using `Time.current`. ([@koic][])
* [#488](https://github.com/rubocop/rubocop-rails/issues/488): Fix a false positive for `Rails/ReversibleMigrationMethodDefinition` when using cbase migration class. ([@koic][])
* [#500](https://github.com/rubocop/rubocop-rails/issues/500): Fix a false positive for `Rails/DynamicFindBy` when using dynamic finder with hash argument. ([@koic][])

### Changes

* [#288](https://github.com/rubocop/rubocop-rails/issues/288): Add `AllowToTime` option (`true` by default) to `Rails/Date`. ([@koic][])
* [#499](https://github.com/rubocop/rubocop-rails/issues/499): Add `IgnoreWhereFirst` option (`true` by default) to `Rails/FindBy`. ([@koic][])
* [#505](https://github.com/rubocop/rubocop-rails/pull/505): Set disabled by default for `Rails/EnvironmentVariableAccess`. ([@koic][])

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
* [#456](https://github.com/rubocop/rubocop-rails/pull/456): **(Compatibility)** Drop Ruby 2.4 support. ([@koic][])
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

* [#233](https://github.com/rubocop/rubocop-rails/pull/233): **(Compatibility)** Drop support for Ruby 2.3. ([@koic][])
* [#236](https://github.com/rubocop/rubocop-rails/pull/236): **(Compatibility)** Drop support for Rails 4.1 or lower. ([@koic][])
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

* [#74](https://github.com/rubocop/rubocop-rails/pull/74): **(Compatibility)** Drop Rails 3 support. ([@koic][])

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
[@aesthetikx]: https://github.com/aesthetikx
[@nvasilevski]: https://github.com/nvasilevski
[@skryukov]: https://github.com/skryukov
[@johnsyweb]: https://github.com/johnsyweb
[@theunraveler]: https://github.com/theunraveler
[@MaximeDucheneS]: https://github.com/MaximeDucheneS
[@pirj]: https://github.com/pirj
[@vitormd]: https://github.com/vitormd
[@mattmccormick]: https://github.com/mattmccormick
[@leoarnold]: https://github.com/leoarnold
[@TonyArra]: https://github.com/TonyArra
[@tachyons]: https://github.com/tachyons
[@composerinteralia]: https://github.com/composerinteralia
[@agrobbin]: https://github.com/agrobbin
[@teckwan]: https://github.com/teckwan
[@sammiya]: https://github.com/sammiya
[@johnny-miyake]: https://github.com/johnny-miyake
[@natematykiewicz]: https://github.com/natematykiewicz
[@lulalala]: https://github.com/lulalala
[@gmcgibbon]: https://github.com/gmcgibbon
[@FunnyHector]: https://github.com/FunnyHector
[@ojab]: https://github.com/ojab
[@tk0miya]: https://github.com/tk0miya
[@nobuyo]: https://github.com/nobuyo
[@dorkrawk]: https://github.com/dorkrawk
[@ydah]: https://github.com/ydah
[@kkitadate]: https://github.com/kkitadate
[@Darhazer]: https://github.com/Darhazer
[@kazarin]: https://github.com/kazarin
[@BrianHawley]: https://github.com/BrianHawley
[@r7kamura]: https://github.com/r7kamura
[@americodls]: https://github.com/americodls
[@bdewater]: https://github.com/bdewater
[@inkstak]: https://github.com/inkstak
[@PedroAugustoRamalhoDuarte]: https://github.com/PedroAugustoRamalhoDuarte
[@mollerhoj]: https://github.com/mollerhoj
[@niklas-hasselmeyer]: https://github.com/niklas-hasselmeyer
[@fsateler]: https://github.com/fsateler
[@jdufresne]: https://github.com/jdufresne
[@vlad-pisanov]: https://github.com/vlad-pisanov
[@gsamokovarov]: https://github.com/gsamokovarov
[@bensheldon]: https://github.com/bensheldon
[@gurix]: https://github.com/gurix
[@etiennebarrie]: https://github.com/etiennebarrie
[@javierjulio]: https://github.com/javierjulio
[@john-h-k]: https://github.com/john-h-k
[@DRBragg]: https://github.com/DRBragg
[@lucthev]: https://github.com/lucthev
[@tka5]: https://github.com/tka5
[@masato-bkn]: https://github.com/masato-bkn
[@splattael]: https://github.com/splattael
[@samrjenkins]: https://github.com/samrjenkins
[@mjankowski]: https://github.com/mjankowski
[@joergschiller]: https://github.com/joergschiller
[@fastjames]: https://github.com/fastjames
[@nipe0324]: https://github.com/nipe0324
[@marocchino]: https://github.com/marocchino
[@jamiemccarthy]: https://github.com/jamiemccarthy
[@sambostock]: https://github.com/sambostock
[@Dania02525]: https://github.com/Dania02525
[@bquorning]: https://github.com/bquorning
