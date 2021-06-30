# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SetIgnoredColumns, :config do
  it 'registers an offense when using `ignored_columns` once' do
    expect_offense(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns = [:one]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This assignment to `ignored_columns` may overwrite previous ones.
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns += [:one]
      end
    RUBY
  end

  it 'registers an offense when setting `ignored_columns` twice' do
    expect_offense(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns = [:one]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This assignment to `ignored_columns` may overwrite previous ones.
        self.ignored_columns = [:two]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This assignment to `ignored_columns` may overwrite previous ones.
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns += [:one]
        self.ignored_columns += [:two]
      end
    RUBY
  end

  it 'registers an offense when setting `ignored_columns` after appending' do
    expect_offense(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns += [:one]
        self.ignored_columns = [:two]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This assignment to `ignored_columns` may overwrite previous ones.
      end
    RUBY

    expect_correction(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns += [:one]
        self.ignored_columns += [:two]
      end
    RUBY
  end

  it 'does not register an offense when appending to `ignored_columns` and then appending' do
    expect_no_offenses(<<~RUBY)
      class User < ActiveRecord::Base
        self.ignored_columns += [:one]
        self.ignored_columns += [:two]
      end
    RUBY
  end
end
