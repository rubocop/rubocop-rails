# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::PluralizationGrammar, :config do
  shared_examples 'enforces pluralization grammar' do |method_name|
    context "When #{method_name} is called on an unknown variable" do
      context "when using the plural form ##{method_name}s" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            some_variable.#{method_name}s
          RUBY
        end
      end

      context "when using the singular form ##{method_name}" do
        let(:source) { "some_method.#{method_name}" }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            some_method.#{method_name}
          RUBY
        end
      end
    end

    [-1, -1.0, 1, 1.0].each do |singular_literal|
      context "when mis-pluralizing #{method_name} with #{singular_literal}" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, singular_literal: singular_literal, method_name: method_name)
            #{singular_literal}.#{method_name}s.ago
            ^{singular_literal}^^{method_name}^ Prefer `#{singular_literal}.#{method_name}`.
          RUBY

          expect_correction(<<~RUBY)
            #{singular_literal}.#{method_name}.ago
          RUBY
        end
      end

      context "when using the singular form ##{method_name}" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            #{singular_literal}.#{method_name}
          RUBY
        end
      end
    end

    context "when #{method_name} is called on any other literal number" do
      [-rand(2..1000),
       -rand(0...1.0),
       0,
       rand(0...1.0),
       rand(2..1000)].each do |plural_number|
        context "when using the plural form ##{method_name}s" do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY)
              #{plural_number}.#{method_name}s
            RUBY
          end
        end

        context "when using the singular form ##{method_name}" do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, plural_number: plural_number, method_name: method_name)
              #{plural_number}.#{method_name}.from_now
              ^{plural_number}^^{method_name} Prefer `#{plural_number}.#{method_name}s`.
            RUBY

            expect_correction(<<~RUBY)
              #{plural_number}.#{method_name}s.from_now
            RUBY
          end
        end
      end
    end
  end

  it_behaves_like 'enforces pluralization grammar', 'second'
  it_behaves_like 'enforces pluralization grammar', 'minute'
  it_behaves_like 'enforces pluralization grammar', 'hour'
  it_behaves_like 'enforces pluralization grammar', 'day'
  it_behaves_like 'enforces pluralization grammar', 'week'
  it_behaves_like 'enforces pluralization grammar', 'fortnight'
  it_behaves_like 'enforces pluralization grammar', 'month'
  it_behaves_like 'enforces pluralization grammar', 'year'
  it_behaves_like 'enforces pluralization grammar', 'byte'
  it_behaves_like 'enforces pluralization grammar', 'kilobyte'
  it_behaves_like 'enforces pluralization grammar', 'megabyte'
  it_behaves_like 'enforces pluralization grammar', 'gigabyte'
  it_behaves_like 'enforces pluralization grammar', 'terabyte'
  it_behaves_like 'enforces pluralization grammar', 'petabyte'
  it_behaves_like 'enforces pluralization grammar', 'exabyte'
  it_behaves_like 'enforces pluralization grammar', 'zettabyte'
end
