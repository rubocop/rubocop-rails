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
