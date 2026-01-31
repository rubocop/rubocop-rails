# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::StrongParametersExpect, :config do
  context 'Rails >= 8.0', :rails80 do
    it 'registers an offense when using `params[:key]` with method call' do
      expect_offense(<<~RUBY)
        params[:key].do_something
              ^^^^^^ Use `expect(:key)` instead.
      RUBY

      expect_correction(<<~RUBY)
        params.expect(:key).do_something
      RUBY
    end

    it 'does not register an offense when using `params[:key]`' do
      expect_no_offenses(<<~RUBY)
        params[:key]
      RUBY
    end

    it 'does not register an offense when using `params[:key].nil?`' do
      expect_no_offenses(<<~RUBY)
        params[:key].nil?
      RUBY
    end

    it "does not register an offense when using `params[:key] == 'value'`" do
      expect_no_offenses(<<~RUBY)
        params[:key] == 'value'
      RUBY
    end

    it 'does not register an offense when using `params[:key].blank?`' do
      expect_no_offenses(<<~RUBY)
        params[:key].blank?
      RUBY
    end

    it 'does not register an offense when using `params[:key].present?`' do
      expect_no_offenses(<<~RUBY)
        params[:key].present?
      RUBY
    end

    it 'registers an offense when using `Model.find(params[:id])`' do
      expect_offense(<<~RUBY)
        Model.find(params[:id])
                         ^^^^^ Use `expect(:id)` instead.
      RUBY

      expect_correction(<<~RUBY)
        Model.find(params.expect(:id))
      RUBY
    end

    it 'registers an offense when using `Model&.find(params[:id])`' do
      expect_offense(<<~RUBY)
        Model&.find(params[:id])
                          ^^^^^ Use `expect(:id)` instead.
      RUBY

      expect_correction(<<~RUBY)
        Model&.find(params.expect(:id))
      RUBY
    end

    it 'does not register an offense when using `Model.find(params[:id]) || DEFAULT_VALUE`' do
      expect_no_offenses(<<~RUBY)
        Model.find(params[:id] || DEFAULT_VALUE)
      RUBY
    end

    it 'does not register an offense when using `Model.find_by(key: params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.find_by(key: params[:key])
      RUBY
    end

    it 'registers an offense when using `Model.find_by!(key: params[:key])`' do
      expect_offense(<<~RUBY)
        Model.find_by!(key: params[:key])
                                  ^^^^^^ Use `expect(:key)` instead.
      RUBY

      expect_correction(<<~RUBY)
        Model.find_by!(key: params.expect(:key))
      RUBY
    end

    it 'does not register an offense when using `Model.find_or_initialize_by(key: params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.find_or_initialize_by(key: params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model&.find_or_initialize_by(key: params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model&.find_or_initialize_by(key: params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.find_or_create_by(key: params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.find_or_create_by(key: params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.find_or_create_by!(key: params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.find_or_create_by!(key: params[:key])
      RUBY
    end

    it 'registers an offense when using `Model.find_sole_by(key: params[:key])`' do
      expect_offense(<<~RUBY)
        Model.find_sole_by(key: params[:key])
                                      ^^^^^^ Use `expect(:key)` instead.
      RUBY

      expect_correction(<<~RUBY)
        Model.find_sole_by(key: params.expect(:key))
      RUBY
    end

    it 'does not register an offense when using `Model.find(non_params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.find(non_params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.findxxx(params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.findxxx(params[:key])
      RUBY
    end

    it 'does not register an offense when using methods that do not start with `find_` such as `Model.where' do
      expect_no_offenses(<<~RUBY)
        Model.where(key: params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.delete(params[:id])`' do
      expect_no_offenses(<<~RUBY)
        Model.delete(params[:id])
      RUBY
    end

    it 'does not register an offense when using `Model.destroy(params[:id])`' do
      expect_no_offenses(<<~RUBY)
        Model.destroy(params[:id])
      RUBY
    end

    it 'does not register an offense when using `Model.delete_by(key: params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.delete_by(key: params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.destroy_by(params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.destroy_by(key: params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.delete_custom_method(params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.delete_custom_method(params[:key])
      RUBY
    end

    it 'does not register an offense when using `Model.destroy_custom_method(params[:key])`' do
      expect_no_offenses(<<~RUBY)
        Model.destroy_custom_method(params[:key])
      RUBY
    end

    it 'registers an offense when using `params.require(:user).permit(:name, :age)`' do
      expect_offense(<<~RUBY)
        params.require(:user).permit(:name, :age)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [:name, :age])` instead.
      RUBY

      expect_correction(<<~RUBY)
        params.expect(user: [:name, :age])
      RUBY
    end

    it 'registers an offense when using `params&.require(:user)&.permit(:name, :age)`' do
      expect_offense(<<~RUBY)
        params&.require(:user)&.permit(:name, :age)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [:name, :age])` instead.
      RUBY

      expect_correction(<<~RUBY)
        params&.expect(user: [:name, :age])
      RUBY
    end

    it 'registers an offense when using `params.permit(user: [:name, :age]).require(:user)`' do
      expect_offense(<<~RUBY)
        params.permit(user: [:name, :age]).require(:user)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [:name, :age])` instead.
      RUBY

      expect_correction(<<~RUBY)
        params.expect(user: [:name, :age])
      RUBY
    end

    it 'registers an offense when using `params&.permit(user: [:name, :age])&.require(:user)`' do
      expect_offense(<<~RUBY)
        params&.permit(user: [:name, :age])&.require(:user)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [:name, :age])` instead.
      RUBY

      expect_correction(<<~RUBY)
        params&.expect(user: [:name, :age])
      RUBY
    end

    it 'registers an offense when using `params.require(:user).permit(:name, some_ids: [])`' do
      expect_offense(<<~RUBY)
        params.require(:user).permit(:name, some_ids: [])
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [:name, some_ids: []])` instead.
      RUBY

      expect_correction(<<~RUBY)
        params.expect(user: [:name, some_ids: []])
      RUBY
    end

    it 'registers an offense when using `params.require(:user).permit(*parameters, some_ids: [])`' do
      expect_offense(<<~RUBY)
        params.require(:user).permit(*parameters, some_ids: [])
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [*parameters, some_ids: []])` instead.
      RUBY

      expect_correction(<<~RUBY)
        params.expect(user: [*parameters, some_ids: []])
      RUBY
    end

    it 'registers an offense when using `params.require(var).permit(:name, some_ids: [])`' do
      expect_offense(<<~RUBY)
        var = :user
        params.require(var).permit(:name, some_ids: [])
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `expect(var => [:name, some_ids: []])` instead.
      RUBY

      expect_correction(<<~RUBY)
        var = :user
        params.expect(var => [:name, some_ids: []])
      RUBY
    end

    it "registers an offense when using `params.require(:user).permit(:name, :age)` and `permit`'s args has comment" do
      expect_offense(<<~RUBY)
        params.require(:user).permit(
               ^^^^^^^^^^^^^^^^^^^^^^ Use `expect(user: [:name, :age])` instead.
          :name, # comment
          :age # comment
        )
      RUBY

      expect_correction(<<~RUBY)
        params.expect(
          user: [:name, # comment
          :age] # comment
        )
      RUBY
    end

    it 'registers an offense when using a leading dot multiline call to `params.require(:user).permit(:name, :age)`' do
      expect_offense(<<~RUBY)
        params
          .require(:user)
           ^^^^^^^^^^^^^^ Use `expect(user: [:name, :age])` instead.
          .permit(:name, :age)
      RUBY

      expect_correction(<<~RUBY)
        params
          .expect(user: [:name, :age])
      RUBY
    end

    it 'does not register an offense when using `params.expect(user: [:name, :age])`' do
      expect_no_offenses(<<~RUBY)
        params.expect(user: [:name, :age])
      RUBY
    end

    it 'does not register an offense when using `params.permit(unmatch_require_param: [:name, :age]).require(:user)`' do
      expect_no_offenses(<<~RUBY)
        params.permit(unmatch_require_param: [:name, :age]).require(:user)
      RUBY
    end

    it 'does not register an offense when using `params.require(:name)`' do
      expect_no_offenses(<<~RUBY)
        params.require(:name)
      RUBY
    end

    it 'does not register an offense when using `params.permit(:name)`' do
      expect_no_offenses(<<~RUBY)
        params.permit(:name)
      RUBY
    end

    it 'does not register an offense when using `params.require(:target).permit`' do
      expect_no_offenses(<<~RUBY)
        params.require(:target).permit
      RUBY
    end

    it 'does not register an offense when using `params[:name]`' do
      expect_no_offenses(<<~RUBY)
        params[:name]
      RUBY
    end

    it 'does not register an offense when using `params.fetch(:name)`' do
      expect_no_offenses(<<~RUBY)
        params.fetch(:name)
      RUBY
    end

    it 'does not register an offense when using `params[:user][:name]`' do
      expect_no_offenses(<<~RUBY)
        params[:user][:name]
      RUBY
    end
  end

  context 'Rails <= 7.2', :rails72 do
    it 'does not register an offense when using `params.require(:user).permit(:name, :age)`' do
      expect_no_offenses(<<~RUBY)
        params.require(:user).permit(:name, :age)
      RUBY
    end
  end
end
