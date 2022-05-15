# Contributing

If you discover issues, have ideas for improvements or new features,
please report them to the [issue tracker][1] of the repository or
submit a pull request. Please, try to follow these guidelines when you
do so.

## Issue reporting

* Check that the issue has not already been reported.
* Check that the issue has not already been fixed in the latest code
  (a.k.a. `master`).
* Be clear, concise and precise in your description of the problem.
* Open an issue with a descriptive title and a summary in grammatically correct,
  complete sentences.
* Consider using [Real World Rails](https://github.com/eliotsykes/real-world-rails) for research or testing.
* Include the output of `rubocop -V`:

```
$ rubocop -V
0.66.0 (using Parser 2.6.2.0, running on ruby 2.6.2 x86_64-linux)
```

* Include any relevant code to the issue summary.

## Pull requests

* Read [how to properly contribute to open source projects on GitHub][2].
* Fork the project.
* Use a topic/feature branch to easily amend a pull request later, if necessary.
* Write [good commit messages][3].
* Use the same coding conventions as the rest of the project.
* Commit and push until you are happy with your contribution.
* If your change has a corresponding open GitHub issue, prefix the commit message with `[Fix #github-issue-number]`.
* Make sure to add tests for it. This is important so I don't break it
  in a future version unintentionally.
* Add an entry to the [Changelog](CHANGELOG.md) by creating a file `changelog/{type}_{some_description}.md`. See [changelog entry format](#changelog-entry-format) for details.
* Please try not to mess with the Rakefile, version, or history. If
  you want to have your own version, or is otherwise necessary, that
  is fine, but please isolate to its own commit so I can cherry-pick
  around it.
* Make sure the test suite is passing and the code you wrote doesn't produce
  RuboCop offenses (usually this is as simple as running `bundle exec rake`).
* [Squash related commits together][5].
* Open a [pull request][4] that relates to *only* one subject with a clear title
  and description in grammatically correct, complete sentences.

### Changelog entry format

Here are a few examples:

```
* [#67](https://github.com/rubocop/rubocop-rails/issues/67): Fix an incorrect autocorrect for `Rails/TimeZone` when using `DateTime`. ([@koic][])
* New cop `ElseLayout` checks for odd arrangement of code in the `else` branch of a conditional expression. ([@bbatsov][])
```

* Create one file `changelog/{type}_{some_description}.md`, where `type` is `new` (New feature), `fix` or `change`, and `some_description` is unique to avoid conflicts. Task `changelog:fix` (or `:new` or `:change`) can help you.
* Mark it up in [Markdown syntax][6].
* The entry line should start with `* ` (an asterisk and a space).
* If the change has a related GitHub issue (e.g. a bug fix for a reported issue), put a link to the issue as `[#123](https://github.com/rubocop/rubocop-rails/issues/123): `.
* Describe the brief of the change. The sentence should end with a punctuation.
* At the end of the entry, add an implicit link to your GitHub user page as `([@username][])`.
* Alternatively, you may modify the CHANGELOG file directly, but this may result in conflicts later on. Also, if this is your first contribution to RuboCop project, add a link definition for the implicit link to the bottom of the changelog as `[@username]: https://github.com/username`.

### Real World Rails

[Real World Rails][7] is a collection of open source Rails application codebases.
When introducing or changing a cop, running against this can help to uncover wide range of potential problems.

Run the following to check out Real World Rails:

```
git clone git@github.com:eliotsykes/real-world-rails.git
cd real-world-rails

# This will take some time...
git submodule update --init --remote --checkout --single-branch --depth 1
```

To avoid problems relating to outdated RuboCop configurations, delete them with:

```
rm -v **/.rubocop.yml
```

Now, you can run:

```
rubocop --only <your-cop-name> <path-to-real-world-rails>
```

Take a close look at the output and make sure that:

* There are no errors
* It doesn't stall or hang

Ideally, the cop should only raise legitimate offenses again Real World Rails.
If there are any false positives, mark the cop as unsafe.

[1]: https://github.com/rubocop/rubocop-rails/issues
[2]: https://www.gun.io/blog/how-to-github-fork-branch-and-pull-request
[3]: https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[4]: https://help.github.com/articles/about-pull-requests
[5]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[6]: https://daringfireball.net/projects/markdown/syntax
[7]: https://github.com/eliotsykes/real-world-rails
