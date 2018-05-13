require 'spec_helper'

RSpec.describe Ringo::Environment do
  subject { Ringo::Environment.new }

  describe '#define' do
    it 'creates an entry in the environment' do
      subject.define('x', 22)
      expect(subject.get('x')).to eq(22)
    end

    it 'creates a nil entry in the environment' do
      subject.define('x', nil)
      expect(subject.get('x')).to be_nil
    end
  end

  describe '#get' do
    it 'returns a value from the environment' do
      subject.define('x', 22)
      value = subject.get('x')
      expect(value).to eq(22)
    end

    it 'returns a nil value from the environment' do
      subject.define('x', nil)
      value = subject.get('x')
      expect(value).to be_nil
    end

    it 'raises a runtime error if the variable name does now exist' do
      expect{subject.get('x')}.to raise_error(Ringo::Errors::RuntimeError)
    end
  end
end
