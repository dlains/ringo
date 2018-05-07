require 'bundler/setup'
require 'byebug'
require 'ringo'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Helper to create a LoxScanner with the supplied source code.
def make_scanner(source)
  scanner = Ringo::Scanner::LoxScanner.new(source)
  scanner.scan
  scanner
end

# Helper to create a printed AST tree from the provided source code.
def make_ast(source)
  scanner = make_scanner(source)
  parser = Ringo::Parser::LoxParser.new(scanner.tokens)
  Ringo::Tools::AstPrinter.new.print(parser.parse)
end
