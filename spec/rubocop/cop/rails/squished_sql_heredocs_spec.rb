# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SquishedSQLHeredocs, :config do
  context 'with multi line heredoc' do
    it 'registers an offense and corrects it' do
      expect_offense(<<~RUBY)
        <<~SQL
        ^^^^^^ Use `<<~SQL.squish` instead of `<<~SQL`.
          SELECT * FROM posts
            WHERE id = 1
        SQL
      RUBY

      expect_correction(<<~RUBY)
        <<~SQL.squish
          SELECT * FROM posts
            WHERE id = 1
        SQL
      RUBY
    end

    it 'registers an offense and corrects it with comment-like string and identifiers' do
      expect_offense(<<~RUBY)
        <<~SQL
        ^^^^^^ Use `<<~SQL.squish` instead of `<<~SQL`.
          SELECT * FROM posts
            WHERE [--another identifier!] = 1
            AND "-- this is a name, not a comment" = '-- this is a string, not a comment'
        SQL
      RUBY

      expect_correction(<<~RUBY)
        <<~SQL.squish
          SELECT * FROM posts
            WHERE [--another identifier!] = 1
            AND "-- this is a name, not a comment" = '-- this is a string, not a comment'
        SQL
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        <<-SQL.squish
          SELECT * FROM posts
            WHERE id = 1
        SQL
      RUBY
    end

    it 'does not register an offense due to comments' do
      expect_no_offenses(<<~RUBY)
        <<-SQL
          SELECT * FROM posts
            -- This is a comment, so squish can't be used
            WHERE id = 1
        SQL
      RUBY
    end
  end

  context 'with single line heredoc' do
    it 'registers an offense and corrects it' do
      expect_offense(<<~RUBY)
        <<-SQL
        ^^^^^^ Use `<<-SQL.squish` instead of `<<-SQL`.
          SELECT * FROM posts;
        SQL
      RUBY

      expect_correction(<<~RUBY)
        <<-SQL.squish
          SELECT * FROM posts;
        SQL
      RUBY
    end

    it 'registers an offense and corrects it with comment-like string and identifiers' do
      expect_offense(<<~RUBY)
        <<~SQL
        ^^^^^^ Use `<<~SQL.squish` instead of `<<~SQL`.
          SELECT * FROM posts WHERE [--another identifier!] = 1 AND "-- this is a name, not a comment" = '-- this is a string, not a comment';
        SQL
      RUBY

      expect_correction(<<~RUBY)
        <<~SQL.squish
          SELECT * FROM posts WHERE [--another identifier!] = 1 AND "-- this is a name, not a comment" = '-- this is a string, not a comment';
        SQL
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        <<-SQL.squish
          SELECT * FROM posts;
        SQL
      RUBY
    end

    it 'does not register an offense due to comments' do
      expect_no_offenses(<<~RUBY)
        <<-SQL
          -- This is a comment, so squish can't be used
        SQL
      RUBY
    end
  end

  context 'with heredocs as method parameters' do
    it 'registers an offense and corrects it' do
      expect_offense(<<~RUBY)
        execute(<<~SQL, "Post Load")
                ^^^^^^ Use `<<~SQL.squish` instead of `<<~SQL`.
          SELECT * FROM posts
            WHERE post_id = 1
        SQL
      RUBY

      expect_correction(<<~RUBY)
        execute(<<~SQL.squish, "Post Load")
          SELECT * FROM posts
            WHERE post_id = 1
        SQL
      RUBY
    end

    it 'registers an offense and corrects it with comment-like string and identifiers' do
      expect_offense(<<~RUBY)
        execute(<<~SQL, "Post Load")
                ^^^^^^ Use `<<~SQL.squish` instead of `<<~SQL`.
          SELECT * FROM posts
            WHERE [--another identifier!] = 1
            AND "-- this is a name, not a comment" = '-- this is a string, not a comment'
        SQL
      RUBY

      expect_correction(<<~RUBY)
        execute(<<~SQL.squish, "Post Load")
          SELECT * FROM posts
            WHERE [--another identifier!] = 1
            AND "-- this is a name, not a comment" = '-- this is a string, not a comment'
        SQL
      RUBY
    end

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        execute(<<~SQL.squish, "Post Load")
          SELECT * FROM posts
            WHERE post_id = 1
        SQL
      RUBY
    end

    it 'does not register an offense due to comments' do
      expect_no_offenses(<<~RUBY)
        execute(<<-SQL, "Post Load")
          SELECT * FROM posts
          -- This is a comment, so squish can't be used
            WHERE post_id = 1
        SQL
      RUBY
    end
  end
end
