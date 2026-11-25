# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SquishedSQLHeredocComments, :config do
  it 'registers an offense for a `--` comment followed by more SQL' do
    expect_offense(<<~RUBY)
      execute(<<~SQL.squish)
              ^^^^^^ Use `/* */` instead of `--` in a squished SQL heredoc. `.squish` joins the lines, so `--` comments out the rest of the query.
        DELETE FROM records
        WHERE expired = true -- only expired records
        AND user_id = 1
      SQL
    RUBY
  end

  it 'registers an offense for a `--` comment on its own line' do
    expect_offense(<<~RUBY)
      <<-SQL.squish
      ^^^^^^ Use `/* */` instead of `--` in a squished SQL heredoc. `.squish` joins the lines, so `--` comments out the rest of the query.
        -- most recent first
        SELECT * FROM posts
        ORDER BY created_at DESC
      SQL
    RUBY
  end

  it 'registers an offense for a `--` comment in a heredoc with interpolation' do
    expect_offense(<<~'RUBY')
      <<~SQL.squish
      ^^^^^^ Use `/* */` instead of `--` in a squished SQL heredoc. `.squish` joins the lines, so `--` comments out the rest of the query.
        SELECT * FROM #{table} -- any table
        WHERE id = 1
      SQL
    RUBY
  end

  it 'does not register an offense for a `--` comment on the last line' do
    expect_no_offenses(<<~RUBY)
      <<~SQL.squish
        SELECT * FROM posts
        WHERE id = 1 -- by primary key
      SQL
    RUBY
  end

  it 'does not register an offense for a `/* */` comment' do
    expect_no_offenses(<<~RUBY)
      <<~SQL.squish
        SELECT * FROM posts /* all of them */
        WHERE id = 1
      SQL
    RUBY
  end

  it 'does not register an offense for `--` inside strings and identifiers' do
    expect_no_offenses(<<~RUBY)
      <<~SQL.squish
        SELECT * FROM posts
          WHERE [--another identifier!] = 1
          AND "-- this is a name, not a comment" = '-- this is a string, not a comment'
          AND id = 1
      SQL
    RUBY
  end

  it 'does not register an offense when the heredoc is not squished' do
    expect_no_offenses(<<~RUBY)
      <<~SQL
        SELECT * FROM posts -- all of them
        WHERE id = 1
      SQL
    RUBY
  end

  it 'does not register an offense for a non-SQL heredoc' do
    expect_no_offenses(<<~RUBY)
      <<~TEXT.squish
        Some text -- with dashes
        on two lines
      TEXT
    RUBY
  end
end
