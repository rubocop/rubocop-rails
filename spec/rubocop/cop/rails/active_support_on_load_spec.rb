# frozen_string_literal: true

RSpec.describe(RuboCop::Cop::Rails::ActiveSupportOnLoad, :config) do
  it 'adds offense and corrects when trying to extend a framework class with include' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.include(MyClass)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record) { include MyClass }` instead of `ActiveRecord::Base.include(MyClass)`.
    RUBY

    expect_correction(<<~RUBY)
      ActiveSupport.on_load(:active_record) { include MyClass }
    RUBY
  end

  it 'does not add offense for include without arguments' do
    expect_no_offenses(<<~RUBY)
      ActiveRecord::Base.include
    RUBY
  end

  it 'adds offense and corrects when trying to extend a framework class with prepend' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.prepend(MyClass)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record) { prepend MyClass }` instead of `ActiveRecord::Base.prepend(MyClass)`.
    RUBY

    expect_correction(<<~RUBY)
      ActiveSupport.on_load(:active_record) { prepend MyClass }
    RUBY
  end

  it 'adds offense and corrects when trying to extend a framework class with extend' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.extend(MyClass)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record) { extend MyClass }` instead of `ActiveRecord::Base.extend(MyClass)`.
    RUBY

    expect_correction(<<~RUBY)
      ActiveSupport.on_load(:active_record) { extend MyClass }
    RUBY
  end

  it 'adds offense and corrects when trying to extend a framework class with absolute name' do
    expect_offense(<<~RUBY)
      ::ActiveRecord::Base.extend(MyClass)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record) { extend MyClass }` instead of `::ActiveRecord::Base.extend(MyClass)`.
    RUBY

    expect_correction(<<~RUBY)
      ActiveSupport.on_load(:active_record) { extend MyClass }
    RUBY
  end

  it 'adds offense and corrects when trying to extend a framework class with a variable' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.extend(my_class)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record) { extend my_class }` instead of `ActiveRecord::Base.extend(my_class)`.
    RUBY

    expect_correction(<<~RUBY)
      ActiveSupport.on_load(:active_record) { extend my_class }
    RUBY
  end

  it 'does not add offense when extending a variable' do
    expect_no_offenses(<<~RUBY)
      foo.extend(MyClass)
    RUBY
  end

  it 'does not add offense when extending the framework using on_load and include' do
    expect_no_offenses(<<~RUBY)
      ActiveSupport.on_load(:active_record) { include MyClass }
    RUBY
  end

  it 'does not add offense when extending the framework using on_load and include in a multi-line block' do
    expect_no_offenses(<<~RUBY)
      ActiveSupport.on_load(:active_record) do
        include MyClass
      end
    RUBY
  end

  it 'does not add offense when there is no extension on the supported classes' do
    expect_no_offenses(<<~RUBY)
      ActiveRecord::Base.include_root_in_json = false
    RUBY
  end

  it 'does not add offense when using include?' do
    expect_no_offenses(<<~RUBY)
      name.include?('bob')
    RUBY
  end

  it 'does not add offense on unsupported classes' do
    expect_no_offenses(<<~RUBY)
      MyClass1.prepend(MyClass)
    RUBY
  end

  context 'Rails 5.2', :rails52 do
    it 'registers an offense for a Rails 5.2 load hook' do
      expect_offense(<<~RUBY)
        ActiveRecord::ConnectionAdapters::SQLite3Adapter.include(MyClass)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record_sqlite3adapter) { include MyClass }` [...]
      RUBY

      expect_correction(<<~RUBY)
        ActiveSupport.on_load(:active_record_sqlite3adapter) { include MyClass }
      RUBY
    end

    it 'registers no offense for a Rails 7.1 load hook' do
      expect_no_offenses(<<~RUBY)
        ActiveRecord::TestFixtures.include(MyClass)
      RUBY
    end
  end

  context 'Rails 7.1', :rails71 do
    it 'registers an offense for a Rails 5.2 load hook' do
      expect_offense(<<~RUBY)
        ActiveRecord::ConnectionAdapters::SQLite3Adapter.include(MyClass)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record_sqlite3adapter) { include MyClass }` [...]
      RUBY

      expect_correction(<<~RUBY)
        ActiveSupport.on_load(:active_record_sqlite3adapter) { include MyClass }
      RUBY
    end

    it 'registers an offense for a Rails 7.1 load hook' do
      expect_offense(<<~RUBY)
        ActiveRecord::TestFixtures.include(MyClass)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `ActiveSupport.on_load(:active_record_fixtures) { include MyClass }` [...]
      RUBY

      expect_correction(<<~RUBY)
        ActiveSupport.on_load(:active_record_fixtures) { include MyClass }
      RUBY
    end
  end
end
