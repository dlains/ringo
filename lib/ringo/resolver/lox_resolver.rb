module Ringo::Resolver
  class LoxResolver
    def initialize(interpreter)
      @interpreter = interpreter
      @scopes = []
    end

    def visit_block(block)
      begin_scope
      block.statements.each do |statement|
        resolve(statement)
      end
      end_scope
      return nil
    end

    def visit_var(var)
      declare(var.name)
      resolve(var.initializer) unless var.initializer.nil?
      define(var.name)
      return nil
    end

    private

    def resolve(resolvee)
      resolvee.accept(self)
    end

    def begin_scope
      scopes.push(Hash.new)
    end

    def end_scope
      scopes.pop
    end

    def declare(token)
      return nil if @scopes.empty?
      @scopes.last.put(token.lexeme, false)
    end

    def define(token)
      return nil if @scopes.empty?
      @scopes.last.put(token.lexeme, true)
    end
  end
end
