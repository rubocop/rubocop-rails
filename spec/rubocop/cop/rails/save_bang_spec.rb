# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::SaveBang, :config do
  let(:cop_config) { { 'AllowImplicitReturn' => true } }

  shared_examples 'checks_common_offense' do |method|
    it "when using #{method} with arguments" do
      if method == :destroy
        expect_no_offenses(<<~RUBY)
          object.#{method}(name: 'Tom', age: 20)
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method}(name: 'Tom', age: 20)
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
        RUBY

        expect_correction(<<~RUBY)
          object.#{method}!(name: 'Tom', age: 20)
        RUBY
      end
    end

    it "when using #{method} with variable arguments" do
      inspect_source("object.#{method}(variable)")

      if method == :destroy
        expect_no_offenses(<<~RUBY)
          object.#{method}(variable)
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method}(variable)
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
        RUBY

        expect_correction(<<~RUBY)
          object.#{method}!(variable)
        RUBY
      end
    end

    it "when using #{method} with variable star arguments" do
      if method == :destroy
        expect_no_offenses(<<~RUBY)
          object.#{method}(*variable)
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method}(*variable)
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
        RUBY

        expect_correction(<<~RUBY)
          object.#{method}!(*variable)
        RUBY
      end
    end

    it "when using #{method} with variable star star arguments" do
      if method == :destroy
        expect_no_offenses(<<~RUBY)
          object.#{method}(**variable)
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method}(**variable)
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
        RUBY

        expect_correction(<<~RUBY)
          object.#{method}!(**variable)
        RUBY
      end
    end

    it "when using #{method} without arguments" do
      expect_offense(<<~RUBY, method: method)
        #{method}
        ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY

      expect_correction(<<~RUBY)
        #{method}!
      RUBY
    end

    it "when using #{method} without arguments" do
      expect_offense(<<~RUBY, method: method)
        object&.#{method}
                ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY

      expect_correction(<<~RUBY)
        object&.#{method}!
      RUBY
    end

    it "when using #{method}!" do
      expect_no_offenses("object.#{method}!")
    end

    it "when using #{method} with 2 arguments" do
      expect_no_offenses("Model.#{method}(1, name: 'Tom')")
    end

    it "when using #{method} with wrong argument" do
      expect_no_offenses("object.#{method}('Tom')")
    end
  end

  shared_examples 'checks_variable_return_use_offense' do |method, update|
    it "when assigning the return value of #{method}" do
      if update
        expect_no_offenses(<<~RUBY)
          x = object.#{method}
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          x = object.#{method}
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
        RUBY
      end
    end

    it "when assigning the return value of #{method} with block" do
      if update
        expect_no_offenses(<<~RUBY)
          x = object.#{method} do |obj|
            obj.name = 'Tom'
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          x = object.#{method} do |obj|
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
            obj.name = 'Tom'
          end
        RUBY
      end
    end

    it "when assigning the return value of #{method} with numblock" do
      if update
        expect_no_offenses(<<~RUBY)
          x = object.#{method} do
            _1.name = 'Tom'
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          x = object.#{method} do
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
            _1.name = 'Tom'
          end
        RUBY
      end
    end

    it "when assigning the return value of #{method} with `it` block", :ruby34, unsupported_on: :parser do
      if update
        expect_no_offenses(<<~RUBY)
          x = object.#{method} do
            it.name = 'Tom'
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          x = object.#{method} do
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
            it.name = 'Tom'
          end
        RUBY
      end
    end

    it "when using #{method} with if" do
      if update
        expect_no_offenses(<<~RUBY)
          if object.#{method}; something; end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if object.#{method}; something; end
                    ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with if with method chain" do
      if update
        expect_no_offenses(<<~RUBY)
          if object.tap(&:prepare_for_save).#{method}
            something
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if object.tap(&:prepare_for_save).#{method}
                                            ^{method} `#{method}` returns a model which is always truthy.
            something
          end
        RUBY
      end
    end

    it "when using #{method} wrapped within parenthesis with if" do
      if update
        expect_no_offenses(<<~RUBY)
          if (object.#{method}); something; end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if (object.#{method}); something; end
                     ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with if with block" do
      if update
        expect_no_offenses(<<~RUBY)
          if object.#{method} { |o| o.name = 'Tom' }
            something
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if object.#{method} { |o| o.name = 'Tom' }
                    ^{method} `#{method}` returns a model which is always truthy.
            something
          end
        RUBY
      end
    end

    it "when using #{method} with referenced block" do
      if update
        expect_no_offenses(<<~RUBY)
          if object.#{method}(&:values); something; end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if object.#{method}(&:values); something; end
                    ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with negated if" do
      if update
        expect_no_offenses(<<~RUBY)
          if !object.#{method}; something; end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if !object.#{method}; something; end
                     ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with multiple conditional" do
      if update
        expect_no_offenses(<<~RUBY)
          if true && object.active? && object.#{method}
            something
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          if true && object.active? && object.#{method}
                                              ^{method} `#{method}` returns a model which is always truthy.
            something
          end
        RUBY
      end
    end

    it "when using #{method} with oneline if" do
      if update
        expect_no_offenses(<<~RUBY)
          something if object.#{method}
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          something if object.#{method}
                              ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with oneline if and multiple conditional" do
      if update
        expect_no_offenses(<<~RUBY)
          something if false || object.#{method}
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          something if false || object.#{method}
                                       ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} in the body of a oneline if" do
      expect_offense(<<~RUBY, method: method)
        object.#{method} if false
               ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY
    end

    it "when using #{method} in the body of an else" do
      expect_offense(<<~RUBY, method: method)
        if condition
          puts "true"
        else
          object.#{method}
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
        end
      RUBY
    end

    it "when using #{method} with a bunch of hashes & arrays" do
      expect_no_offenses(<<~RUBY)
        return [{ success: object.#{method} }, true]
      RUBY
    end

    it "when using #{method} with case statement" do
      if update
        expect_no_offenses(<<~RUBY)
          case object.#{method}
          when true
            puts "true"
          when false
            puts "false"
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          case object.#{method}
                      ^{method} `#{method}` returns a model which is always truthy.
          when true
            puts "true"
          when false
            puts "false"
          end
        RUBY
      end
    end

    it "when using #{method} with '&&'" do
      if update
        expect_no_offenses(<<~RUBY)
          object.#{method} && false
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method} && false
                 ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with 'and'" do
      if update
        expect_no_offenses(<<~RUBY)
          object.#{method} and false
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method} and false
                 ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it "when using #{method} with '||'" do
      if update
        expect_no_offenses(<<~RUBY)
          object.#{method} || false
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method} || false
                 ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it 'when passing to a method' do
      expect_no_offenses("handle_save(object.#{method})")
    end

    it 'when passing to a method as the non-last argument' do
      expect_no_offenses("handle_save(object.#{method}, true)")
    end

    it "when using #{method} with 'or'" do
      if update
        expect_no_offenses(<<~RUBY)
          object.#{method} or false
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          object.#{method} or false
                 ^{method} `#{method}` returns a model which is always truthy.
        RUBY
      end
    end

    it 'when passing to a method as a keyword argument' do
      expect_no_offenses("handle_save(success: object.#{method})")
    end

    it 'when assigning as a hash value' do
      expect_no_offenses("result = { success: object.#{method} }")
    end

    it 'when using an explicit early return' do
      expect_no_offenses(<<~RUBY)
        def foo
          return foo.#{method} if do_the_save
          do_something_else
        end
      RUBY
    end

    it 'when using an explicit final return' do
      expect_no_offenses(<<~RUBY)
        def foo
          return foo.#{method}
        end
      RUBY
    end

    it 'when using an explicit early return from a block' do
      expect_no_offenses(<<~RUBY)
        objects.each do |object|
          next object.#{method} if do_the_save
          do_something_else
        end
      RUBY
    end

    it 'when using an explicit final return from a block' do
      expect_no_offenses(<<~RUBY)
        objects.each do |object|
          next foo.#{method}
        end
      RUBY
    end

    it 'when using an allowed variable receiver' do
      cop_config['AllowedReceivers'] = ['gateway']
      expect_no_offenses(<<~RUBY)
        gateway = true
        gateway.#{method}
        gateway.#{method} { |t| t.name = 'Tom' }

        merchant.gateway = true
        merchant.gateway.#{method}
        merchant.gateway.#{method} { |t| t.name = 'Tom' }
      RUBY
    end

    it 'when using an allowed method receiver' do
      cop_config['AllowedReceivers'] = ['customer']
      expect_no_offenses(<<~RUBY)
        customer.#{method}
        merchant.customer.#{method}
        customer(true).#{method}
        merchant.customer(true).#{method}
        customer.#{method} { |t| t.name = 'Tom' }
        merchant.customer.#{method} { |t| t.name = 'Tom' }
      RUBY
    end

    it 'when using an allowed const receiver' do
      cop_config['AllowedReceivers'] = ['NonActiveRecord']
      expect_no_offenses(<<~RUBY)
        NonActiveRecord.#{method}
        NameSpace::NonActiveRecord.#{method}
        ::NonActiveRecord.#{method}
        NonActiveRecord::#{method}
      RUBY
    end

    it 'when using an allowed namespaced const receiver' do
      cop_config['AllowedReceivers'] = ['NameSpace::NonActiveRecord']
      expect_no_offenses(<<~RUBY)
        NameSpace::NonActiveRecord.#{method}
        ::NameSpace::NonActiveRecord.#{method}
        NameSpace::NonActiveRecord::#{method}
      RUBY
    end

    it 'when using only part of an allowed namespaced const receiver' do
      cop_config['AllowedReceivers'] = ['NameSpace::NonActiveRecord']

      expect_offense(<<~RUBY, method: method)
        NonActiveRecord.#{method}
                        ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY
    end

    it 'when using a namespaced const with an allowed absolute const' do
      cop_config['AllowedReceivers'] = ['::NonActiveRecord']

      expect_offense(<<~RUBY, method: method)
        NameSpace::NonActiveRecord.#{method}
                                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY
    end

    it 'when using an allowed method chain receiver' do
      cop_config['AllowedReceivers'] = ['merchant.gateway']

      expect_no_offenses(<<~RUBY)
        merchant.gateway.#{method}
      RUBY
    end

    it 'when using only part of an allowed method chain receiver' do
      cop_config['AllowedReceivers'] = ['merchant.gateway']

      expect_offense(<<~RUBY, method: method)
        gateway.#{method}
                ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY
    end

    it 'when using an allowed class and method receiver' do
      cop_config['AllowedReceivers'] = ['A::B.merchant.gateway']

      expect_no_offenses(<<~RUBY)
        A::B.merchant.gateway.#{method}
        A::B::merchant::gateway::#{method}
      RUBY
    end

    it 'when using only part of an allowed class and method receiver' do
      cop_config['AllowedReceivers'] = ['A::B.merchant.gateway']

      expect_offense(<<~RUBY, method: method)
        B.merchant.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
      RUBY
    end

    # Bug: https://github.com/rubocop/rubocop/issues/4264
    it 'when using the assigned variable as value in a hash' do
      if update
        expect_no_offenses(<<~RUBY)
          def foo
            foo = Foo.#{method}
            render json: foo
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            foo = Foo.#{method}
                      ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
            render json: foo
          end
        RUBY
      end
    end
  end

  shared_examples 'check_implicit_return' do |method, allow_implicit_return|
    it "when using #{method} as last method call" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            object.#{method}
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            object.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} as last method call of a block" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          objects.each do |object|
            object.#{method}
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          objects.each do |object|
            object.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} as last method call of a numblock" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          objects.each do
            _1.#{method}
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          objects.each do
            _1.#{method}
               ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} as last method call of an itblock", :ruby34, unsupported_on: :parser do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          objects.each do
            it.#{method}
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          objects.each do
            it.#{method}
               ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} as part of the last line" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def whatever
            [{ success: object.#{method} }, true]
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def whatever
            [{ success: object.#{method} }, true]
                               ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} as the last method call in a multiline method" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            bar
            object.#{method}
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            bar
            object.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} as the last method call in a multiline block" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          objects.each do |object|
            bar
            object.#{method}
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          objects.each do |object|
            bar
            object.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} in a modifier if as the last expression" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            object.#{method} if condition
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            object.#{method} if condition
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} in a modifier unless as the last expression" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            object.#{method} unless condition
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            object.#{method} unless condition
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY
      end
    end

    it "when using #{method} in a modifier if before the last expression" do
      expect_offense(<<~RUBY, method: method)
        def foo
          object.#{method} if condition
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          bar
        end
      RUBY
    end

    it "when using #{method} in an if as the last expression" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            if condition
              prepare
              object.#{method}
            end
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            if condition
              prepare
              object.#{method}
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo
            if condition
              prepare
              object.#{method}!
            end
          end
        RUBY
      end
    end

    it "when using #{method} in each branch of an if-elsif-else as the last expression" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            if condition
              object.#{method}
            elsif other_condition
              other.#{method}
            else
              another.#{method}
            end
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            if condition
              object.#{method}
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
            elsif other_condition
              other.#{method}
                    ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
            else
              another.#{method}
                      ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo
            if condition
              object.#{method}!
            elsif other_condition
              other.#{method}!
            else
              another.#{method}!
            end
          end
        RUBY
      end
    end

    it "when using #{method} in a ternary as the last expression" do
      if allow_implicit_return
        expect_no_offenses(<<~RUBY)
          def foo
            condition ? object.#{method} : nil
          end
        RUBY
      else
        expect_offense(<<~RUBY, method: method)
          def foo
            condition ? object.#{method} : nil
                               ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo
            condition ? object.#{method}! : nil
          end
        RUBY
      end
    end

    it "when using #{method} before the last expression of an if branch" do
      expect_offense(<<~RUBY, method: method)
        def foo
          if condition
            object.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
            bar
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          if condition
            object.#{method}!
            bar
          end
        end
      RUBY
    end

    it "when using #{method} in an if before the last expression" do
      expect_offense(<<~RUBY, method: method)
        def foo
          if condition
            object.#{method}
                   ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          end
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          if condition
            object.#{method}!
          end
          bar
        end
      RUBY
    end

    it "when using #{method} not as the last method call in a multiline method" do
      expect_offense(<<~RUBY, method: method)
        def foo
          object.#{method}
                 ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked.
          bar
        end
      RUBY
    end
  end

  described_class::MODIFY_PERSIST_METHODS.each do |method|
    context method.to_s do
      let(:cop_config) { { 'AllowImplicitReturn' => true } }

      it_behaves_like('checks_common_offense', method)
      it_behaves_like('checks_variable_return_use_offense', method, true)
      it_behaves_like('check_implicit_return', method, true)

      context 'with AllowImplicitReturn false' do
        let(:cop_config) { { 'AllowImplicitReturn' => false } }

        it_behaves_like('checks_variable_return_use_offense', method, true)
        it_behaves_like('check_implicit_return', method, false)
      end
    end
  end

  shared_examples 'checks_create_offense' do |method|
    it "when using persisted? after #{method}" do
      expect_no_offenses(<<~RUBY)
        x = object.#{method}
        if x.persisted? then; something; end
      RUBY
    end

    it "when using persisted? after #{method} with block" do
      expect_no_offenses(<<~RUBY)
        x = object.#{method} do |obj|
          obj.name = 'Tom'
        end
        if x.persisted? then; something; end
      RUBY
    end

    it "when using persisted? after #{method} called on a chain" do
      expect_no_offenses(<<~RUBY)
        x = User.unverified.with_initial_values.#{method}
        if x.persisted?; something; end
      RUBY
    end

    it "when using persisted? directly on #{method} return value" do
      expect_no_offenses(<<~RUBY)
        return unless object.#{method}.persisted?
      RUBY
    end

    it "when using persisted? directly on a parenthesized #{method} return value" do
      expect_no_offenses(<<~RUBY)
        return unless (object.#{method}).persisted?
      RUBY
    end

    it "when using persisted? on the result of #{method} in if assignment" do
      expect_no_offenses(<<~RUBY)
        if (user = User.#{method}).persisted?
          foo(user)
        else
          bar(user)
        end
      RUBY
    end

    it "when not using persisted? on the result of #{method} in if assignment" do
      expect_offense(<<~RUBY, method: method)
        if (user = User.#{method})
                        ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
          foo(user)
        else
          bar(user)
        end
      RUBY
    end

    it "when using persisted? on the result of #{method} in elsif assignment" do
      expect_no_offenses(<<~RUBY)
        if something
        elsif (user = User.#{method}).persisted?
          foo(user)
        else
          bar(user)
        end
      RUBY
    end

    it "when using persisted? on the result of #{method} in if assignment without a parenthesized call" do
      expect_no_offenses(<<~RUBY)
        if (user = User.#{method}).persisted?
          foo
        end

        return unless (post = Post.#{method}).persisted?
        bar post
      RUBY
    end

    it "when using persisted? on a variable that a nested assignment of #{method} is assigned to" do
      expect_no_offenses(<<~RUBY)
        temp = (user = User.#{method})

        if temp.persisted?
          foo
        end
      RUBY
    end

    it "when using persisted? on a variable that a chained assignment of #{method} is assigned to" do
      expect_no_offenses(<<~RUBY)
        temp = user = User.#{method}

        if temp.persisted?
          foo
        end
      RUBY
    end

    it "when using persisted? on the inner variable of a nested assignment of #{method}" do
      expect_no_offenses(<<~RUBY)
        temp = (user = User.#{method})

        if user.persisted?
          foo(temp)
        end
      RUBY
    end

    it "when using persisted? after a parenthesized #{method}" do
      expect_no_offenses(<<~RUBY)
        user = (User.#{method})

        if user.persisted?
          foo
        end
      RUBY
    end

    it "when not using persisted? after a parenthesized #{method}" do
      expect_offense(<<~RUBY, method: method)
        user = (User.#{method})
                     ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
        foo(user)
      RUBY
    end

    it "when not using persisted? on a variable that a nested assignment of #{method} is assigned to" do
      expect_offense(<<~RUBY, method: method)
        temp = (user = User.#{method})
                            ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.
        foo(temp)
      RUBY
    end

    it "when passing the result of #{method} to a parenthesized call in an if checking another persisted?" do
      expect_offense(<<~RUBY, method: method)
        user = User.#{method}
                    ^{method} Use `#{method}!` instead of `#{method}` if the return value is not checked. Or check `persisted?` on model returned from `#{method}`.

        if other.persisted?
          foo(user)
        end
      RUBY
    end

    it "does not register an offense when using persisted? after #{method} to a local variable" do
      expect_no_offenses(<<~RUBY)
        user = User.#{method}

        if user.persisted?
          foo
        end
      RUBY
    end

    it "does not register an offense when using persisted? after #{method} to an instance variable" do
      expect_no_offenses(<<~RUBY)
        @user = User.#{method}

        if @user.persisted?
          foo
        end
      RUBY
    end

    it "does not register an offense when using persisted? after #{method} to a global variable" do
      expect_no_offenses(<<~RUBY)
        $user = User.#{method}

        if $user.persisted?
          foo
        end
      RUBY
    end

    it "does not register an offense when using persisted? after #{method} for multiple assignments" do
      expect_no_offenses(<<~RUBY)
        a, b = User.#{method}, User.new

        if a.persisted?
          foo
        end
      RUBY
    end

    it "does not register an offense when using persisted? after #{method} for conditional assignments" do
      expect_no_offenses(<<~RUBY)
        user ||= User.#{method}

        if user.persisted?
          foo
        end
      RUBY
    end

    it "when using #{method} with `||`" do
      expect_no_offenses(<<~RUBY)
        def find_or_create(**opts)
          find(**opts) || #{method}(**opts)
        end
      RUBY
    end
  end

  described_class::CREATE_PERSIST_METHODS.each do |method|
    context method.to_s do
      let(:cop_config) { { 'AllowImplicitReturn' => true } }

      it_behaves_like('checks_common_offense', method)
      it_behaves_like('checks_variable_return_use_offense', method, false)
      it_behaves_like('checks_create_offense', method)
      it_behaves_like('check_implicit_return', method, true)

      context 'with AllowImplicitReturn false' do
        let(:cop_config) { { 'AllowImplicitReturn' => false } }

        it_behaves_like('checks_variable_return_use_offense', method, false)
        it_behaves_like('check_implicit_return', method, false)
      end
    end
  end

  describe 'a persistence method passed as a symbol block' do
    described_class::MODIFY_PERSIST_METHODS.each do |method|
      it "registers an offense for each(&:#{method}) and autocorrects it" do
        expect_offense(<<~RUBY, method: method)
          users.each(&:#{method})
                      ^^{method} Use `&:#{method}!` instead of `&:#{method}` if the return value is not checked.
          something
        RUBY

        expect_correction(<<~RUBY)
          users.each(&:#{method}!)
          something
        RUBY
      end
    end

    it 'registers an offense for a call with safe navigation' do
      expect_offense(<<~RUBY)
        users&.each(&:save)
                     ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
        something
      RUBY
    end

    it 'registers an offense when the result is not used in an if body' do
      expect_offense(<<~RUBY)
        if condition
          users.each(&:save)
                      ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
        end
        something
      RUBY
    end

    it 'allows the bang form' do
      expect_no_offenses('users.each(&:save!)')
    end

    it 'allows other symbol blocks' do
      expect_no_offenses(<<~RUBY)
        users.each(&:touch)
        users.map(&:name)
        something
      RUBY
    end

    it 'allows a block that is not a symbol' do
      expect_no_offenses(<<~RUBY)
        users.each(&block)
        something
      RUBY
    end

    it 'allows a result that is assigned' do
      expect_no_offenses(<<~RUBY)
        saved = users.map(&:save)
        something
      RUBY
    end

    it 'allows a result that is tested in a condition' do
      expect_no_offenses(<<~RUBY)
        if users.all?(&:save)
          something
        end
      RUBY
    end

    it 'allows a result that is an operand of a boolean operator' do
      expect_no_offenses(<<~RUBY)
        users.all?(&:save) || raise('failed')
        something
      RUBY
    end

    it 'allows a result that is explicitly returned' do
      expect_no_offenses(<<~RUBY)
        def save_all
          return users.all?(&:save)
        end
      RUBY
    end

    it 'allows a result that is passed as an argument' do
      expect_no_offenses(<<~RUBY)
        raise_if_failed(users.map(&:save))
      RUBY
    end

    it 'allows a chained call' do
      expect_no_offenses(<<~RUBY)
        users.map(&:save).all?
        users.reject(&:save).each { |user| report(user) }
        users.select(&:save).size
        something
      RUBY
    end

    it 'registers an offense for a result that is discarded before the last statement of a method' do
      expect_offense(<<~RUBY)
        def save_all
          users.all?(&:save)
                      ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
          something
        end
      RUBY
    end

    it 'registers an offense for the last statement of an each block' do
      expect_offense(<<~RUBY)
        groups.each do |group|
          group.users.each(&:save)
                            ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
        end
      RUBY
    end

    it 'registers an offense for the last statement of initialize' do
      expect_offense(<<~RUBY)
        def initialize
          users.each(&:save)
                      ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
        end
      RUBY
    end

    it 'registers an offense for a result that is discarded in a case branch' do
      expect_offense(<<~RUBY)
        case kind
        when :all
          users.each(&:save)
                      ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
        end
        something
      RUBY
    end

    it 'allows the implicit return of a method from an if branch' do
      expect_no_offenses(<<~RUBY)
        def save_all
          if condition
            users.each(&:save)
          end
        end
      RUBY
    end

    it 'allows the implicit return of a method' do
      expect_no_offenses(<<~RUBY)
        def save_all
          users.all?(&:save)
        end
      RUBY
    end

    context 'with AllowImplicitReturn false' do
      let(:cop_config) { { 'AllowImplicitReturn' => false } }

      it 'registers an offense for the implicit return of a method' do
        expect_offense(<<~RUBY)
          def save_all
            users.all?(&:save)
                        ^^^^^ Use `&:save!` instead of `&:save` if the return value is not checked.
          end
        RUBY

        expect_correction(<<~RUBY)
          def save_all
            users.all?(&:save!)
          end
        RUBY
      end
    end
  end

  it 'properly ignores lvasign without right hand side' do
    expect_no_offenses('variable += 1')
  end

  it 'ignores update when called on ENV' do
    expect_no_offenses('ENV.update("DISABLE_SPRING" => "1")')
  end
end
