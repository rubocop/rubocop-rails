# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::I18nLocaleTexts, :config do
  it 'registers an offense when using `validates` with text messages' do
    expect_offense(<<~RUBY)
      validates :email, presence: { message: "must be present" },
                                             ^^^^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
        format: { with: /@/, message: "not an email" },
                                      ^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
        length: { maximum: 64 }
    RUBY
  end

  it 'does not register an offense when using `validates` with localized messages' do
    expect_no_offenses(<<~RUBY)
      validates :email, presence: { message: :email_missing },
        format: { with: /@/, message: I18n.t('email_format') },
        length: { maximum: 64 }
    RUBY
  end

  it 'registers an offense when using `redirect_to` with text flash messages' do
    expect_offense(<<~RUBY)
      redirect_to root_path, notice: "Post created!"
                                     ^^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
    RUBY
  end

  it 'registers an offense when using `redirect_back` with text flash messages' do
    expect_offense(<<~RUBY)
      redirect_back fallback_location: root_path, notice: "Post created!"
                                                          ^^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
    RUBY
  end

  it 'does not register an offense when using `redirect_to` with localized flash messages' do
    expect_no_offenses(<<~RUBY)
      redirect_to root_path, notice: t(".success")
    RUBY
  end

  it 'registers an offense when assigning to `flash` text messages' do
    expect_offense(<<~RUBY)
      flash[:notice] = "Post created!"
                       ^^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
    RUBY
  end

  it 'does not register an offense when assigning to `flash` localized messages' do
    expect_no_offenses(<<~RUBY)
      flash[:notice] = t(".success")
    RUBY
  end

  it 'registers an offense when assigning to `flash.now` text messages' do
    expect_offense(<<~RUBY)
      flash.now[:notice] = "Post created!"
                           ^^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
    RUBY
  end

  it 'does not register an offense when assigning to `flash.now` localized messages' do
    expect_no_offenses(<<~RUBY)
      flash.now[:notice] = t(".success")
    RUBY
  end

  it 'registers an offense when using `mail` with text subject' do
    expect_offense(<<~RUBY)
      mail(to: user.email, subject: "Welcome to My Awesome Site")
                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Move locale texts to the locale files in the `config/locales` directory.
    RUBY
  end

  it 'does not register an offense when using `mail` with localized subject' do
    expect_no_offenses(<<~RUBY)
      mail(to: user.email)
      mail(to: user.email, subject: t("mailers.users.welcome"))
    RUBY
  end
end
