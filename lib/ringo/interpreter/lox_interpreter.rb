module Ringo::Interpreter

  # The LoxInterpreter is a tree walk interpreter for the Lox language. It uses the
  # visitor pattern to recursively walk through the AST nodes provided by the
  # LoxParser and performs the actions specified in the source code.
  class LoxInterpreter
    attr_reader :globals

    def initialize
      @environment = Ringo::Environment.new
      @globals = @environment

      # Create the clock native function and put it in globals.
      @globals.define(Ringo::Token.new(:identifier, 'clock', nil, 1), Ringo::Clock.new)
    end

    # Kick off the interpreter for the given statements. If a runtime error occurs
    # it is caught here and reported to the Ringo error routines, otherwise a
    # string representation of the result of the expression is returned to the caller.
    def interpret(statements)
      statements.each do |statement|
        execute(statement)
      end
    rescue Ringo::Errors::RuntimeError => error
      Ringo.runtime_error(error)
    end

    # Handle function declarations. Create a LoxFunction and store it
    # in the environment.
    def visit_function(statement)
      function = Ringo::LoxFunction.new(statement, @environment)
      @environment.define(statement.name, function)
      return nil
    end

    # Handle var declarations.
    def visit_var(statement)
      value = nil
      value = evaluate(statement.initializer) unless statement.initializer.nil?

      @environment.define(statement.name, value)
      return nil
    end

    # Handle while loops.
    def visit_while(statement)
      while(is_truthy?(evaluate(statement.condition)))
        execute(statement.body)
      end

      return nil
    end

    # Handle expression statements.
    def visit_expression(statement)
      evaluate(statement.expression)
      return nil
    end

    # Handle a conditional if / else statement.
    def visit_if(statement)
      if is_truthy?(evaluate(statement.condition))
        execute(statement.then_branch)
      elsif !statement.else_branch.nil?
        execute(statement.else_branch)
      end

      return nil
    end

    # Handle print statements.
    def visit_print(statement)
      value = evaluate(statement.expression)
      puts stringify(value)
      return nil
    end

    # Handle a return statement within function calls. This rewinds all of the
    # visit_* interpreter calls back to visit_call.
    def visit_return(statement)
      value = statement.value.nil? ? nil : evaluate(statement.value)
      raise Ringo::Errors::Return.new(value)
    end

    # Handle a block of statements. A block creates a new scope, so a new
    # environment is created and the current environment is set as the enclosing
    # scope.
    def visit_block(block)
      execute_block(block.statements, Ringo::Environment.new(@environment))
      return nil
    end

    # Handle variable expressions.
    def visit_variable(expression)
      return @environment.get(expression.name.lexeme)
    end

    # Handle binary expressions. The +plus+ case is overloaded to add either numbers
    # or concatenate strings. The operations that require a number are validated. If
    # both operands are not Numeric a runtime error is raised.
    def visit_binary(binary)
      left = evaluate(binary.left)
      right = evaluate(binary.right)

      case binary.operator.type
      when :plus
        if ((left.is_a?(String) && right.is_a?(String)) || (left.is_a?(Numeric) && right.is_a?(Numeric)))
          return left + right
        else
          raise Ringo::Errors::RuntimeError.new(binary.operator, 'Operand must be two numbers or two strings.')
        end
      when :minus
        validate_number_operands(binary.operator, left, right)
        return left - right
      when :slash
        validate_number_operands(binary.operator, left, right)
        return left / right
      when :star
        validate_number_operands(binary.operator, left, right)
        return left * right
      when :greater
        validate_number_operands(binary.operator, left, right)
        return left > right
      when :greater_equal
        validate_number_operands(binary.operator, left, right)
        return left >= right
      when :less
        validate_number_operands(binary.operator, left, right)
        return left < right
      when :less_equal
        validate_number_operands(binary.operator, left, right)
        return left <= right
      when :bang_equal
        return !is_equal?(left, right)
      when :equal_equal
        return is_equal?(left, right)
      when :comma
        return right
      end

      return nil
    end

    # Handle function call expressions.
    def visit_call(call)
      callee = evaluate(call.callee)

      arguments = []
      call.arguments.each do |arg|
        arguments << evaluate(arg)
      end

      if !callee.respond_to?(:call)
        raise Ringo::Errors.new(call.paren, 'Can only call functions and classes.')
      end

      function = callee
      if arguments.length != function.arity
        raise Ringo::Errors::RuntimeError.new(call.paren, "Expected #{function.arity} arguments but got #{arguments.length}.")
      end

      function.call(self, arguments)
    end

    # Handle assignment expressions. This re-assigns a new value to an existing
    # variable. If the variable name does not exist already a runtime error is raised.
    def visit_assign(assignment)
      value = evaluate(assignment.value)

      @environment.assign(assignment.name, value)
      return value
    end

    # Handle the ternary conditional operator. It first evaluates the main expression,
    # if it is true the +then_branch+ expression is evaluated, otherwise the +else_branch+
    # is evaluated. No time is spent evaluating the branch that is not picked.
    def visit_conditional(conditional)
      expr = evaluate(conditional.expression)

      return evaluate(conditional.then_branch) if is_truthy?(expr)
      return evaluate(conditional.else_branch)
    end

    # Handle the logical operators 'and', 'or'.
    def visit_logical(logical)
      left = evaluate(logical.left)

      if logical.operator.type == :or
        return left if is_truthy?(left)
      else
        return left if !is_truthy?(left)
      end

      return evaluate(logical.right)
    end

    # Handle unary expressions.
    def visit_unary(unary)
      right = evaluate(unary.right)

      case unary.operator.type
      when :minus
        validate_number_operands(unary.operator, right)
        return -right
      when :bang
        return !is_truthy?(right)
      end

      return nil
    end

    # Handle literal expressions. The literal value was stored in the token during
    # scanning, so this is simple.
    def visit_literal(literal)
      literal.value
    end

    # Hanle a grouping expression.
    def visit_grouping(grouping)
      evaluate(grouping.expression)
    end

    # Execute a set of statements. This also provides the new local environment
    # for the block. The block local environment shadows the current environment
    # for the duration of the statements.
    # TODO: I don't really like how the environment switch is handled. Perhaps have a stack of
    #       environments, for each block entered push the new environment, then pop it at the end of the block.
    def execute_block(statements, environment)
      previous = @environment
      begin
        @environment = environment
        statements.each do |statement|
          execute(statement)
        end
      ensure
        @environment = previous
      end
    end

   private

    # Execute is the entry point for visiting statements. It calls +accept+ on
    # the given statement which then recursively calls +accept+ on the leaf nodes
    # in the AST.
    def execute(statement)
      statement.accept(self)
    end

    # Evaluate is the entry point for the visitor pattern. It calls +accept+ on
    # the given expression which then recursively calls +accept+ on the leaf nodes
    # in the AST.
    def evaluate(expression)
      expression.accept(self)
    end

    # The following rules determine truthiness:
    #
    # If value is nil or false return false.
    # Otherwise return true.
    def is_truthy?(value)
      return false if value.nil?
      return false if value.is_a?(FalseClass)
      return true
    end

    # Lox nil is equal to nil, otherwise use Ruby +:==+ to test equality.
    # TODO: Check the validity of this. There are a number of other ways in Ruby to check equality. Using the right one?
    def is_equal?(left, right)
      return true if left.nil? && right.nil?
      return left == right
    end

    # In Ruby nil.to_s is an empty string, so handle that here.
    def stringify(value)
      return 'nil' if value.nil?
      value.to_s
    end

    # Validate that all of the operands giver are of the Ruby top level number class
    # Numeric. This includes integers, doubles, etc.
    # If all of the operands are not Numeric then raise a runtime error.
    def validate_number_operands(token, *operands)
      return if operands.all? { |operand| operand.is_a?(Numeric) }
      raise Ringo::Errors::RuntimeError.new(token, 'Operand must be a number.')
    end
  end
end
