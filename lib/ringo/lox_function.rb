module Ringo

  # LoxFunction represents a function call. It implements the interface in
  # LoxCallable, which could probably be removed in this Ruby implementation.
  # LoxFunctions hold the original declaration of the function, a closure
  # around the environment available to the function at the time it is declared
  # and a flag to determine if it is a regular function or a class initializer.
  class LoxFunction < LoxCallable
    def initialize(declaration, closure, is_initializer)
      @declaration = declaration
      @closure = closure
      @is_initializer = is_initializer
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
        return @closure.get_at(0, 'this') if @is_initializer
        return e.value
      end

      return @closure.get_at(0, 'this') if @is_initializer
      return nil
    end

    def bind(instance)
      environment = Ringo::Environment.new(@closure)
      environment.define(Ringo::Token.new(:this, 'this', nil, 1), instance)
      return Ringo::LoxFunction.new(@declaration, environment, @is_initializer)
    end

    def to_s
      "<fn #{@declaration.name.lexeme}>"
    end
  end
end
