require 'spec_helper'

RSpec.describe Ringo::Scanner::LoxScanner do
  describe '#tokens' do
    it 'adds an eof token if source is empty' do
      scanner = make_scanner('')
      expect(scanner.tokens.length).to eq(1)
      expect(scanner.tokens[0].to_s).to eq('eof')
    end

    it 'displays an error if an unknown character is found' do
      scanner = Ringo::Scanner::LoxScanner.new('^')
      expect(Ringo).to receive(:report_error).with(1, 'Unexpected character')
      scanner.scan
    end

    it 'handles single character lexemes' do
      scanner = make_scanner('(){}')
      expect(scanner.tokens.length).to eq(5)
      expect(scanner.tokens[0].lexeme).to eq('(')
      expect(scanner.tokens[1].lexeme).to eq(')')
      expect(scanner.tokens[2].lexeme).to eq('{')
      expect(scanner.tokens[3].lexeme).to eq('}')
      expect(scanner.tokens[4].type).to eq(:eof)
    end

    it 'handles the equal operator' do
      scanner = make_scanner('=')
      expect(scanner.tokens.length).to eq(2)
      expect(scanner.tokens[0].lexeme).to eq('=')
      expect(scanner.tokens[0].type).to eq(:equal)
      expect(scanner.tokens[1].type).to eq(:eof)
    end

    it 'handles the not equal operator' do
      scanner = make_scanner('!=')
      expect(scanner.tokens.length).to eq(2)
      expect(scanner.tokens[0].lexeme).to eq('!=')
      expect(scanner.tokens[0].type).to eq(:bang_equal)
      expect(scanner.tokens[1].type).to eq(:eof)
    end

    it 'handles the equal equal operator' do
      scanner = make_scanner('==')
      expect(scanner.tokens.length).to eq(2)
      expect(scanner.tokens[0].lexeme).to eq('==')
      expect(scanner.tokens[0].type).to eq(:equal_equal)
      expect(scanner.tokens[1].type).to eq(:eof)
    end

    it 'handles comments' do
      scanner = make_scanner("() // this is a comment\n{}")
      expect(scanner.tokens.length).to eq(5)
      expect(scanner.tokens[0].lexeme).to eq('(')
      expect(scanner.tokens[1].lexeme).to eq(')')
      expect(scanner.tokens[2].lexeme).to eq('{')
      expect(scanner.tokens[3].lexeme).to eq('}')
      expect(scanner.tokens[4].type).to eq(:eof)
    end

    it 'ignores whitespace' do
      scanner = make_scanner("{      }\n\t.")
      expect(scanner.tokens.length).to eq(4)
      expect(scanner.tokens[0].lexeme).to eq('{')
      expect(scanner.tokens[1].lexeme).to eq('}')
      expect(scanner.tokens[2].lexeme).to eq('.')
      expect(scanner.tokens[3].type).to eq(:eof)
    end

    it 'can find string literals' do
      scanner = make_scanner('; "strung"')
      expect(scanner.tokens.length).to eq(3)
      expect(scanner.tokens[0].lexeme).to eq(';')
      expect(scanner.tokens[1].type).to eq(:string)
      expect(scanner.tokens[1].literal).to eq('strung')
      expect(scanner.tokens[2].type).to eq(:eof)
    end

    it 'can find a number literal' do
      scanner = make_scanner('(123)')
      expect(scanner.tokens.length).to eq(4)
      expect(scanner.tokens[0].lexeme).to eq('(')
      expect(scanner.tokens[1].lexeme).to eq('123')
      expect(scanner.tokens[1].literal).to eq(123)
      expect(scanner.tokens[2].lexeme).to eq(')')
      expect(scanner.tokens[3].type).to eq(:eof)
    end

    it 'can find a floating point number literal' do
      scanner = make_scanner('(123.002)')
      expect(scanner.tokens.length).to eq(4)
      expect(scanner.tokens[0].lexeme).to eq('(')
      expect(scanner.tokens[1].lexeme).to eq('123.002')
      expect(scanner.tokens[1].literal).to eq(123.002)
      expect(scanner.tokens[2].lexeme).to eq(')')
      expect(scanner.tokens[3].type).to eq(:eof)
    end

    it 'can find keywords' do
      scanner = make_scanner('(1 and 2)')
      expect(scanner.tokens.length).to eq(6)
      expect(scanner.tokens[0].lexeme).to eq('(')
      expect(scanner.tokens[1].lexeme).to eq('1')
      expect(scanner.tokens[2].lexeme).to eq('and')
      expect(scanner.tokens[3].lexeme).to eq('2')
      expect(scanner.tokens[4].lexeme).to eq(')')
      expect(scanner.tokens[5].type).to eq(:eof)
    end

    it 'can find identifiers' do
      scanner = make_scanner('var something = 1')
      expect(scanner.tokens.length).to eq(5)
      expect(scanner.tokens[0].lexeme).to eq('var')
      expect(scanner.tokens[0].type).to eq(:var)
      expect(scanner.tokens[1].lexeme).to eq('something')
      expect(scanner.tokens[1].type).to eq(:identifier)
      expect(scanner.tokens[2].lexeme).to eq('=')
      expect(scanner.tokens[3].lexeme).to eq('1')
      expect(scanner.tokens[4].type).to eq(:eof)
    end

    it 'can find identifiers that start with an underscore' do
      scanner = make_scanner('var _something = 1')
      expect(scanner.tokens.length).to eq(5)
      expect(scanner.tokens[0].lexeme).to eq('var')
      expect(scanner.tokens[0].type).to eq(:var)
      expect(scanner.tokens[1].lexeme).to eq('_something')
      expect(scanner.tokens[1].type).to eq(:identifier)
      expect(scanner.tokens[2].lexeme).to eq('=')
      expect(scanner.tokens[3].lexeme).to eq('1')
      expect(scanner.tokens[4].type).to eq(:eof)
    end
  end

  def make_scanner(source)
    scanner = Ringo::Scanner::LoxScanner.new(source)
    scanner.scan
    scanner
  end
end
