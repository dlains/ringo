module Ringo
  class Environment
    def initialize
      @values = Hash.new
    end

    def define(name, value)
      @values[name] = value
    end

    def get(name)
      @values.fetch(name) do
        raise Ringo::Errors::RuntimeError.new(name, "Undefined variable '#{name}'.")
      end
    end
  end
end
