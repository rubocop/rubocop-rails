# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RootPathnameMethods, :config do
  {
    Dir: described_class::DIR_METHODS,
    File: described_class::FILE_METHODS,
    FileTest: described_class::FILE_TEST_METHODS,
    FileUtils: described_class::FILE_UTILS_METHODS,
    IO: described_class::FILE_METHODS
  }.each do |receiver, methods|
    methods.each do |method|
      next if method == :glob

      it "registers an offense when using `#{receiver}.#{method}(Rails.public_path)` (if arity exists)" do
        expect_offense(<<~RUBY, receiver: receiver, method: method)
          %{receiver}.%{method}(Rails.public_path)
          ^{receiver}^^{method}^^^^^^^^^^^^^^^^^^^ `Rails.public_path` is a `Pathname` so you can just append `#%{method}`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.public_path.#{method}
        RUBY
      end

      it "registers an offense when using `::#{receiver}.#{method}(::Rails.root.join(...))` (if arity exists)" do
        expect_offense(<<~RUBY, receiver: receiver, method: method)
          ::%{receiver}.%{method}(::Rails.root.join('db', 'schema.rb'))
          ^^^{receiver}^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `::Rails.root` is a `Pathname` so you can just append `#%{method}`.
        RUBY

        expect_correction(<<~RUBY)
          ::Rails.root.join('db', 'schema.rb').#{method}
        RUBY
      end

      it "registers an offense when using `::#{receiver}.#{method}(::Rails.root.join(...), ...)` (if arity exists)" do
        expect_offense(<<~RUBY, receiver: receiver, method: method)
          ::%{receiver}.%{method}(::Rails.root.join('db', 'schema.rb'), 20, 5)
          ^^^{receiver}^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `::Rails.root` is a `Pathname` so you can just append `#%{method}`.
        RUBY

        expect_correction(<<~RUBY)
          ::Rails.root.join('db', 'schema.rb').#{method}(20, 5)
        RUBY
      end
    end
  end

  context 'when using `Dir.glob`' do
    it "registers an offense when using `Dir.glob(Rails.root.join('**/*.rb'))`" do
      expect_offense(<<~RUBY)
        Dir.glob(Rails.root.join('**/*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~RUBY)
        Rails.root.glob('**/*.rb')
      RUBY
    end

    it "registers an offense when using `::Dir.glob(Rails.root.join('**/*.rb'))`" do
      expect_offense(<<~RUBY)
        ::Dir.glob(Rails.root.join('**/*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~RUBY)
        Rails.root.glob('**/*.rb')
      RUBY
    end

    it "registers an offense when using `Dir.glob(Rails.root.join('**/\#{path}/*.rb'))`" do
      expect_offense(<<~'RUBY')
        Dir.glob(Rails.root.join("**/#{path}/*.rb"))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~'RUBY')
        Rails.root.glob("**/#{path}/*.rb")
      RUBY
    end

    it "registers an offense when using `Dir.glob(Rails.root.join('**', '*.rb'))`" do
      expect_offense(<<~RUBY)
        Dir.glob(Rails.root.join('**', '*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~RUBY)
        Rails.root.glob('**/*.rb')
      RUBY
    end

    it "registers an offense when using `Dir.glob(Rails.root.join('**', \"\#{path}\", '*.rb'))`" do
      expect_offense(<<~'RUBY')
        Dir.glob(Rails.root.join('**', "#{path}", '*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~'RUBY')
        Rails.root.glob("**/#{path}/*.rb")
      RUBY
    end
  end

  # This is handled by `Rails/RootJoinChain`
  it 'does not register an offense when using `File.read(Rails.root.join(...).join(...))`' do
    expect_no_offenses(<<~RUBY)
      File.read(Rails.root.join('db').join('schema.rb'))
    RUBY
  end

  # This is handled by `Style/FileRead`
  it 'does not register an offense when using `File.open(Rails.root.join(...)).read`' do
    expect_no_offenses(<<~RUBY)
      File.open(Rails.root.join('db', 'schema.rb')).read
    RUBY
  end

  # This is handled by `Style/FileRead`
  it 'does not register an offense when using `File.open(Rails.root.join(...)).binread`' do
    expect_no_offenses(<<~RUBY)
      File.open(Rails.root.join('db', 'schema.rb')).binread
    RUBY
  end

  # This is handled by `Style/FileWrite`
  it 'does not register an offense when using `File.open(Rails.root.join(...)).write(content)`' do
    expect_no_offenses(<<~RUBY)
      File.open(Rails.root.join('db', 'schema.rb')).write(content)
    RUBY
  end

  # This is handled by `Style/FileWrite`
  it 'does not register an offense when using `File.open(Rails.root.join(...)).binwrite(content)`' do
    expect_no_offenses(<<~RUBY)
      File.open(Rails.root.join('db', 'schema.rb')).binwrite(content)
    RUBY
  end

  it 'registers an offense when using `File.open(Rails.root.join(...), ...)` inside an iterator' do
    expect_offense(<<~RUBY)
      files.map { |file| File.open(Rails.root.join('db', file), 'wb') }
                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#open`.
    RUBY

    expect_correction(<<~RUBY)
      files.map { |file| Rails.root.join('db', file).open('wb') }
    RUBY
  end
end
