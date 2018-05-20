module Ringo::Parser

  # LoxParser is  a parser for the Lox language. It takes a series of tokens
  # generated by the LoxScanner and parses the tokens into valid Lox expressions.
  # Any errors are reported via Ringo::error and then the parser synchronizes and
  # continues parsing the tokens.
  #
  # The current grammar is as follows:
  # program              -> declaration* EOF ;
  # declaration          -> varDecl | statement ;
  # varDecl              -> 'var' IDENTIFIER ( '=' expression )? ';' ;
  # statement            -> exprStmt
  #                       | forStmt
  #                       | ifStmt
  #                       | printStmt
  #                       | whileStmt
  #                       | block ;
  # exprStmt             -> expression ';' ;
  # forStmt              -> 'for' '(' ( varDecl | exprStmt | ';' ) expression? ';' expression? ';' ')' statement ;
  # ifStmt               -> 'if' '(' expression ')' statement ( 'else' statement )? ;
  # printStmt            -> 'print' expression ';' ;
  # whileStmt            -> 'while' '(' expression ')' statement ;
  # block                -> '{' declaration* '}' ;
  # arguments            -> expression ( ',' expression )* ;
  # expression           -> comma
  # comma                -> assignment (',' assignment)* ;
  # assignment           -> identifier '=' assignment | comparison ;
  # conditional          -> logicOr ('?' expression ':' conditional)? ;
  # logicOr              -> logicAnd ( 'or' logicAnd )* ;
  # logicAnd             -> equality ( 'and' equality )* ;
  # equality             -> comparison ( ( "!=" | "==" ) comparison )* ;
  # comparison           -> addition ( ( ">" | ">=" | "<" | "<=" ) addition )* ;
  # addition             -> multiplication ( ( "-" | "+" ) multiplication )* ;
  # multiplication       -> unary ( ( "/" | "*" ) unary )* ;
  # unary                -> ( "!" | "-" ) unary
  #                       | call ;
  # call                 -> primary ( '(' arguments? ')' )* ;
  # primary              -> NUMBER | STRING | 'false' | 'true' | 'nil'
  #                       | '(' expression ')'
  #                       | IDENTIFIER
  class LoxParser
    def initialize(tokens)
      @tokens = tokens
      @current = 0
    end

    # Start the recursive descent parse for the given expression.
    # The AST generated from parsing the tokens is returned, or nil if there
    # was a parse error.
    def parse
      statements = []
      while !at_end?
        statements << declaration
      end

      return statements
    rescue Ringo::Errors::ParseError
      return nil
    end

    private

    # Are we at the end of the token list?
    def at_end?
      peek.type == :eof
    end

    # Take a look at the current token.
    def peek
      @tokens.at(@current)
    end

    # Get the previous token.
    def previous
      @tokens.at(@current - 1)
    end

    # Check token_types for a match and advance to the next token if it does match.
    # If it does not match return false.
    def match?(*token_types)
      token_types.each do |type|
        if check?(type)
          advance
          return true
        end
      end

      return false
    end

    # Does the token type match the current token?
    # Return false if at the end of the token list or the token type doesn't match.
    # Return true if the current token's type matches the passed in token_type.
    def check?(token_type)
      return false if at_end?
      return peek.type == token_type
    end

    # Move the token list pointer to the next token and return the previous token.
    def advance
      @current += 1 unless at_end?
      return previous
    end

    # Move the token list pointer to the next token if the current token matches
    # +token_type+, otherwise raise an error with the given +message+.
    def consume(token_type, message)
      return advance if check?(token_type)
      raise error(peek, message)
    end

    # Pass the error token and message to Ringo.error so it will output to STDERR
    # and mark the @@had_error flag.
    # Returns a new Ringo::Errors::ParseError to the LoxParser can deal with the
    # error.
    def error(token, message)
      Ringo.error(token, message)
      return Ringo::Errors::ParseError.new
    end

    # After an error move forward in the token list until a new valid expression
    # can be parsed.
    # As long as the token stream is not at the end move forward until you find
    # a semicolon, or one of the keywords shown.
    def synchronize
      advance

      while !at_end?
        return if previous.type == :semicolon

        case peek.type
        when :class, :fun, :var, :for, :if, :while, :print, :return
          return
        end

        advance
      end
    end

    # Top level Lox grammar rule. A full program is a list of declarations.
    def declaration
      return var_declaration if match?(:var)
      return statement
    rescue Ringo::Errors::ParseError => error
      synchronize
      return nil
    end

    # Create a variable declaration of the form 'var x;', or 'var x = 2;'
    # If there is no initializer the var will be initialized to nil.
    def var_declaration
      name = consume(:identifier, 'Expect variable name.')

      initializer = nil
      initializer = expression if match?(:equal)

      consume(:semicolon, "Expect ';' after variable declaration.")
      return Ringo::Var.new(name, initializer)
    end

    # Fall through to statement if the declaraction is not a variable declaration.
    def statement
      return for_statement if match?(:for)
      return if_statement if match?(:if)
      return print_statement if match?(:print)
      return while_statement if match?(:while)
      return Ringo::Block.new(block) if match?(:lbrace)
      return expression_statement
    end

    # A traditional 'for' looping statement like the one in C.
    def for_statement
      consume(:lparen, "Expect '(' after 'for'.")
      
      initializer = nil
      if match?(:semicolon)
        initializer = nil
      elsif match?(:var)
        initializer = var_declaration
      else
        initializer = expression_statement
      end

      condition = nil
      if !check?(:semicolon)
        condition = expression
      end
      consume(:semicolon, "Expect ';' after loop condition.")

      increment = nil
      if !check?(:rparen)
        increment = expression
      end
      consume(:rparen, "Expect ')' after for clause.")

      body = statement

      if !increment.nil?
        body = Ringo::Block.new([body, Ringo::Expression.new(increment)])
      end

      if condition.nil?
        condition = Ringo::Literal.new(true)
      end
      body = Ringo::While.new(condition, body)

      if !initializer.nil?
        body = Ringo::Block.new([initializer, body])
      end

      return body
    end

    # A conditional if / else statement.
    def if_statement
      consume(:lparen, "Expect '(' after 'if'.")
      condition = expression
      consume(:rparen, "Expect ')' after if condition.")

      then_branch = statement
      else_branch = match?(:else) ? statement : nil

      return Ringo::If.new(condition, then_branch, else_branch)
    end

    # A kind of statement that prints the result of the given expression.
    def print_statement
      value = expression
      consume(:semicolon, "Expect ';' after value.")
      return Ringo::Print.new(value)
    end

    # A while loop statement. Execute body while the condition is true.
    def while_statement
      consume(:lparen, "Expect '(' after while.")
      condition = expression
      consume(:rparen, "Expect ')' after while condition.")
      body = statement

      return Ringo::While.new(condition, body)
    end

    # A block of statements grouped by {} characters.
    def block
      statements = []

      while !check?(:rbrace) && !at_end?
        statements << declaration
      end

      consume(:rbrace, "Expect '}' after block.")
      return statements
    end

    # A kind of statement that is just an expression followed by a semicolon.
    def expression_statement
      expr = expression
      consume(:semicolon, "Expect ';' after expression.")
      return Ringo::Expression.new(expr)
    end

    # An expression in the Lox language.
    def expression
      comma
    end

    # Handle the comma operator. It re-uses the Binary expression and groups
    # each pair of expressions.
    def comma
      expr = assignment

      while match?(:comma)
        operator = previous
        right = assignment
        expr = Ringo::Binary.new(expr, operator, right)
      end

      expr
    end

    # Handle assigning a new value to an existing variable.
    def assignment
      expr = conditional

      if match?(:equal)
        equals = previous
        value = expression

        if expr.is_a?(Ringo::Variable)
          name = expr.name
          return Ringo::Assign.new(name, value)
        end

        error(equals, "Invalid assignment target.")
      end

      return expr
    end

    # Handle the ternary operator 'expr ? expr : expr'.
    def conditional
      expr = logical_or

      if match?(:question)
        then_branch = expression
        consume(:colon, "Expect ':' after then branch of conditional expression.")
        else_branch = conditional
        expr = Ringo::Conditional.new(expr, then_branch, else_branch)
      end

      expr
    end

    # Handle the logical or operator.
    def logical_or
      expr = logical_and

      while match?(:or)
        operator = previous
        right = logical_and
        expr = Ringo::Logical.new(expr, operator, right)
      end

      expr
    end

    # Handle the logical and operator.
    def logical_and
      expr = equality

      while match?(:and)
        operator = previous
        right = equality
        expr = Ringo::Logical.new(expr, operator, right)
      end

      expr
    end

    # Handle equality operators: +!=+ and +==+.
    def equality
      expr = comparison

      while match?(:bang_equal, :equal_equal)
        operator = previous
        right = comparison
        expr = Ringo::Binary.new(expr, operator, right)
      end

      expr
    end

    # Handle comparison operators: +>+, +>=+, +<+, +<=+
    def comparison
      expr = addition

      while match?(:greater, :greater_equal, :less, :less_equal)
        operator = previous
        right = addition
        expr = Ringo::Binary.new(expr, operator, right)
      end

      return expr
    end

    # Handle addition and subtraction: +++, +-+.
    def addition
      expr = multiplication

      while match?(:minus, :plus)
        operator = previous
        right = multiplication
        expr = Ringo::Binary.new(expr, operator, right)
      end

      return expr
    end

    # Handle multiplication and division: +/+, +*+
    def multiplication
      expr = unary

      while match?(:slash, :star)
        operator = previous
        right = unary
        expr = Ringo::Binary.new(expr, operator, right)
      end

      return expr
    end

    # Handle unary operations: +!+, +-+
    def unary
      if match?(:bang, :minus)
        operator = previous
        right = unary
        return Ringo::Unary.new(operator, right)
      end

      return call
    end

    # Handle parsing function calls.
    def call
      expr = primary

      while(true)
        if match?(:lparen)
          expr = finish_call(expr)
        else
          break;
        end
      end

      return expr
    end

    # Handle function arguments.
    def finish_call(callee)
      arguments = []
      if !check?(:rparen)
        loop do
          if arguments.size >= 8
            error(peek, 'Cannot have more than eight arguments.')
          end
          arguments << expression
          break unless match?(:comma)
        end
      end

      paren = consume(:rparen, "Expect ')' after arguments.")

      Ringo::Call.new(callee, paren, arguments)
    end

    # Handle string, number, grouping and other literals: +true+, +false+, +nil+
    def primary
      return Ringo::Literal.new(false) if match?(:false)
      return Ringo::Literal.new(true)  if match?(:true)
      return Ringo::Literal.new(nil)   if match?(:nil)
      return Ringo::Literal.new(previous.literal) if match?(:number, :string)
      return Ringo::Variable.new(previous) if match?(:identifier)

      if match?(:lparen)
        expr = expression
        consume(:rparen, 'Expect ) after expression.')
        return Ringo::Grouping.new(expr)
      end

      raise error(peek(), 'Expecting expression.')
    end

  end
end
