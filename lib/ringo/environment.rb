module Ringo
  class Environment
    def initialize(enclosing = nil)
      @values = Hash.new
      @enclosing = enclosing
    end

    def define(token, value)
      @values[token.lexeme] = value
    end

    def assign(token, value)
      if @values.has_key?(token.lexeme)
        @values[token.lexeme] = value
        return
      end

      unless @enclosing.nil?
        @enclosing.assign(token, value)
        return
      end
      raise undefined_variable_error(token.lexeme)
    end

    def get(name)
      return @values[name] if @values.has_key?(name)
      return @enclosing.get(name) unless @enclosing.nil?
      raise undefined_variable_error(name)
    end

    private

    def undefined_variable_error(name)
      Ringo::Errors::RuntimeError.new(name, "Undefined variable '#{name}'.")
    end
  end
end
