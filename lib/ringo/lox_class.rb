module Ringo
  class LoxClass < LoxCallable
    attr_reader :name

    def initialize(name)
      @name = name.lexeme
    end

    def arity
      return 0
    end

    def call(interpreter, arguments)
      Ringo::LoxInstance.new(self)
    end

    def to_s
      @name
    end
  end
end
