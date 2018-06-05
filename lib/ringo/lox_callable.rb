module Ringo

  # LoxCallable is an interface for function type objects in the Lox language.
  # Two classes implement this behavior, LoxClass and LoxFunction. LoxFunction
  # handles regular function calls and LoxClass handles method calls on an
  # instance of a class.
  class LoxCallable
    def arity
      raise NotImplementedError.new("Arity is implemented by subclasses.")
    end

    def call
      raise NotImplementedError.new("Call is implemented by subclasses.")
    end
  end
end
