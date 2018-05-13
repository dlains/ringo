module Ringo
  class Environment
    def initialize
      @values = Hash.new
    end

    def define(token, value)
      @values[token.lexeme] = value
    end

    def assign(token, value)
      @values.fetch(token.lexeme) do
        raise undefined_variable_error(token.lexeme)
      end
      @values[token.lexeme] = value
    end

    def get(name)
      @values.fetch(name) do
        raise undefined_variable_error(name)
      end
    end

    private

    def undefined_variable_error(name)
      Ringo::Errors::RuntimeError.new(name, "Undefined variable '#{name}'.")
    end
  end
end
