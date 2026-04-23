# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::InOrderOf, :config do
  context 'Rails >= 7.0', :rails70 do
    context 'when using Arel.sql with CASE statement' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Post.order(
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
            Arel.sql(
              <<~SQL
                case status
                when 'draft' then 1
                when 'published' then 2
                when 'archived' then 3
                else 4 end
              SQL
            )
          )
        RUBY
      end
    end

    context 'when using Arel.sql with inline CASE statement' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          User.order(Arel.sql("CASE status WHEN 'active' THEN 1 ELSE 2 END"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end
    end

    context 'when using Arel.sql with FIELD function' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Post.order(Arel.sql("FIELD(status, 'draft', 'published', 'archived')"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end
    end

    context 'when using ::Arel.sql with CASE statement' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Post.order(::Arel.sql("case priority when 'high' then 1 else 2 end"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end
    end

    context 'when using Arel.sql without CASE or FIELD' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          User.order(Arel.sql("created_at DESC"))
        RUBY
      end
    end

    context 'when using regular order methods' do
      it 'does not register an offense with symbol' do
        expect_no_offenses(<<~RUBY)
          User.order(:created_at)
        RUBY
      end

      it 'does not register an offense with hash' do
        expect_no_offenses(<<~RUBY)
          User.order(created_at: :desc)
        RUBY
      end

      it 'does not register an offense with string' do
        expect_no_offenses(<<~RUBY)
          User.order('created_at DESC')
        RUBY
      end
    end

    context 'when using in_order_of' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          Post.in_order_of(:status, %w[draft published archived])
        RUBY
      end
    end

    context 'when using Arel.sql with FIELD and string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          TITLES = ['foo', 'bar']
          Post.order(Arel.sql("FIELD(title,'#{TITLES.join(",")}')"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end

      it 'registers an offense with join using single quotes' do
        expect_offense(<<~'RUBY')
          Post.order(Arel.sql("FIELD(status,'#{UNPUBLISHED_STATES.join("','")}')"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end

      it 'registers an offense with exact user pattern' do
        expect_offense(<<~'RUBY')
          TITLES = ['foo', 'bar']
          Post.order(Arel.sql("FIELD(title,'#{TITLES.join("','")}')"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end
    end

    context 'when using Arel.sql with CASE and string interpolation' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY')
          column = 'status'
          User.order(Arel.sql("CASE #{column} WHEN 'active' THEN 1 ELSE 2 END"))
               ^^^^^ Use `in_order_of` for ordering instead of manually constructing SQL.
        RUBY
      end
    end
  end

  context 'Rails <= 6.1', :rails61 do
    it 'does not register an offense for Arel.sql with CASE' do
      expect_no_offenses(<<~RUBY)
        Post.order(Arel.sql("case status when 'draft' then 1 else 2 end"))
      RUBY
    end
  end
end
