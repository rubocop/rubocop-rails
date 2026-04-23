# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MigrationExecute, :config do
  it 'registers an offense and autocorrects `connection.execute` in migrations' do
    expect_offense(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          connection.execute('SELECT 1')
          ^^^^^^^^^^ Use `execute` instead of `connection.execute` in migrations.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          execute('SELECT 1')
        end
      end
    RUBY
  end

  it 'registers an offense and autocorrects `self.connection.execute` in migrations' do
    expect_offense(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          self.connection.execute('SELECT 1')
          ^^^^^^^^^^^^^^^ Use `execute` instead of `connection.execute` in migrations.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          execute('SELECT 1')
        end
      end
    RUBY
  end

  it 'registers an offense and autocorrects `connection&.execute` in migrations' do
    expect_offense(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          connection&.execute('SELECT 1')
          ^^^^^^^^^^ Use `execute` instead of `connection.execute` in migrations.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          execute('SELECT 1')
        end
      end
    RUBY
  end

  it 'does not register an offense for `execute` in migrations' do
    expect_no_offenses(<<~RUBY)
      class AddIndexToUsers < ActiveRecord::Migration[7.0]
        def up
          execute('SELECT 1')
        end
      end
    RUBY
  end

  it 'does not register an offense outside migrations' do
    expect_no_offenses(<<~RUBY)
      class SqlRunner
        def up
          connection.execute('SELECT 1')
        end
      end
    RUBY
  end
end
