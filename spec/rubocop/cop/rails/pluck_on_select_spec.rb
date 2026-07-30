# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PluckOnSelect, :config do
  let(:cop_config) do
    { 'EnforcedStyle' => enforced_style }
  end

  context 'EnforcedStyle: aggressive' do
    let(:enforced_style) { 'aggressive' }

    it 'registers an offense when using pluck on select' do
      expect_offense(<<~RUBY)
        User.select(:id).pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with string ID' do
      expect_offense(<<~RUBY)
        User.select('id').pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with alias' do
      expect_offense(<<~RUBY)
        User.select('id AS id2').pluck('id2')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with distinct' do
      expect_offense(<<~RUBY)
        User.select('DISTINCT id').pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select higher up in the node' do
      expect_offense(<<~RUBY)
        User.select('id AS id2').distinct.pluck(:id2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with a method filter' do
      expect_offense(<<~RUBY)
        User.select(&:active?).pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with multiple columns' do
      expect_offense(<<~RUBY)
        User.select(:id, :name).pluck(:id, :name)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with intermediate methods' do
      expect_offense(<<~RUBY)
        User.select(:id).where(active: true).pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with complex chaining' do
      expect_offense(<<~RUBY)
        User.joins(:posts).select('users.id').order(created_at: :desc).pluck('users.id')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'does not register an offense when using pluck without select' do
      expect_no_offenses(<<~RUBY)
        User.pluck(:id)
      RUBY
    end

    it 'does not register an offense when using pluck without receiver' do
      expect_no_offenses(<<~RUBY)
        pluck(:id)
      RUBY
    end

    it 'does not register an offense when using select and pluck in separate chains' do
      expect_no_offenses(<<~RUBY)
        users = User.select(:id)
        ids = User.pluck(:id)
      RUBY
    end
  end

  context 'EnforcedStyle: conservative' do
    let(:enforced_style) { 'conservative' }

    it 'registers an offense when using pluck on select' do
      expect_offense(<<~RUBY)
        User.select(:id).pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with string ID' do
      expect_offense(<<~RUBY)
        User.select('id').pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with alias' do
      expect_offense(<<~RUBY)
        User.select('id AS id2').pluck('id2')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with distinct' do
      expect_offense(<<~RUBY)
        User.select('DISTINCT id').pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select higher up in the node' do
      expect_offense(<<~RUBY)
        User.select('id AS id2').distinct.pluck(:id2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with multiple columns' do
      expect_offense(<<~RUBY)
        User.select(:id, :name).pluck(:id, :name)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'registers an offense when using pluck on select with intermediate methods' do
      expect_offense(<<~RUBY)
        User.select(:id).where(active: true).pluck(:id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `.pluck` on `.select`.
      RUBY
    end

    it 'does not register an offense when using pluck on select with a method filter' do
      expect_no_offenses(<<~RUBY)
        User.select(&:active?).pluck(:id)
      RUBY
    end

    it 'does not register an offense when using pluck without select' do
      expect_no_offenses(<<~RUBY)
        User.pluck(:id)
      RUBY
    end

    it 'does not register an offense when using pluck without receiver' do
      expect_no_offenses(<<~RUBY)
        pluck(:id)
      RUBY
    end

    it 'does not register an offense when using select and pluck in separate chains' do
      expect_no_offenses(<<~RUBY)
        users = User.select(:id)
        ids = User.pluck(:id)
      RUBY
    end
  end
end
