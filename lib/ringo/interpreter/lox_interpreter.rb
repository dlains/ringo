module Ringo::Interpreter

  # The LoxInterpreter is a tree walk interpreter for the Lox language. It uses the
  # visitor pattern to recursively walk through the AST nodes provided by the
  # LoxParser and performs the actions specified in the source code.
  class LoxInterpreter

    # Kick off the interpreter for the given expression. If a runtime error occurs
    # it is caught here and reported to the Ringo error routines, otherwise a
    # string representation of the result of the expression is returned to the caller.
    def interpret(expression)
      value = evaluate(expression)
      stringify(value)
    rescue Ringo::Errors::RuntimeError => error
      Ringo.runtime_error(error)
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

    # Handle the ternary conditional operator. It first evaluates the main expression,
    # if it is true the +then_branch+ expression is evaluated, otherwise the +else_branch+
    # is evaluated. No time is spent evaluating the branch that is not picked.
    def visit_conditional(conditional)
      expr = evaluate(conditional.expression)

      return evaluate(conditional.then_branch) if is_truthy?(expr)
      return evaluate(conditional.else_branch)
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

    private

    # Evaluate is the entry point for the visitor pattern. It calles +accept+ on
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
