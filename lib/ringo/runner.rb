require 'readline'

module Ringo

  # Ringo::Runner kicks off the ringo interpreter process. It runs the given
  # script or starts an interactive session depending on the command line arguments.
  class Runner

    def run_file(file)
      File.open(file, 'r') do |file|
        source = file.read
        run(source)
      end
    end

    def run_prompt()
      loop do
        source = Readline.readline('> ', true)
        break if source.strip == 'exit'
        run(source)
      end
    end

    private

    def run(source)
      scanner = Ringo::Scanner::LoxScanner.new(source)
      scanner.scan
      parser  = Ringo::Parser::LoxParser.new(scanner.tokens)
      statements = parser.parse

      # Stop if there was an error.
      # If there was an error reported during the parse step
      # don't try to run the code.
      return if Ringo.had_error?

      resolver = Ringo::Resolver::LoxResolver.new(interpreter)
      resolver.resolve(statements)

      # If there was an error reported during the resolve step
      # don't try to run the code.
      return if Ringo.had_error?

      interpreter.interpret(statements)
    end

    def interpreter
      @interpreter ||= Ringo::Interpreter::LoxInterpreter.new
    end
  end

end
