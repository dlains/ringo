require 'readline'

module Ringo

  # Ringo::Runner kicks off the ringo interpreter process. It runs the given
  # script or starts an interactive session depending on the command line arguments.
  # TODO: Figure out how to handle errors. The Ringo module has error reporting methods,
  #       but they aren't being used yet.
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
      scanner.tokens.each do |token|
        puts token
      end
    end
  end

end
