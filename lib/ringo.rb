require 'ringo/runner'
require 'ringo/token'
require 'ringo/version'
require 'ringo/util'

require 'ringo/scanner/lox_scanner'

module Ringo
  @@had_error = false

  def self.had_error?
    @@had_error
  end

  def self.report_error(line, message)
    STDERR.puts "[line: #{line}]: #{message}"
    @@had_error = true
  end

end
