module Ringo::Scanner

  # LoxScanner is a scanner for the Lox language. It takes a string of source code
  # and generates an array of tokens from it.
  class LoxScanner
    attr_reader :source, :tokens

    def initialize(source)
      @source = source
      @tokens = []
      @start = 0
      @current = 0
      @line = 1
      @keywords = Hash.new(:identifier)
      @keywords['and']    = :and
      @keywords['class']  = :class
      @keywords['else']   = :else
      @keywords['false']  = :false
      @keywords['for']    = :for
      @keywords['fun']    = :fun
      @keywords['if']     = :if
      @keywords['nil']    = :nil
      @keywords['or']     = :or
      @keywords['print']  = :print
      @keywords['return'] = :return
      @keywords['super']  = :super
      @keywords['this']   = :this
      @keywords['true']   = :true
      @keywords['var']    = :var
      @keywords['while']  = :while
    end

    # Retrieve an array of Tokens found in the source code.
    def scan
      while !at_end?
        @start = @current
        scan_token
      end

      add_token(:eof)
      @tokens
    end

    private

    # Look at each character in the source and determine what kind of token it
    # is. Found tokens are stored in the +@tokens+ array. If a token can not be
    # determined report it to STDERR.
    def scan_token
      character = next_character
      case character
      when '('
        add_token(:lparen)
      when ')'
        add_token(:rparen)
      when '{'
        add_token(:lbrace)
      when '}'
        add_token(:rbrace)
      when ','
        add_token(:comma)
      when '?'
        add_token(:question)
      when ':'
        add_token(:colon)
      when '.'
        add_token(:dot)
      when '-'
        add_token(:minus)
      when '+'
        add_token(:plus)
      when ';'
        add_token(:semicolon)
      when '/'
        if match?('/')
          # Found a comment, ignore the rest of the line.
          while(!new_line? && !at_end?)
            next_character
          end
        else
          add_token(:slash)
        end
      when '*'
        add_token(:star)
      when '!'
        add_token(match?('=') ? :bang_equal : :bang)
      when '='
        add_token(match?('=') ? :equal_equal : :equal)
      when '<'
        add_token(match?('=') ? :less_equal : :less)
      when '>'
        add_token(match?('=') ? :greater_equal : :greater)
      when '"'
        string
      when /[[:digit:]]/
        number
      when /[[:alpha:]_]/
        identifier
      when ' ', "\r", "\t"
        # Ignore white space.
      when "\n"
        # New line found.
        @line += 1
      else
        Ringo.report_error(@line, 'Unexpected character')
      end
    end

    # Has the scanner reached the end of the source code?
    def at_end?
      return @current >= source.length
    end

    # Have we reached a new line in the source file?
    def new_line?
      peek == "\n"
    end

    # Is the current character a number?
    def digit?(character)
      character =~ /[[:digit:]]/
    end

    # Is the current character a letter?
    def alpha?(character)
      character =~ /[[:alpha:]]/
    end

    # Is the current character a letter or number?
    def alpha_numeric?(character)
      character =~ /[[:alnum:]]/
    end

    # Does the next character in the source code match +character+?
    #
    # Return true and increment the current pointer if the character matches, otherwise return false.
    def match?(character)
      return false if at_end?
      return false if source[@current] != character

      @current += 1
      return true
    end

    # Get the next character in the source code. The current pointer is incremented.
    #
    # Return the current character from the source code.
    def next_character
      @current += 1
      source[@current - 1]
    end

    # Get the next character in the source code, but do not advance the current pointer.
    def peek
      return "\0" if at_end?
      source[@current]
    end

    # Get the character after the next in the source code. We need this in cases where
    # it requires two characters to determine the correct lexeme.
    # For instance: number literals like 12.21. The scanner will stop on the first 2,
    # use peek to check for the '.' and if it finds one use peek_next to see if there
    # is another digit after the '.'.
    def peek_next
      return "\0" if @current + 1 >= source.length
      source[@current + 1]
    end

    # Found a double-quote character in source. Scan the source for the full
    # string literal.
    def string
      while(peek != '"' && !at_end?)
        @line += 1 if new_line?
        next_character
      end

      if at_end?
        Ringo.error(Ringo::Token.new(:quote, '"', nil, @line), 'Unterminated string found.')
        return
      end

      # Move past the final double quote character.
      next_character

      # Get the string literal without the surrounding quotes.
      value = source[@start + 1, (@current - @start - 2)]
      add_token(:string, value)
    end

    # Found a digit in the source. Scan the source for the full number literal.
    def number
      while(digit?(peek))
        next_character
      end

      # Look for floating point numbers.
      if peek == '.' && digit?(peek_next)
        # consume the .
        next_character

        while(digit?(peek))
          next_character
        end
      end

      add_token(:number, token_text.to_f)
    end

    # Found the start of an identifier [a-zA-Z_]. Scan the source for the full
    # identifier.
    def identifier
      while(alpha_numeric?(peek))
        next_character
      end

      type = @keywords[token_text]
      add_token(type)
    end

    # Create a Token object and add it to the +@tokens+ array.
    def add_token(type, literal = nil)
      @tokens << Ringo::Token.new(type, token_text, literal, @line)
    end

    # Extract the token text from the source code.
    def token_text
      source[@start, (@current - @start)]
    end
  end
end
