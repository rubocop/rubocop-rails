**Replace this text with a summary of the changes in your PR.
The more detailed you are, the better.**

-----------------

Before submitting the PR make sure the following are checked:

* [ ] The PR relates to _only_ one subject with a clear title and description in grammatically correct, complete sentences.
* [ ] Feature branch is up-to-date with `master` (if not - rebase it).
* [ ] Squashed related commits together.
* [ ] Added tests.
* [ ] Updated documentation.
* [ ] Added an entry (file) to the [changelog folder](https://github.com/rubocop/rubocop-rails/blob/master/changelog/) named `{change_type}_{change_description}.md` if the new code introduces user-observable changes. See [changelog entry format](https://github.com/rubocop/rubocop/blob/master/CONTRIBUTING.md#changelog-entry-format) for details.
* [ ] The build (`bundle exec rake`) passes (be sure to run this locally, since it may produce updated documentation that you will need to commit).
* [ ] Wrote [good commit messages][1].
* [ ] Commit message starts with `[Fix #issue-number]` (if a related issue exists).

If you have created a new cop:

* [ ] The cop has been checked against `real-world-rails`. [Learn how](https://github.com/rubocop/rubocop-rails/blob/master/CONTRIBUTING.md#real-world-rails).
* [ ] Added the new cop to `config/default.yml`.
* [ ] The cop documents examples of good and bad code.
* [ ] The tests assert both that bad code is reported and that good code is not reported.
* [ ] The cop is configured as `Enabled: pending` in `config/default.yml`.
* [ ] Set `VersionAdded` in `default/config.yml` to the next minor version.
* [ ] Consider making a corresponding update to the [Rails Style Guide](https://github.com/rubocop/rails-style-guide).

If you have modified an existing cop's configuration options:

* [ ] Set `VersionChanged` in `config/default.yml` to the next major version.

[1]: https://chris.beams.io/posts/git-commit/
