# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::FilePath, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is `slashes`' do
    let(:cop_config) { { 'EnforcedStyle' => 'slashes' } }

    context 'when using Rails.root.join with some path strings' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          Rails.root.join('app', 'models', 'user.rb')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
        RUBY
      end
    end

    context 'when using Rails.root.join in string interpolation of argument' do
      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          system "rm -rf #{Rails.root.join('a', 'b.png')}"
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
        RUBY
      end
    end

    context 'when using string interpolation without Rails.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
        RUBY
      end
    end

    context 'when using File::SEPARATOR string without Rails.root' do
      it 'does not register an offense' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          "#{42}/"
        RUBY
      end
    end

    context 'when using File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
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
        expect_offense(<<-'RUBY'.strip_indent)
          "#{Rails.root}/app/models/goober"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
        RUBY
      end
    end

    context 'when concat Rails.root and file separator ' \
            'using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          system "rm -rf #{Rails.root}/foo/bar"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
        RUBY
      end
    end

    context 'when concat Rails.root.join and extension ' \
            'using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{Rails.root.join('tmp', user.id, 'icon')}.png"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
        RUBY
      end
    end

    context 'Rails.root is used as a method argument' do
      it 'registers an offense once' do
        expect_offense(<<-RUBY.strip_indent)
          foo(bar(File.join(Rails.root, "app", "models")))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path/to')` instead.
        RUBY
      end
    end

    context 'Rails.root.join used as an argument' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo(Rails.root.join('app/models'))
        RUBY
      end
    end

    context 'Rails.root.join with a non-string argument including "/"' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Rails.root.join("tmp", "data", index/3, "data.csv")
        RUBY
      end
    end

    context 'when string contains an interpolation followed by a period' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          puts "test #\{123\}. Hey!"
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is `arguments`' do
    let(:cop_config) { { 'EnforcedStyle' => 'arguments' } }

    context 'when using Rails.root.join with some path strings' do
      it 'does not registers an offense' do
        expect_no_offenses("Rails.root.join('app', 'models', 'user.rb')")
      end
    end

    context 'when using Rails.root.join in string interpolation of argument' do
      it 'does not registers an offense' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          'system "rm -rf #{Rails.root.join(\'a\', \'b.png\')}"'
        RUBY
      end
    end

    context 'when using string interpolation without Rails.root' do
      it 'does not registers an offense' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
        RUBY
      end
    end

    context 'when using File::SEPARATOR string without Rails.root' do
      it 'does not registers an offense' do
        expect_no_offenses(<<-'RUBY'.strip_indent)
          "#{42}/"
        RUBY
      end
    end

    context 'when using File.join with Rails.root' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          File.join(Rails.root, 'app', 'models')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'when using Rails.root.join with slash separated path string' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          Rails.root.join('app/models/goober')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'when using Rails.root called by double quoted string' do
      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{Rails.root}/app/models/goober"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'when concat Rails.root and file separator ' \
            'using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          system "rm -rf #{Rails.root}/foo/bar"
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'when concat Rails.root.join and extension ' \
            'using string interpolation' do
      it 'registers an offense' do
        expect_offense(<<-'RUBY'.strip_indent)
          "#{Rails.root.join('tmp', user.id, 'icon')}.png"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'Rails.root is used as a method argument' do
      it 'registers an offense once' do
        expect_offense(<<-RUBY.strip_indent)
          foo(bar(File.join(Rails.root, "app", "models")))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'Rails.root.join used as an argument' do
      it 'registers an offense once' do
        expect_offense(<<-RUBY.strip_indent)
          foo(Rails.root.join('app/models'))
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please use `Rails.root.join('path', 'to')` instead.
        RUBY
      end
    end

    context 'Rails.root.join with a non-string argument including "/"' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          Rails.root.join("tmp", "data", index/3, "data.csv")
        RUBY
      end
    end

    context 'when string contains an interpolation followed by a period' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          puts "test #\{123\}. Hey!"
        RUBY
      end
    end
  end
end
