# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FilePath, :config do
  context 'when EnforcedStyle is `slashes`' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    context 'when using Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.join('app', 'models', 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY
      end
    end

    context 'when using ::Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          ::Rails.root.join('app', 'models', 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY
      end
    end

    context 'when using Rails.root.join in string interpolation of argument' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root.join('a', 'b.png')}"
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
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
      end
    end

    context 'when using ::File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          ::File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
        RUBY
      end
    end

    context 'when using Rails.root.join with slash separated path string' do
      it 'does not register an offense' do
        expect_no_offenses("Rails.root.join('app/models/goober')")
      end
    end

    context 'when using Rails.root called by double quoted string' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/app/models/goober"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string that ends with string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/a/#{b}"
          ^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY
      end
    end

    context 'when concat Rails.root and file separator using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root}/foo/bar"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY
      end
    end

    context 'when concat Rails.root.join and extension using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root.join('tmp', user.id, 'icon')}.png"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to')`.
        RUBY
      end
    end

    context 'Rails.root is used as a method argument' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          foo(bar(File.join(Rails.root, "app", "models")))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path/to').to_s`.
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
  end

  context 'when EnforcedStyle is `arguments`' do
    let(:cop_config) { { 'EnforcedStyle' => 'arguments' } }

    context 'when using Rails.root.join with some path strings' do
      it 'does not register an offense' do
        expect_no_offenses("Rails.root.join('app', 'models', 'user.rb')")
      end
    end

    context 'when using Rails.root.join in string interpolation of argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          'system "rm -rf #{Rails.root.join(\'a\', \'b.png\')}"'
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
      end
    end

    context 'when using Rails.root.join with slash separated path string' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Rails.root.join('app/models/goober')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root}/app/models/goober"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY
      end
    end

    context 'when concat Rails.root and file separator using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          system "rm -rf #{Rails.root}/foo/bar"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY
      end
    end

    context 'when concat Rails.root.join and extension using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          "#{Rails.root.join('tmp', user.id, 'icon')}.png"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
        RUBY
      end
    end

    context 'Rails.root is used as a method argument' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          foo(bar(File.join(Rails.root, "app", "models")))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to').to_s`.
        RUBY
      end
    end

    context 'Rails.root.join used as an argument' do
      it 'registers an offense once' do
        expect_offense(<<~RUBY)
          foo(Rails.root.join('app/models'))
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `Rails.root.join('path', 'to')`.
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
  end
end
