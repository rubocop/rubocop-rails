# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SkipsModelValidations, :config do
  cop_config = {
    'ForbiddenMethods' => %w[decrement!
                             decrement_counter
                             increment!
                             increment_counter
                             insert
                             insert!
                             insert_all
                             insert_all!
                             toggle!
                             touch
                             touch_all
                             update_all
                             update_attribute
                             update_column
                             update_columns
                             update_counters
                             upsert
                             upsert_all]
  }

  let(:msg) { 'Avoid using `%s` because it skips validations.' }
  let(:cop_config) { cop_config }

  methods_with_arguments = described_class::METHODS_WITH_ARGUMENTS

  context 'with default forbidden methods' do
    cop_config['ForbiddenMethods'].each do |method_name|
      it "registers an offense for `#{method_name}`" do
        expect_offense(<<~RUBY, method_name: method_name)
          User.#{method_name}(:attr)
               ^{method_name} #{format(msg, method_name)}
        RUBY
      end
    end

    it 'accepts FileUtils.touch' do
      expect_no_offenses("FileUtils.touch('file')")
    end

    it 'accepts ::FileUtils.touch' do
      expect_no_offenses("::FileUtils.touch('file')")
    end

    it 'accepts touch with literal true' do
      expect_no_offenses('belongs_to(:user).touch(true)')
    end

    it 'accepts touch with literal false' do
      expect_no_offenses('belongs_to(:user).touch(false)')
    end

    %w[insert insert!].each do |method|
      it "does not register an offense for #{method} that looks like String#insert" do
        expect_no_offenses(<<~RUBY)
          string.#{method}(0, 'b')
        RUBY
      end

      it "does not register an offense for #{method} that looks like Array#insert" do
        expect_no_offenses(<<~RUBY)
          array.#{method}(1, :a, :b)
        RUBY
      end

      # FIXME: `undefined method `[]' for nil` occurs Prism 0.24.0. It has been resolved in
      # the development line. This will be resolved in Prism > 0.24.0 and higher releases.
      it "registers an offense for #{method} with `:returning` keyword argument", broken_on: :prism do
        expect_offense(<<~RUBY, method: method)
          %{method}(attributes, returning: false)
          ^{method} Avoid using `#{method}` because it skips validations.
        RUBY
      end

      # FIXME: `undefined method `[]' for nil` occurs Prism 0.24.0. It has been resolved in
      # the development line. This will be resolved in Prism > 0.24.0 and higher releases.
      it "registers an offense for #{method} with `:unique_by` keyword argument", broken_on: :prism do
        expect_offense(<<~RUBY, method: method)
          %{method}(attributes, unique_by: :username)
          ^{method} Avoid using `#{method}` because it skips validations.
        RUBY
      end

      # FIXME: `undefined method `[]' for nil` occurs Prism 0.24.0. It has been resolved in
      # the development line. This will be resolved in Prism > 0.24.0 and higher releases.
      it "registers an offense for #{method} with both `:returning` and `:unique_by` keyword arguments", broken_on: :prism do # rubocop:disable Layout/LineLength
        expect_offense(<<~RUBY, method: method)
          %{method}(attributes, returning: false, unique_by: :username)
          ^{method} Avoid using `#{method}` because it skips validations.
        RUBY
      end

      it "does not register an offense for #{method} with another keyword argument" do
        expect_no_offenses(<<~RUBY)
          insert(attributes, something_else: true)
        RUBY
      end

      it "does not register an offense for #{method} with mixed keyword arguments" do
        expect_no_offenses(<<~RUBY)
          insert(attributes, returning: false, something_else: true)
        RUBY
      end
    end
  end

  context 'with methods that require at least an argument' do
    methods_with_arguments.each do |method_name|
      it "doesn't register an offense for `#{method_name}`" do
        expect_no_offenses("User.#{method_name}")
      end
    end
  end

  context "with methods that don't require an argument" do
    (cop_config['ForbiddenMethods'] - methods_with_arguments).each do |method_name|
      it "registers an offense for `#{method_name}`" do
        expect_offense(<<~RUBY, method_name: method_name)
          User.#{method_name}
               ^{method_name} #{format(msg, method_name)}
        RUBY
      end
    end
  end

  context 'with `update_attribute` method in forbidden methods' do
    let(:cop_config) do
      { 'ForbiddenMethods' => %w[update_attribute] }
    end

    allowed_methods = cop_config['ForbiddenMethods'].reject do |val|
      val == 'update_attribute'
    end

    allowed_methods.each do |method_name|
      it "accepts `#{method_name}`" do
        expect_no_offenses("User.#{method_name}")
      end
    end

    it 'registers an offense for `update_attribute`' do
      expect_offense(<<~RUBY)
        user.update_attribute(:website, 'example.com')
             ^^^^^^^^^^^^^^^^ Avoid using `update_attribute` because it skips validations.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for `update_attribute`' do
        expect_offense(<<~RUBY)
          user&.update_attribute(:website, 'example.com')
                ^^^^^^^^^^^^^^^^ Avoid using `update_attribute` because it skips validations.
        RUBY
      end
    end
  end

  context 'with allowed methods' do
    let(:cop_config) do
      {
        'ForbiddenMethods' => %w[toggle! touch],
        'AllowedMethods' => %w[touch]
      }
    end

    it 'registers an offense for method not in allowed methods' do
      expect_offense(<<~RUBY)
        user.toggle!(:active)
             ^^^^^^^ Avoid using `toggle!` because it skips validations.
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers an offense for method not in allowed methods' do
        expect_offense(<<~RUBY)
          user&.toggle!(:active)
                ^^^^^^^ Avoid using `toggle!` because it skips validations.
        RUBY
      end
    end

    it 'accepts method in allowed methods, superseding the forbidden methods' do
      expect_no_offenses('User.touch(:attr)')
    end
  end

  context 'with obsolete Blacklist configuration' do
    let(:cop_config) do
      {
        'Blacklist' => %w[toggle! touch]
      }
    end

    it 'warns about renamed forbidden methods' do
      expect do
        expect_offense(<<~RUBY)
          user&.toggle!(:active)
                ^^^^^^^ Avoid using `toggle!` because it skips validations.
        RUBY
      end.to output("`Blacklist` has been renamed to `ForbiddenMethods`.\n").to_stderr
    end
  end

  context 'with obsolete Whitelist configuration' do
    let(:cop_config) do
      {
        'Whitelist' => %w[touch]
      }
    end

    it 'warns about renamed allowed methods' do
      expect do
        expect_no_offenses('User.touch(:attr)')
      end.to output("`Whitelist` has been renamed to `AllowedMethods`.\n").to_stderr
    end
  end
end
