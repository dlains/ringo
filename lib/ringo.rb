require 'ringo/runner'
require 'ringo/token'
require 'ringo/version'
require 'ringo/environment'

require 'ringo/lox_callable'
require 'ringo/lox_function'
require 'ringo/lox_class'
require 'ringo/lox_instance'
require 'ringo/clock'

require 'ringo/scanner/lox_scanner'
require 'ringo/parser/lox_parser'
require 'ringo/interpreter/lox_interpreter'
require 'ringo/resolver/lox_resolver'
require 'ringo/tools/node_generator'
require 'ringo/tools/ast_printer'

require 'ringo/errors/parse_error'
require 'ringo/errors/runtime_error'
require 'ringo/errors/return'

module Ringo
  # Generate the AST node classes defined in node_descriptions.yml.
  Tools::NodeGenerator.run("#{__dir__}/ringo/tools/node_descriptions.yml")

  @@had_error = false
  @@had_runtime_error = false

  def self.had_error?
    @@had_error
  end

  def self.had_runtime_error?
    @@had_runtime_error
  end

  def self.error(token, message)
    if token.type == :eof
      report_error(token.line, " at end #{message}")
    else
      report_error(token.line, " at '#{token.lexeme}' #{message}")
    end
  end

  def self.runtime_error(error)
    STDERR.puts "#{error.message} [line: #{error.token.line}]"
    @@had_runtime_error = true
  end

  def self.report_error(line, message)
    STDERR.puts "[line: #{line}]: #{message}"
    @@had_error = true
  end

end
