module Ringo
  class LoxClass < LoxCallable
    attr_reader :name, :methods

    def initialize(name, methods)
      @name = name.lexeme
      @methods = methods
    end

    def arity
      return 0
    end

    def call(interpreter, arguments)
      Ringo::LoxInstance.new(self)
    end

    def find_method(instance, name)
      return @methods[name].bind(instance) if @methods.has_key?(name)
      return nil
    end

    def to_s
      @name
    end
  end
end
