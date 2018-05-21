module Ringo
  class Clock < LoxCallable

    def arity
      return 0
    end

    def call(interpreter, arguments)
      return Time.now.to_f / 1000.0
    end

  end
end
