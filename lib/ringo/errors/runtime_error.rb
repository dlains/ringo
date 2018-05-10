module Ringo::Errors
  class RuntimeError < StandardError
    attr_reader :token
    
    def initialize(token, message)
      @token = token
      super(message)
    end
  end
end
