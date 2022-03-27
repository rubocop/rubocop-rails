# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::MailerPreviews, :config do
  include FileHelper

  let(:cop_config) { { 'PreviewPaths' => 'tmp/mailers/previews' } }

  after { FileUtils.rm_rf('tmp') }

  it 'registers an offense when there is no mailer preview file' do
    expect_offense(<<~RUBY)
      class UserMailer < ApplicationMailer
        def welcome_email
        ^^^^^^^^^^^^^^^^^ Add a mailer preview for `welcome_email`.
        end
      end
    RUBY
  end

  it 'registers an offense when there is no mailer preview method' do
    create_preview(<<~RUBY)
      class UserMailerPreview < ActionMailer::Preview
      end
    RUBY

    expect_offense(<<~RUBY)
      class UserMailer < ApplicationMailer
        def welcome_email
        ^^^^^^^^^^^^^^^^^ Add a mailer preview for `welcome_email`.
        end
      end
    RUBY
  end

  it 'registers an offense when there is a private mailer preview method' do
    create_preview(<<~RUBY)
      class UserMailerPreview < ActionMailer::Preview
        private
        def welcome_email
        end
      end
    RUBY

    expect_offense(<<~RUBY)
      class UserMailer < ApplicationMailer
        def welcome_email
        ^^^^^^^^^^^^^^^^^ Add a mailer preview for `welcome_email`.
        end
      end
    RUBY
  end

  it 'registers an offense when there is no mailer preview in the file' do
    create_preview

    expect_offense(<<~RUBY)
      class UserMailer < ApplicationMailer
        def welcome_email
        ^^^^^^^^^^^^^^^^^ Add a mailer preview for `welcome_email`.
        end
      end
    RUBY
  end

  it 'does not register an offense when there is mailer preview' do
    create_preview(<<~RUBY)
      class UserMailerPreview < ActionMailer::Preview
        def welcome_email
        end
      end
    RUBY

    expect_no_offenses(<<~RUBY)
      class UserMailer < ApplicationMailer
        def welcome_email
        end
      end
    RUBY
  end

  private

  def create_preview(content = '')
    create_file('tmp/mailers/previews/user_mailer_preview.rb', content)
  end
end
