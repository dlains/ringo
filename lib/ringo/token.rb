module Ringo

  # Represents a single token from the source code. The LoxScanner creates
  # tokens as it scans the source code.
  #
  # Type is the token type, a ruby symbol representing the type. can be one of:
  #   :lparen, :rparen, :lbrace, :rbrace, :comma, :dot, :minus, :plus, :semicolon,
  #   :slash, :star, :bang_equal, :bang, :equal_equal, :equal, :less_equal, :less,
  #   :greater_equal, :greater, :sting, :number, :identifier, :and, :class, :else,
  #   :false, :for, :fun, :if, :nil, :or, :print,:return, :super, :this, :true, :var, :while
  #
  # Lexeme is the actual text of the token from the source.
  #
  # Literal is the token converted to the required type. For Strings, Numbers, etc.
  #
  # Line is the line number in the source where the token was found.
  class Token
    attr_reader :type, :lexeme, :literal, :line

    def initialize(type, lexeme, literal, line)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s
      "#{type} #{lexeme} #{literal}".strip
    end
  end
end
