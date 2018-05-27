module Ringo
  class LoxClass
    def initialize(name)
      @name = name.lexeme
    end

    def to_s
      @name
    end
  end
end
