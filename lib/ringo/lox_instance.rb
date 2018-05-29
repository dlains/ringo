module Ringo
  class LoxInstance
    def initialize(klass)
      @klass = klass
      @fields = {}
    end

    def get(token)
      return @fields[token.lexeme] if @fields.has_key?(token.lexeme)
      raise Ringo::Errors::RuntimeError.new(token, "Undefined property #{token.lexeme}.")
    end

    def set(token, value)
      @fields[token.lexeme] = value
    end

    def to_s
      "#{@klass.name} instance"
    end
  end
end
