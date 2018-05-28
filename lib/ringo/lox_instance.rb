module Ringo
  class LoxInstance
    def initialize(klass)
      @klass = klass
    end

    def to_s
      "#{@klass.name} instance"
    end
  end
end
