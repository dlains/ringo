require 'spec_helper'

RSpec.describe Ringo::Interpreter::LoxInterpreter do
  subject { Ringo::Interpreter::LoxInterpreter.new }

  describe '#interpret' do
    it 'can evaluate an addition expression' do
      expression = make_expression('2 + 4')
      expect(subject.interpret(expression)).to eq('6.0')
    end

    it 'can evaluate a string contatenation expression' do
      expression = make_expression('"Hello," + " world!"')
      expect(subject.interpret(expression)).to eq('Hello, world!')
    end

    it 'can evaluate a grouping expression correctly' do
      expression = make_expression('(5 - 1) * 4')
      expect(subject.interpret(expression)).to eq('16.0')
    end

    it 'can evaluate a greater than expression correctly' do
      expression = make_expression('5 >= 9')
      expect(subject.interpret(expression)).to eq('false')
    end

    it 'can evaluate greater expression correctly' do
      expression = make_expression('5 > 2')
      expect(subject.interpret(expression)).to eq('true')
    end

    it 'can evaluate a less than expression correctly' do
      expression = make_expression('9 <= 8')
      expect(subject.interpret(expression)).to eq('false')
    end

    it 'can evaluate less expression correctly' do
      expression = make_expression('2 < 5')
      expect(subject.interpret(expression)).to eq('true')
    end

    it 'can evaluate an equivalence expression' do
      expression = make_expression('1 == 1')
      expect(subject.interpret(expression)).to eq('true')
    end

    it 'can evaluate a not equal expression' do
      expression = make_expression('1 != 1')
      expect(subject.interpret(expression)).to eq('false')
    end

    it 'can evaluate a comma expression' do
      expression = make_expression('2 - 1, 3 * 5')
      expect(subject.interpret(expression)).to eq('15.0')
    end

    it 'can evaluate a true conditional expression' do
      expression = make_expression('1 <= 2 ? 3 + 3 : 4 + 4')
      expect(subject.interpret(expression)).to eq('6.0')
    end

    it 'can evaluate a false conditional expression' do
      expression = make_expression('1 >= 2 ? 3 + 3 : 4 + 4')
      expect(subject.interpret(expression)).to eq('8.0')
    end
  end
end
