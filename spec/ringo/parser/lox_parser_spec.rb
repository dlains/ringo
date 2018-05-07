require 'spec_helper'

RSpec.describe Ringo::Parser::LoxParser do
  describe '#parse' do
    it 'correctly parses an equivalence expression' do
      result = make_ast('(3 + 4) == 7')
      expect(result).to eq('(== (group (+ 3.0 4.0)) 7.0)')
    end

    it 'correctly parses a comparison expression' do
      result = make_ast('3 * 4 >= 4')
      expect(result).to eq('(>= (* 3.0 4.0) 4.0)')
    end

    it 'correctly parses an addition and multiplications expression' do
      result = make_ast('3 + 4 * 5')
      expect(result).to eq('(+ 3.0 (* 4.0 5.0))')
    end

    it 'correctly parses a unary expression' do
      result = make_ast('-2 * 20')
      expect(result).to eq('(* (- 2.0) 20.0)')
    end
  end
end