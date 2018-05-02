require 'ringo/runner'
require 'ringo/token'
require 'ringo/version'
require 'ringo/util'

require 'ringo/scanner/lox_scanner'
require 'ringo/tools/node_generator'
require 'ringo/tools/ast_printer'

module Ringo
  # Generate the AST node classes defined in node_descriptions.yml.
  Tools::NodeGenerator.run("#{__dir__}/ringo/tools/node_descriptions.yml")

  @@had_error = false

  def self.had_error?
    @@had_error
  end

  def self.report_error(line, message)
    STDERR.puts "[line: #{line}]: #{message}"
    @@had_error = true
  end

end
