module Ringo::Errors
  class Return < ::RuntimeError
    attr_accessor :value

    def initialize(value)
      super(nil)
      @value = value
    end
  end
end
