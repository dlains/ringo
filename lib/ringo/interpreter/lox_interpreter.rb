module Ringo::Interpreter
  class LoxInterpreter

    def visit_binary(binary)
      left = evaluate(binary.left)
      right = evaluate(binary.right)

      case binary.operator.type
      when :plus
        return left + right
      when :minus
        return left - right
      when :slash
        return left / right
      when :star
        return left * right
      when :greater
        return left > right
      when :greater_equal
        return left >= right
      when :less
        return left < right
      when :less_equal
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
  end
end
