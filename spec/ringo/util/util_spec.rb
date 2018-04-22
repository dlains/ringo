require 'spec_helper'

RSpec.describe Ringo::Util do
  describe 'length' do
    it 'returns zero if the list is nil' do
      expect(Ringo::Util.length(nil)).to eq(0)
    end

    it 'returns zero if the list is empty' do
      expect(Ringo::Util.length([])).to eq(0)
    end

    it 'returns the correct size' do
      expect(Ringo::Util.length([1, 2, 3])).to eq(3)
    end

    it 'returns the correct size in the presence of sub lists' do
      expect(Ringo::Util.length([1, [2, 3], 3, 4])).to eq(4)
    end
  end

  describe 'element_at' do
    it 'raises an error if the list is empty' do
      expect{Ringo::Util.element_at([], 1)}.to raise_error(ArgumentError)
    end

    it 'raises an error if the list is nil' do
      expect{Ringo::Util.element_at(nil, 1)}.to raise_error(ArgumentError)
    end

    it 'returns the correct element' do
      expect(Ringo::Util.element_at([1, 2], 1)).to eq(2)
    end
  end

  describe 'duple' do
    it 'returns an empty list if count is zero' do
      expect(Ringo::Util.duple(0, 'a')).to eq([])
    end

    it 'returns a single element list if the count is one' do
      expect(Ringo::Util.duple(1, 'a')).to eq(['a'])
    end

    it 'returns a two element list if the count is two' do
      expect(Ringo::Util.duple(2, 'a')).to eq(['a','a'])
    end

    it 'can handle lists as the value' do
      expect(Ringo::Util.duple(2, [1, 2])).to eq([[1, 2], [1, 2]])
    end
  end

  describe 'down' do
    it 'raises an error if the list is nil' do
      expect{Ringo::Util.down(nil)}.to raise_error(ArgumentError)
    end

    it 'raises an error if the argument is not a list' do
      expect{Ringo::Util.down(1)}.to raise_error(ArgumentError)
    end

    it 'raises an error if the argument is empty' do
      expect{Ringo::Util.down([])}.to raise_error(ArgumentError)
    end

    it 'wraps a single element list correctly' do
      expect(Ringo::Util.down([1])).to eq([[1]])
    end

    it 'wraps a multiple element list correctly' do
      expect(Ringo::Util.down([1, 2, 3])).to eq([[1],[2],[3]])
    end

    it 'wraps a multiple element list with sub lists correctly' do
      expect(Ringo::Util.down([1, [2, 3], 4])).to eq([[1], [[2,3]], [4]])
    end
  end

  describe 'swapper' do
    it 'returns nil if the list is nil' do
      expect(Ringo::Util.swapper(1, 2, nil)).to be_nil
    end

    it 'returns an empty list if the argument is empty' do
      expect(Ringo::Util.swapper(1, 2, [])).to eq([])
    end

    it 'returns an list with the correct elements swapped' do
      expect(Ringo::Util.swapper(1, 2, [1, 2])).to eq([2, 1])
    end

    it 'correctly swaps elements in sub lists' do
      expect(Ringo::Util.swapper(1, 2, [1, 2, [3, 4, 1], [2]])).to eq([2, 1, [3, 4, 2], [1]])
    end
  end

  describe 'filter_in' do
    it 'returns nil if the list is nil' do
      expect(Ringo::Util.filter_in(nil, -> (elem) { elem.is_a?(Numeric) })).to be_nil
    end

    it 'returns an empty list if the argument is empty' do
      expect(Ringo::Util.filter_in([], -> (elem) { elem.is_a?(Numeric) })).to eq([])
    end

    it 'returns a filtered list of numbers' do
      expect(Ringo::Util.filter_in(['a', 2, 'b', 4], -> (elem) { elem.is_a?(Numeric) })).to eq([2, 4])
    end
  end

  describe 'every?' do
    it 'raises an error if the list is not an array' do
      expect{Ringo::Util.every?(1, -> (elem) { elem.is_a?(Numeric) })}.to raise_error(ArgumentError)
    end

    it 'returns true if the list is empty' do
      expect(Ringo::Util.every?([], -> (elem) { elem.is_a?(Numeric) })).to be_truthy
    end

    it 'returns false if an element in the list fails to satisfy the predicate' do
      expect(Ringo::Util.every?([1, 's'], -> (elem) { elem.is_a?(Numeric) })).to be_falsey
    end

    it 'returns true if all elements in the list satisfy the predicate' do
      expect(Ringo::Util.every?([1, 2], -> (elem) { elem.is_a?(Numeric) })).to be_truthy
    end
  end

  describe 'exists?' do
    it 'raises an error if the list is not an array' do
      expect{Ringo::Util.exists?(1, -> (elem) { elem.is_a?(Numeric) })}.to raise_error(ArgumentError)
    end

    it 'returns false if the list is empty' do
      expect(Ringo::Util.exists?([], -> (elem) { elem.is_a?(Numeric) })).to be_falsey
    end

    it 'returns false if all elements in the list fails to satisfy the predicate' do
      expect(Ringo::Util.exists?(['1', 's'], -> (elem) { elem.is_a?(Numeric) })).to be_falsey
    end

    it 'returns true if one element in the list satisfies the predicate' do
      expect(Ringo::Util.exists?(['1', 2], -> (elem) { elem.is_a?(Numeric) })).to be_truthy
    end
  end

  describe 'car' do
    it 'raises an error if the list is empty' do
      expect{Ringo::Util.car([])}.to raise_error(ArgumentError)
    end

    it 'raises an error if the argument is not a list' do
      expect{Ringo::Util.car(1)}.to raise_error(ArgumentError)
    end

    it 'returns the first character' do
      expect(Ringo::Util.car(['a','b','c'])).to eq('a')
    end

    it 'returns the first list' do
      expect(Ringo::Util.car([[1, 6], 2, 3])).to eq([1,6])
    end

    it 'returns the correct element when nested' do
      expect(Ringo::Util.car(Ringo::Util.car([[[3]], [4]]))).to eq([3])
    end
  end

  describe 'cdr' do
    it 'raises an error if the list is empty' do
      expect{Ringo::Util.cdr([])}.to raise_error(ArgumentError)
    end

    it 'raises an error if the argument is not a list' do
      expect{Ringo::Util.cdr(1)}.to raise_error(ArgumentError)
    end

    it 'returns the remaining characters' do
      expect(Ringo::Util.cdr(['a','b','c'])).to eq(['b','c'])
    end

    it 'returns the remaining list' do
      expect(Ringo::Util.cdr([[1, 6], [2], 3])).to eq([[2], 3])
    end

    it 'returns the correct element when nested' do
      expect(Ringo::Util.cdr(Ringo::Util.cdr([[1],[7,8],[[2]]]))).to eq([[[2]]])
    end
  end

  describe 'cons' do
    it 'raises an error if the argument is not a list' do
      expect{Ringo::Util.cons(1, 2)}.to raise_error(ArgumentError)
    end

    it 'adds numbers to the start of an empty list' do
      expect(Ringo::Util.cons(1, [])).to eq([1])
    end

    it 'adds numbers to the start of an existing list' do
      expect(Ringo::Util.cons(2, [1, 3])).to eq([2,1,3])
    end

    it 'adds a list to the start of an empty list' do
      expect(Ringo::Util.cons([1,2], [])).to eq([[1,2]])
    end

    it 'adds a list to the start of an existing list' do
      expect(Ringo::Util.cons([1,2], ['a'])).to eq([[1,2],'a'])
    end
  end
end
