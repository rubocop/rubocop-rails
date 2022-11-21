* [#871](https://github.com/rubocop/rubocop-rails/pull/871): Fix a false positive for `Rails/WhereMissing` when `left_joins(:foo)` and `where(foos: {id: nil})` separated by `or`, `and`. ([@ydah][])
