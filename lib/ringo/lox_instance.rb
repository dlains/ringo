module Ringo

  # LoxInstance represents a runtime instance of a LoxClass. It holds a reference
  # to the class and any data for the instance.
  class LoxInstance
    def initialize(klass)
      @klass = klass
      @fields = {}
    end

    def get(token)
      return @fields[token.lexeme] if @fields.has_key?(token.lexeme)

      method = @klass.find_method(self, token.lexeme)
      return method unless method.nil?

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
