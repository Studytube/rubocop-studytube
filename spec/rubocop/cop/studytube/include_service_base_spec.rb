# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Studytube::IncludeServiceBase, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using class has self.call' do
    expect_offense(<<~RUBY)
      class AnyService
      ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
        def self.call
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class AnyService
        include ServiceBase
        def call
        end
      end
    RUBY
  end

  it 'registers an offense when using class has #call' do
    expect_offense(<<~RUBY)
      class AnyService
      ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
        def call
        end
      end
    RUBY
    
    expect_correction(<<~RUBY)
      class AnyService
        include ServiceBase
        def call
        end
      end
    RUBY
  end

  it 'does not register an offense when class includes ServiceBase' do
    expect_no_offenses(<<~RUBY)
      class AnyService
        include ServiceBase

        def call
        end
      end
    RUBY
  end

  it 'does not register an offense when class includes ::ServiceBase' do
    expect_no_offenses(<<~RUBY)
      class AnyService
        include ::ServiceBase

        def call
        end
      end
    RUBY
  end

  it 'does not register an offense when no call methods' do
    expect_no_offenses(<<~RUBY)
      class AnyService
      end
    RUBY
  end

  it 'does not register an offense when there is parent class' do
    expect_no_offenses(<<~RUBY)
      class AnyService < ParentService
        def call
        end
      end
    RUBY
  end

  it 'does not register an offense when there call method with args' do
    expect_no_offenses(<<~RUBY)
      class AnyService
        def call(args)
        end
      end
    RUBY
  end

  it 'does not register an offense when there call method with args' do
    expect_no_offenses(<<~RUBY)
      class AnyService
        def self.call(args)
        end
      end
    RUBY
  end

  it 'todo' do
    expect_offense(<<~RUBY)
    class AnyService
    ^^^^^^^^^^^^^^^^ please include ServiceBase into a service class
      attr_reader :params
    
      def initialize(params)
        @params = params
      end
    
      def self.call
        puts '1'
      end
    end
    RUBY
  end
end
