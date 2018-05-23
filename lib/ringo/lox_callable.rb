module Ringo
  class LoxCallable
    def arity
      raise NotImplementedError.new("Arity is implemented by subclasses.")
    end

    def call
      raise NotImplementedError.new("Call is implemented by subclasses.")
    end
  end
end
