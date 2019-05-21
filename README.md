# RuboCop Rails

[![CircleCI](https://circleci.com/gh/rubocop-hq/rubocop-rails.svg?style=svg)](https://circleci.com/gh/rubocop-hq/rubocop-rails)

A [RuboCop](https://github.com/rubocop-hq/rubocop) extension focused on enforcing Rails best practices and coding conventions.

## Installation

Just install the `rubocop-rails` gem

```sh
gem install rubocop-rails
```

or if you use bundler put this in your `Gemfile`

```ruby
gem 'rubocop-rails'
```

## Usage

You need to tell RuboCop to load the Rails extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-rails
```

Now you can run `rubocop` and it will automatically load the RuboCop Rails
cops together with the standard cops.

### Command line

```sh
rubocop --require rubocop-rails
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rails'
end
```

## The Cops

All cops are located under
[`lib/rubocop/cop/rails`](lib/rubocop/cop/rails), and contain
examples/documentation.

In your `.rubocop.yml`, you may treat the Rails cops just like any other
cop. For example:

```yaml
Rails/FindBy:
  Exclude:
    - lib/example.rb
```

## Contributing

Checkout the [contribution guidelines](CONTRIBUTING.md).

## License

`rubocop-rails` is MIT licensed. [See the accompanying file](LICENSE.txt) for
the full text.
