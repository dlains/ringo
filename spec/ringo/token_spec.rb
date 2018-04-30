require 'spec_helper'

RSpec.describe Ringo::Token do
  subject { Ringo::Token.new(:lparen, '(', '(', 1) }

  describe '#type' do
    it 'returns the correct type' do
      expect(subject.type).to eq(:lparen)
    end
  end

  describe '#lexeme' do
    it 'returns the correct value' do
      expect(subject.lexeme).to eq('(')
    end
  end

  describe '#literal' do
    it 'returns the correct value' do
      expect(subject.literal).to eq('(')
    end
  end

  describe '#line' do
    it 'returns the correct value' do
      expect(subject.line).to eq(1)
    end
  end

  describe '#to_s' do
    it 'returs the string representation of the token' do
      expect(subject.to_s).to eq('lparen ( (')
    end
  end
end
