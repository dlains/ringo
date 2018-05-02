require 'spec_helper'

RSpec.describe Ringo::Tools::AstPrinter do
  describe '#print' do
    it 'correctly prints a single binary expression' do
      exp = Ringo::Binary.new(Ringo::Literal.new('32'), Ringo::Token.new(:plus, '+', nil, 1), Ringo::Literal.new('11'))
      result = Ringo::Tools::AstPrinter.new.print(exp)
      expect(result).to eq("(+ 32 11)")
    end

    it 'correctly prints a multi-part expression' do
      exp = Ringo::Binary.new(
        Ringo::Unary.new(
          Ringo::Token.new(:minus, '-', nil, 1),
          Ringo::Literal.new(123)
        ),
        Ringo::Token.new(:star, '*', nil, 1),
        Ringo::Grouping.new(Ringo::Literal.new(45.67))
      )
      result = Ringo::Tools::AstPrinter.new.print(exp)
      expect(result).to eq("(* (- 123) (group 45.67))")
    end
  end
end
