# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::RootPathnameMethods, :config do
  {
    Dir: described_class::DIR_NON_PATHNAMES_RETURNED_METHODS,
    File: described_class::FILE_NON_PATHNAME_RETURNED_METHODS,
    FileTest: described_class::FILE_TEST_METHODS,
    FileUtils: described_class::FILE_UTILS_METHODS,
    IO: described_class::FILE_NON_PATHNAME_RETURNED_METHODS
  }.each do |receiver, methods|
    methods.each do |method|
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
        Rails.root.glob('**/*.rb').map(&:to_s)
      RUBY
    end

    it "registers an offense when using `::Dir.glob(Rails.root.join('**/*.rb'))`" do
      expect_offense(<<~RUBY)
        ::Dir.glob(Rails.root.join('**/*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~RUBY)
        Rails.root.glob('**/*.rb').map(&:to_s)
      RUBY
    end

    it "registers an offense when using `Dir.glob(Rails.root.join('**/\#{path}/*.rb'))`" do
      expect_offense(<<~'RUBY')
        Dir.glob(Rails.root.join("**/#{path}/*.rb"))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~'RUBY')
        Rails.root.glob("**/#{path}/*.rb").map(&:to_s)
      RUBY
    end

    it "registers an offense when using `Dir.glob(Rails.root.join('**', '*.rb'))`" do
      expect_offense(<<~RUBY)
        Dir.glob(Rails.root.join('**', '*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~RUBY)
        Rails.root.glob('**/*.rb').map(&:to_s)
      RUBY
    end

    context 'when double-quoted string literals are preferred' do
      let(:other_cops) do
        super().merge('Style/StringLiterals' => { 'EnforcedStyle' => 'double_quotes' })
      end

      it "registers an offense when using `Dir.glob(Rails.root.join('**', '*.rb'))`" do
        expect_offense(<<~RUBY)
          Dir.glob(Rails.root.join('**', '*.rb'))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
        RUBY

        expect_correction(<<~RUBY)
          Rails.root.glob("**/*.rb").map(&:to_s)
        RUBY
      end
    end

    it "registers an offense when using `Dir.glob(Rails.root.join('**', \"\#{path}\", '*.rb'))`" do
      expect_offense(<<~'RUBY')
        Dir.glob(Rails.root.join('**', "#{path}", '*.rb'))
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
      RUBY

      expect_correction(<<~'RUBY')
        Rails.root.glob("**/#{path}/*.rb").map(&:to_s)
      RUBY
    end

    it 'registers an offense when using `Rails.env` argument within `Dir.glob`' do
      expect_offense(<<~RUBY)
        Dir.glob(Rails.root.join("db", "seeds", Rails.env, "*.rb")).sort.each do |file|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#glob`.
          load file
        end
      RUBY

      expect_correction(<<~'RUBY')
        Rails.root.glob("db/seeds/#{Rails.env}/*.rb").map(&:to_s).sort.each do |file|
          load file
        end
      RUBY
    end
  end

  {
    Dir: described_class::DIR_PATHNAMES_RETURNED_METHODS - %i[glob]
  }.each do |receiver, methods|
    methods.each do |method|
      context "when `#{receiver}.#{method}(Rails.root)` is used" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, receiver: receiver, method: method)
            %{receiver}.%{method}(Rails.root)
            ^{receiver}^^{method}^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#%{method}`.
          RUBY

          expect_correction(<<~RUBY)
            Rails.root.#{method}.map(&:to_s)
          RUBY
        end
      end
    end
  end

  {
    File: described_class::FILE_PATHNAME_RETURNED_METHODS,
    IO: described_class::FILE_PATHNAME_RETURNED_METHODS
  }.each do |receiver, methods|
    methods.each do |method|
      context "when `#{receiver}.#{method}(Rails.root)` is used" do
        it 'registers an offense' do
          expect_offense(<<~RUBY, receiver: receiver, method: method)
            %{receiver}.%{method}(Rails.root)
            ^{receiver}^^{method}^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#%{method}`.
          RUBY

          expect_correction(<<~RUBY)
            Rails.root.#{method}.to_s
          RUBY
        end
      end
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

  it 'registers an offense when using `File.open Rails.root.join ...` without parens' do
    expect_offense(<<~RUBY)
      file = File.open Rails.root.join 'docs', 'invoice.pdf'
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Rails.root` is a `Pathname` so you can just append `#open`.
    RUBY

    expect_correction(<<~RUBY)
      file = Rails.root.join('docs', 'invoice.pdf').open
    RUBY
  end
end
