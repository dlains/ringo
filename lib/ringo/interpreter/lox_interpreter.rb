module Ringo::Interpreter
  class LoxInterpreter

    def interpret(expression)
      value = evaluate(expression)
      puts stringify(value)
    rescue Ringo::Errors::RuntimeError => error
      Ringo.runtime_error(error)
    end

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
      end

      return nil
    end

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

    def visit_literal(literal)
      literal.value
    end

    def visit_grouping(grouping)
      evaluate(grouping.expression)
    end

    private

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

    def is_equal?(left, right)
      return true if left.nil? && right.nil?
      return left == right
    end

    def stringify(value)
      return 'nil' if value.nil?
      value.to_s
    end

    def validate_number_operands(token, *operands)
      return if operands.all? { |operand| operand.is_a?(Numeric) }
      raise Ringo::Errors::RuntimeError.new(token, 'Operand must be a number.')
    end

    def validate_number_or_string_operands(token, *operands)
      all_number = operands.all? {|operand| operand.is_a?(Numeric) }
      return if operands.all? { |operand| operand.is_a?(Numeric) || operand.is_a?(String) }
      raise Ringo::Errors::RuntimeError.new(token, 'Operand must be a number or a string.')
    end
  end
end
