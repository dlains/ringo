module Ringo

  # LoxClass is a runtime representation of a class in the Lox language. Runtime
  # instances of a class store their data in the LoxInstance, but methods are
  # stored in the LoxClass so they can be shared amongst all instances. LoxClass
  # also provides support for calling methods in the superclass.
  class LoxClass < LoxCallable
    attr_reader :name, :methods

    def initialize(name, superclass, methods)
      @name = name.lexeme
      @superclass = superclass
      @methods = methods
    end

    def arity
      initializer = @methods['init']
      return 0 if initializer.nil?
      return initializer.arity
    end

    def call(interpreter, arguments)
      instance = Ringo::LoxInstance.new(self)
      initializer = @methods['init']
      initializer.bind(instance).call(interpreter, arguments) unless initializer.nil?
      return instance
    end

    def find_method(instance, name)
      return @methods[name].bind(instance) if @methods.has_key?(name)
      return @superclass.find_method(instance, name)
      return nil
    end

    def to_s
      @name
    end
  end
end
