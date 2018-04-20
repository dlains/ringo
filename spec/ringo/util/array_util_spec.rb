require 'spec_helper'

RSpec.describe Ringo::Util::ArrayUtil do
  subject { Ringo::Util::ArrayUtil.new }

  describe 'length' do
    it 'returns zero if the array is nil' do
      expect(subject.length(nil)).to eq(0)
    end

    it 'returns zero if the array is empty' do
      expect(subject.length([])).to eq(0)
    end

    it 'returns the correct size' do
      expect(subject.length([1, 2, 3])).to eq(3)
    end

    it 'returns the correct size in the presence of sub arrays' do
      expect(subject.length([1, [2, 3], 3, 4])).to eq(4)
    end
  end

  describe 'element_at' do
    it 'raises an error if the array is empty' do
      expect{subject.element_at([], 1)}.to raise_error(ArgumentError)
    end

    it 'raises an error if the array is nil' do
      expect{subject.element_at(nil, 1)}.to raise_error(ArgumentError)
    end

    it 'returns the correct element' do
      expect(subject.element_at([1, 2], 1)).to eq(2)
    end
  end
end
