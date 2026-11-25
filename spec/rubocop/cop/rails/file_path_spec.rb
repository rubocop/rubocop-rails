# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FilePath, :config do
  context 'when EnforcedStyle is `slashes`' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    context 'when using Rails.root.parent' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.parent.join("app", "models")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.parent.join("app/models")
        RUBY
      end
    end

    context 'when using Rails.root.dirname' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.dirname.join("config", "initializers")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.dirname.join("config/initializers")
        RUBY
      end
    end

    context 'when using Rails.root.basename' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.basename.join("config", "initializers")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.basename.join("config/initializers")
        RUBY
      end
    end

    context 'when using Rails.application.config.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.application.config.root, "app", "models")
        RUBY

        expect_no_offenses(<<~RUBY)
          File.join(Rails.application.config.root, "app/models")
        RUBY
      end
    end

    context 'when using Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.join('app', 'models', 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app/models/user.rb")
        RUBY
      end
    end

    context 'when using Rails.root.join in string interpolation of argument' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root.join('a', 'b.png')}"
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~'RUBY')
          system "rm -rf #{Rails.root.join("a/b.png")}"
        RUBY
      end
    end

    context 'when using File.join with Rails.root and path starting with `/`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, '/app/models', '/user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app/models/user.rb").to_s
        RUBY
      end
    end

    context 'when using ::Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          ::Rails.root.join('app', 'models', 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~RUBY)
          ::Rails.root.join("app/models/user.rb")
        RUBY
      end
    end

    context 'when using Rails.root.join in string interpolation with nothing after it' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root.join('log/production.log')}"
        RUBY
      end
    end

    context 'when string interpolated `Rails.root` is followed by a message starting with `.`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root}. a message"
        RUBY
      end
    end

    context 'when using string interpolation without Rails.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
        RUBY
      end
    end

    context 'when using File::SEPARATOR string without Rails.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{42}/"
        RUBY
      end
    end

    context 'when using File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app/models").to_s
        RUBY
      end
    end

    context 'when using ::File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          ::File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app/models").to_s
        RUBY
      end
    end

    context 'when using File.join with an array' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          File.join([Rails.root, 'foo'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for nested arrays' do
        expect_offense(<<~RUBY)
          File.join([Rails.root, 'foo', ['bar']])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_no_corrections
      end
    end

    context 'when using Rails.root.join with slash separated path string' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('app/models/goober')
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/app/models/goober"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~'RUBY')
          "#{Rails.root.join("app/models/goober")}"
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string that ends with string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/a/#{b}"
          ^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~'RUBY')
          "#{Rails.root.join("a/#{b}")}"
        RUBY
      end
    end

    context 'when concat Rails.root and file separator using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root}/foo/bar"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~'RUBY')
          system "rm -rf #{Rails.root.join("foo/bar")}"
        RUBY
      end
    end

    context 'when concat Rails.root.join and extension using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root.join('tmp', user.id, 'icon')}.png"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY

        expect_correction(<<~'RUBY')
          "#{Rails.root.join('tmp', user.id, 'icon.png')}"
        RUBY
      end
    end

    context 'Rails.root is used as a method argument' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          foo(bar(File.join(Rails.root, "app", "models")))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          foo(bar(Rails.root.join("app/models").to_s))
        RUBY
      end
    end

    context 'Rails.root.join used as an argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo(Rails.root.join('app/models'))
        RUBY
      end
    end

    context 'Rails.root.join with a non-string argument including "/"' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join("tmp", "data", index/3, "data.csv")
        RUBY
      end
    end

    context 'when string contains an interpolation followed by a period' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          puts "test #{123}. Hey!"
        RUBY
      end
    end

    context 'when concat Rails.root and colon using string interpolation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root}:/foo/bar"
        RUBY
      end
    end

    context 'when interpolation with `Rails.root` contains other operations' do
      it 'does not register an offense for boolean method' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root || '.'}/config"
        RUBY
      end

      it 'does not register an offense for `rescue`' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root rescue '.'}/config"
        RUBY
      end

      it 'does not register an offense for if condition' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root if flag}/app/models"
        RUBY
      end

      it 'does not register an offense for a ternary operator' do
        expect_no_offenses(<<~'RUBY')
          "#{some_condition ? Rails.root : '/tmp'}/app/models"
        RUBY
      end
    end

    context 'with `join` method with implicit receiver' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          join(Rails.root, path)
        RUBY
      end
    end

    context 'when using only [] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, ['app', 'models'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*['app', 'models']).to_s
        RUBY
      end
    end

    context 'with a leading string and an array using [] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, "app", ["models", "goober"])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", *["models", "goober"]).to_s
        RUBY
      end
    end

    context 'with an array using [] syntax and a trailing string' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, ["app", "models"], "goober")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*["app", "models"], "goober").to_s
        RUBY
      end
    end

    context 'when using only %w[] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, %w[app models])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*%w[app models]).to_s
        RUBY
      end
    end

    context 'with a leading string and an array using %w[] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, "app", %w[models goober])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", *%w[models goober]).to_s
        RUBY
      end
    end

    context 'with an array using %w[] syntax and a trailing string' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, %w[app models], "goober")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*%w[app models], "goober").to_s
        RUBY
      end
    end

    context 'when using File.join with a local variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          default_path = '/models'
          File.join(Rails.root, 'app', default_path)
        RUBY
      end
    end

    context 'when using File.join with an instance variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.root, 'app', @default_path)
        RUBY
      end
    end

    context 'when using File.join with a class variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.root, 'app', @@default_path)
        RUBY
      end
    end

    context 'when using File.join with a global variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.root, 'app', $default_path)
        RUBY
      end
    end

    context 'when using File.join with a constant' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.root, 'app', DEFAULT_PATH)
        RUBY
      end
    end

    context 'when using Rails.root.join with a local variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          default_path = '/models'
          Rails.root.join(Rails.root, 'app', default_path)
        RUBY
      end
    end

    context 'when using Rails.root.join with an instance variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join(Rails.root, 'app', @default_path)
        RUBY
      end
    end

    context 'when using Rails.root.join with a class variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join(Rails.root, 'app', @@default_path)
        RUBY
      end
    end

    context 'when using Rails.root.join with a global variable' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join(Rails.root, 'app', $default_path)
        RUBY
      end
    end

    context 'when using Rails.root.join with a constant' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join(Rails.root, 'app', DEFAULT_PATH)
        RUBY
      end
    end

    context 'when using Rails.root.join with a leading slash' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('/app/models')
        RUBY
      end
    end

    context 'when using Rails.root.join with mixed leading and normal path strings' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('/app', 'models')
        RUBY
      end
    end

    context 'when using Rails.root.join with mixed normal and leading path strings' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('app', '/models')
        RUBY
      end
    end

    context 'when using Rails.root.join with multiple slashes in a path' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('public//', 'assets')
        RUBY
      end
    end

    context 'when using File.join with multiple slashes in a path' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.root, 'public//', 'assets')
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app', 'models'), 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models'), 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments and path starting with `/`' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models'), '/vehicle' '/car.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/vehicle/car.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with string arguments and .to_s' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app', 'models').to_s, 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments and .to_s' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models').to_s, 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments and path starting with `/` and .to_s' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models').to_s, '/vehicle' '/car.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/vehicle/car.rb').to_s
        RUBY
      end
    end

    context 'when using nested File.join with Rails.root with string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(File.join(Rails.root, 'app', 'models'), 'user.rb')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end

    context 'when using nested File.join with Rails.root with non-string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(File.join(Rails.root, 'app/models'), 'user.rb')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end

    context 'when using nested File.join with Rails.root with non-string arguments and path starting with `/`' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(File.join(Rails.root, '/app/models'), '/user.rb')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app/models/user.rb').to_s
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is `arguments`' do
    let(:cop_config) { { 'EnforcedStyle' => 'arguments' } }

    context 'when using Rails.root.parent' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.parent.join("app/models")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.parent.join("app", "models")
        RUBY
      end
    end

    context 'when using Rails.root.dirname' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.dirname.join("config/initializers")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.dirname.join("config", "initializers")
        RUBY
      end
    end

    context 'when using Rails.root.basename' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.basename.join("config/initializers")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.basename.join("config", "initializers")
        RUBY
      end
    end

    context 'when using Rails.application.config.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.application.config.root, "app", "models")
        RUBY

        expect_no_offenses(<<~RUBY)
          File.join(Rails.application.config.root, "app/models")
        RUBY
      end
    end

    context 'when using Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.join('app/models/user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', "models", "user.rb")
        RUBY
      end
    end

    context 'when using Rails.root.join in string interpolation of argument' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root.join("a/b.png")}"
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~'RUBY')
          system "rm -rf #{Rails.root.join("a", "b.png")}"
        RUBY
      end
    end

    context 'when using ::Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          ::Rails.root.join("app/models/user.rb")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          ::Rails.root.join("app", "models", "user.rb")
        RUBY
      end
    end

    context 'when using Rails.root.join in string interpolation with nothing after it' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root.join('log', 'production.log')}"
        RUBY
      end
    end

    context 'when string interpolated `Rails.root` is followed by a message starting with `.`' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root}. a message"
        RUBY
      end
    end

    context 'when using string interpolation without Rails.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
        RUBY
      end
    end

    context 'when using File::SEPARATOR string without Rails.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{42}/"
        RUBY
      end
    end

    context 'when using File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", "models").to_s
        RUBY
      end
    end

    context 'when using File.join with Rails.root and path starting with `/`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, '/app/models', '/user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", "models", "user.rb").to_s
        RUBY
      end
    end

    context 'when using ::File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          ::File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", "models").to_s
        RUBY
      end
    end

    context 'when using File.join with an array' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          File.join([Rails.root, 'foo'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for nested arrays' do
        expect_offense(<<~RUBY)
          File.join([Rails.root, 'foo', ['bar']])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_no_corrections
      end
    end

    context 'when using Rails.root.join with slash separated path string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.join('app/models/goober')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', "models", "goober")
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/app/models/goober"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~'RUBY')
          "#{Rails.root.join("app", "models", "goober")}"
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string that ends with string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/a/#{b}"
          ^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~'RUBY')
          "#{Rails.root.join("a/#{b}")}"
        RUBY
      end
    end

    context 'when concat Rails.root and file separator using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root}/foo/bar"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~'RUBY')
          system "rm -rf #{Rails.root.join("foo", "bar")}"
        RUBY
      end
    end

    context 'when concat Rails.root.join and extension using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root.join('tmp', user.id, 'icon')}.png"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~'RUBY')
          "#{Rails.root.join('tmp', user.id, 'icon.png')}"
        RUBY
      end
    end

    context 'Rails.root is used as a method argument' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          foo(bar(File.join(Rails.root, "app", "models")))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          foo(bar(Rails.root.join("app", "models").to_s))
        RUBY
      end
    end

    context 'Rails.root.join used as an argument' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          foo(Rails.root.join("app/models"))
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY

        expect_correction(<<~RUBY)
          foo(Rails.root.join("app", "models"))
        RUBY
      end
    end

    context 'Rails.root.join with a non-string argument including "/"' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join("tmp", "data", index/3, "data.csv")
        RUBY
      end
    end

    context 'when string contains an interpolation followed by a period' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          puts "test #{123}. Hey!"
        RUBY
      end
    end

    context 'when concat Rails.root and colon using string interpolation' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root}:/foo/bar"
        RUBY
      end
    end

    context 'when interpolation with `Rails.root` contains other operations' do
      it 'does not register an offense for boolean method' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root || '.'}/config"
        RUBY
      end

      it 'does not register an offense for `rescue`' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root rescue '.'}/config"
        RUBY
      end

      it 'does not register an offense for if condition' do
        expect_no_offenses(<<~'RUBY')
          "#{Rails.root if flag}/app/models"
        RUBY
      end

      it 'does not register an offense for a ternary operator' do
        expect_no_offenses(<<~'RUBY')
          "#{some_condition ? Rails.root : '/tmp'}/app/models"
        RUBY
      end
    end

    context 'with `join` method with implicit receiver' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          join(Rails.root, path)
        RUBY
      end
    end

    context 'when using only [] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, ['app', 'models'])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*['app', 'models']).to_s
        RUBY
      end
    end

    context 'with a leading string and an array using [] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, "app", ["models", "goober"])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", *["models", "goober"]).to_s
        RUBY
      end
    end

    context 'with an array using [] syntax and a trailing string' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, ["app", "models"], "goober")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*["app", "models"], "goober").to_s
        RUBY
      end
    end

    context 'when using only %w[] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, %w[app models])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*%w[app models]).to_s
        RUBY
      end
    end

    context 'with a leading string and an array using %w[] syntax' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, "app", %w[models goober])
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", *%w[models goober]).to_s
        RUBY
      end
    end

    context 'with an array using %w[] syntax and a trailing string' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root, %w[app models], "goober")
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join(*%w[app models], "goober").to_s
        RUBY
      end
    end

    context 'when using Rails.root.join with a leading slash' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('/app/models')
        RUBY
      end
    end

    context 'when using Rails.root.join with mixed leading and normal path strings' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('/app', 'models')
        RUBY
      end
    end

    context 'when using Rails.root.join with mixed normal and leading path strings' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('app', '/models')
        RUBY
      end
    end

    context 'when using Rails.root.join with multiple slashes in a path' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Rails.root.join('public//', 'assets')
        RUBY
      end
    end

    context 'when using File.join with multiple slashes in a path' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          File.join(Rails.root, 'public//', 'assets')
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app', 'models'), 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', 'models', 'user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models'), 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', "models", 'user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments and path starting with `/`' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models'), '/vehicle' '/car.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', "models", 'vehicle', 'car.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with string arguments and .to_s' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app', 'models').to_s, 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', 'models', 'user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments and .to_s' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models').to_s, 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', "models", 'user.rb').to_s
        RUBY
      end
    end

    context 'when File.join wraps Rails.root.join with non-string arguments and path starting with `/` and .to_s' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(Rails.root.join('app/models').to_s, '/vehicle' '/car.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join('app', "models", 'vehicle', 'car.rb').to_s
        RUBY
      end
    end

    context 'when using nested File.join with Rails.root with string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(File.join(Rails.root, 'app', 'models'), 'user.rb')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", "models", 'user.rb').to_s
        RUBY
      end
    end

    context 'when using nested File.join with Rails.root with non-string arguments' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(File.join(Rails.root, 'app/models'), 'user.rb')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", "models", 'user.rb').to_s
        RUBY
      end
    end

    context 'when using nested File.join with Rails.root with non-string arguments and path starting with `/`' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          File.join(File.join(Rails.root, '/app/models'), '/user.rb')
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.join("app", "models", 'user.rb').to_s
        RUBY
      end
    end
  end
end
