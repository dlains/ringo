module Ringo::Tools

  # Show a visual representation of the passed in expression.
  class AstPrinter
    def print(expression)
      expression.accept(self)
    end

    def visit_binary(binary)
      parenthesize(binary.operator.lexeme, binary.left, binary.right)
    end

    def visit_conditional(conditional)
      parenthesize('?', conditional.expression, conditional.then_branch, conditional.else_branch)
    end

    def visit_grouping(grouping)
      parenthesize('group', grouping.expression)
    end

    def visit_literal(literal)
      literal.value
    end

    def visit_unary(unary)
      parenthesize(unary.operator.lexeme, unary.right)
    end

    # TODO: Add the remaining visitor methods as they are defined.

    private

    def parenthesize(name, *args)
      "(#{name} #{args.map { |arg| arg.accept(self) }.join(' ')})"
    end
  end
end
