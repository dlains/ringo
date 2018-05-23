module Ringo
  class LoxFunction < LoxCallable
    def initialize(declaration, closure)
      @declaration = declaration
      @closure = closure
    end

    def arity
      @declaration.parameters.length
    end

    def call(interpreter, arguments)
      environment = Ringo::Environment.new(@closure)
      @declaration.parameters.each_index do |i|
        environment.define(@declaration.parameters.at(i), arguments.at(i))
      end

      begin
        interpreter.execute_block(@declaration.body, environment)
      rescue Ringo::Errors::Return => e
        return e.value
      end

      return nil
    end

    def to_s
      "<fn #{@declaration.name.lexeme}>"
    end
  end
end