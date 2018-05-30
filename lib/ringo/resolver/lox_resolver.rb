module Ringo::Resolver
  class LoxResolver
    # Function type constants allow the code to detect return statements
    # that are not within an actual function.
    FUNCTION_TYPE_NONE = 1
    FUNCTION_TYPE_FUNCTION = 2
    FUNCTION_TYPE_METHOD = 3

    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = []
      @current_function_type = FUNCTION_TYPE_NONE
    end

    def resolve(statements)
      statements.each do |statement|
        resolve_stmt(statement)
      end
    end

    def visit_block(block)
      begin_scope
      block.statements.each do |statement|
        resolve_stmt(statement)
      end
      end_scope
      return nil
    end

    def visit_var(var)
      declare(var.name)
      resolve_stmt(var.initializer) unless var.initializer.nil?
      define(var.name)
      return nil
    end

    def visit_variable(expression)
      if !@scopes.empty? && @scopes.last[expression.name.lexeme] == false
        Ringo.error(expression.name, "Cannot read local variable in its own initializer.")
      end

      resolve_local(expression, expression.name)
      return nil
    end

    def visit_assign(expression)
      resolve_expr(expression.value)
      resolve_local(expression, expression.name)
      return nil
    end

    def visit_function(statement)
      declare(statement.name)
      define(statement.name)

      resolve_function(statement, FUNCTION_TYPE_FUNCTION)
      return nil
    end

    def visit_class(statement)
      declare(statement.name)
      define(statement.name)

      statement.methods.each do |method|
        resolve_function(method, FUNCTION_TYPE_METHOD)
      end

      return nil
    end

    def visit_expression(statement)
      resolve_stmt(statement.expression)
      return nil
    end

    def visit_if(statement)
      resolve_stmt(statement.condition)
      resolve_stmt(statement.then_branch)
      resolve_stmt(statement.else_branch) unless statement.else_branch.nil?
      return nil
    end

    def visit_print(statement)
      resolve_stmt(statement.expression)
      return nil
    end

    def visit_return(statement)
      if @current_function_type == FUNCTION_TYPE_NONE
        Ringo.error(statement.keyword, "Can not return from top-level code.")
      end
      resolve_stmt(statement.value) unless statement.value.nil?
      return nil
    end

    def visit_while(statement)
      resolve_stmt(statement.condition)
      resolve_stmt(statement.body)
      return nil
    end

    def visit_binary(expression)
      resolve_expr(expression.left)
      resolve_expr(expression.right)
      return nil
    end

    def visit_call(expression)
      resolve_expr(expression.callee)
      expression.arguments.each do |arg|
        resolve_expr(arg)
      end

      return nil
    end

    def visit_get(expression)
      resolve_expr(expression.object)
      return nil
    end

    def visit_conditional(expression)
      resolve_expr(expression.expression)
      resolve_expr(expression.then_branch)
      resolve_expr(expression.else_branch)
      return nil
    end

    def visit_grouping(expression)
      resolve_expr(expression.expression)
      return nil
    end

    def visit_literal(expression)
      return nil
    end

    def visit_logical(expression)
      resolve_expr(expression.left)
      resolve_expr(expression.right)
      return nil
    end

    def visit_set(expression)
      resolve_expr(expression.value)
      resolve_expr(expression.object)
      return nil
    end

    def visit_unary(expression)
      resolve_expr(expression.right)
      return nil
    end

    private

    def resolve_stmt(statement)
      statement.accept(self)
    end

    def resolve_expr(expression)
      expression.accept(self)
    end

    def resolve_function(function, function_type)
      enclosing_function_type = @current_function_type
      @current_function_type = function_type

      begin_scope
      function.parameters.each do |param|
        declare(param)
        define(param)
      end
      resolve(function.body)
      end_scope
      @current_function_type = enclosing_function_type
    end

    def begin_scope
      @scopes.push(Hash.new)
    end

    def end_scope
      @scopes.pop
    end

    def declare(token)
      return nil if @scopes.empty?
      scope = @scopes.last
      if scope.has_key?(token.lexeme)
        Ringo.error("Variable with this name already declared in this scope.")
      end
      scope[token.lexeme] = false
    end

    def define(token)
      return nil if @scopes.empty?
      @scopes.last[token.lexeme] = true
    end

    def resolve_local(expression, token)
      reversed = @scopes.reverse
      reversed.each_index do |i|
        if reversed.at(i).has_key?(token.lexeme)
          @interpreter.resolve(expression, i)
          return
        end
      end

      # Not found, assume it is global.
    end

  end
end
