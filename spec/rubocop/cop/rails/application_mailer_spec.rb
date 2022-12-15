# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ApplicationMailer, :config do
  context 'Rails 4.2', :rails42 do
    it 'allows `ApplicationMailer` to be defined' do
      expect_no_offenses(<<~RUBY)
        class ApplicationMailer < ActionMailer::Base; end
      RUBY
    end

    it 'allows `ApplicationMailer` to be defined using Class.new' do
      expect_no_offenses(<<~RUBY)
        ApplicationMailer = Class.new(ActionMailer::Base)
      RUBY
    end

    it 'allows mailers that subclass `ActionMailer::Base`' do
      expect_no_offenses(<<~RUBY)
        class MyMailer < ActionMailer::Base; end
      RUBY
    end

    it 'allows mailers defined in module namespaces' do
      expect_no_offenses(<<~RUBY)
        module Nested
          class MyMailer < ActionMailer::Base; end
        end
      RUBY
    end

    it 'allows mailers defined in inline namespaces' do
      expect_no_offenses(<<~RUBY)
        class Nested::MyMailer < ActionMailer::Base; end
      RUBY
    end

    it 'allows mailers defined using Class.new' do
      expect_no_offenses(<<~RUBY)
        MyMailer = Class.new(ActionMailer::Base)
      RUBY
    end

    it 'allows nested mailers defined using Class.new' do
      expect_no_offenses(<<~RUBY)
        Nested::MyMailer = Class.new(ActionMailer::Base)
      RUBY
    end

    it 'allows anonymous mailers' do
      expect_no_offenses(<<~RUBY)
        Class.new(ActionMailer::Base) {}
      RUBY
    end
  end

  context 'Rails 5.0', :rails50 do
    it 'allows `ApplicationMailer` to be defined' do
      expect_no_offenses(<<~RUBY)
        class ApplicationMailer < ActionMailer::Base; end
      RUBY
    end

    it 'allows `ApplicationMailer` to be defined using Class.new' do
      expect_no_offenses(<<~RUBY)
        ApplicationMailer = Class.new(ActionMailer::Base)
      RUBY
    end

    it 'corrects mailers that subclass `ActionMailer::Base`' do
      expect_offense(<<~RUBY)
        class MyMailer < ActionMailer::Base; end
                         ^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
      RUBY

      expect_correction(<<~RUBY)
        class MyMailer < ApplicationMailer; end
      RUBY
    end

    it 'corrects mailers that subclass `::ActionMailer::Base`' do
      expect_offense(<<~RUBY)
        class MyMailer < ::ActionMailer::Base; end
                         ^^^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
      RUBY

      expect_correction(<<~RUBY)
        class MyMailer < ApplicationMailer; end
      RUBY
    end

    it 'corrects mailers defined in module namespaces' do
      expect_offense(<<~RUBY)
        module Nested
          class MyMailer < ActionMailer::Base; end
                           ^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Nested
          class MyMailer < ApplicationMailer; end
        end
      RUBY
    end

    it 'corrects mailers defined in inline namespaces' do
      expect_offense(<<~RUBY)
        class Nested::MyMailer < ActionMailer::Base; end
                                 ^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
      RUBY

      expect_correction(<<~RUBY)
        class Nested::MyMailer < ApplicationMailer; end
      RUBY
    end

    it 'corrects mailers defined using Class.new' do
      expect_offense(<<~RUBY)
        MyMailer = Class.new(ActionMailer::Base)
                             ^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
      RUBY

      expect_correction(<<~RUBY)
        MyMailer = Class.new(ApplicationMailer)
      RUBY
    end

    it 'corrects nested mailers defined using Class.new' do
      expect_offense(<<~RUBY)
        Nested::MyMailer = Class.new(ActionMailer::Base)
                                     ^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
      RUBY

      expect_correction(<<~RUBY)
        Nested::MyMailer = Class.new(ApplicationMailer)
      RUBY
    end

    it 'corrects anonymous mailers' do
      expect_offense(<<~RUBY)
        Class.new(ActionMailer::Base) {}
                  ^^^^^^^^^^^^^^^^^^ Mailers should subclass `ApplicationMailer`.
      RUBY

      expect_correction(<<~RUBY)
        Class.new(ApplicationMailer) {}
      RUBY
    end
  end
end
