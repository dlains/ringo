require 'spec_helper'

RSpec.describe Ringo::Environment do
  subject     { Ringo::Environment.new }
  let(:token) { Ringo::Token.new(:identifier, 'x', nil, 1) }

  describe '#define' do
    it 'creates an entry in the environment' do
      subject.define(token, 22)
      expect(subject.get('x')).to eq(22)
    end

    it 'creates a nil entry in the environment' do
      subject.define(token, nil)
      expect(subject.get('x')).to be_nil
    end
  end

  describe '#assign' do
    it 'sets a new value for an existing entry' do
      subject.define(token, 22)
      subject.assign(token, 1)
      expect(subject.get('x')).to eq(1.0)
    end

    it 'raises a runtime error if the variable name does not exist' do
      expect{subject.assign(token, 22)}.to raise_error(Ringo::Errors::RuntimeError)
    end

    it 'searches enclosing scopes if the variable is not found' do
      subject.define(token, 22)
      local_scope = Ringo::Environment.new(subject)
      local_scope.define(Ringo::Token.new(:identifier, 'y', nil, 2), 32)
      local_scope.assign(token, 1)
      expect(local_scope.get('x')).to eq(1.0)
    end
  end

  describe '#get' do
    it 'returns a value from the environment' do
      subject.define(token, 22)
      expect(subject.get('x')).to eq(22)
    end

    it 'returns a nil value from the environment' do
      subject.define(token, nil)
      expect(subject.get('x')).to be_nil
    end

    it 'raises a runtime error if the variable name does now exist' do
      expect{subject.get(token)}.to raise_error(Ringo::Errors::RuntimeError)
    end

    it 'searches enclosing scopes if the variable is not found' do
      subject.define(token, 22)
      local_scope = Ringo::Environment.new(subject)
      local_scope.define(Ringo::Token.new(:identifier, 'y', nil, 2), 32)
      expect(local_scope.get('x')).to eq(22.0)
    end
  end
end
