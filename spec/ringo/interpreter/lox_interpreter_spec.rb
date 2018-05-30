require 'spec_helper'

RSpec.describe Ringo::Interpreter::LoxInterpreter do
  subject { Ringo::Interpreter::LoxInterpreter.new }

  describe '#interpret' do
    it 'can evaluate an addition expression' do
      statements = make_statements('print 2 + 4;', subject)
      expect{subject.interpret(statements)}.to output("6.0\n").to_stdout
    end

    it 'can evaluate a string contatenation expression' do
      statements = make_statements('print "Hello," + " world!";', subject)
      expect{subject.interpret(statements)}.to output("Hello, world!\n").to_stdout
    end

    it 'can evaluate a grouping expression correctly' do
      statements = make_statements('print (5 - 1) * 4;', subject)
      expect{subject.interpret(statements)}.to output("16.0\n").to_stdout
    end

    it 'can evaluate a greater than expression correctly' do
      statements = make_statements('print 5 >= 9;', subject)
      expect{subject.interpret(statements)}.to output("false\n").to_stdout
    end

    it 'can evaluate greater expression correctly' do
      statements = make_statements('print 5 > 2;', subject)
      expect{subject.interpret(statements)}.to output("true\n").to_stdout
    end

    it 'can evaluate a less than expression correctly' do
      statements = make_statements('print 9 <= 8;', subject)
      expect{subject.interpret(statements)}.to output("false\n").to_stdout
    end

    it 'can evaluate less expression correctly' do
      statements = make_statements('print 2 < 5;', subject)
      expect{subject.interpret(statements)}.to output("true\n").to_stdout
    end

    it 'can evaluate an equivalence expression' do
      statements = make_statements('print 1 == 1;', subject)
      expect{subject.interpret(statements)}.to output("true\n").to_stdout
    end

    it 'can evaluate a not equal expression' do
      statements = make_statements('print 1 != 1;', subject)
      expect{subject.interpret(statements)}.to output("false\n").to_stdout
    end

    it 'can evaluate a comma expression' do
      statements = make_statements('print 2 - 1, 3 * 5;', subject)
      expect{subject.interpret(statements)}.to output("15.0\n").to_stdout
    end

    it 'can evaluate a true conditional expression' do
      statements = make_statements('print 1 <= 2 ? 3 + 3 : 4 + 4;', subject)
      expect{subject.interpret(statements)}.to output("6.0\n").to_stdout
    end

    it 'can evaluate a false conditional expression' do
      statements = make_statements('print 1 >= 2 ? 3 + 3 : 4 + 4;', subject)
      expect{subject.interpret(statements)}.to output("8.0\n").to_stdout
    end

    it 'can handle variable declarations' do
      statements = make_statements('var a = 1;print a;', subject)
      expect{subject.interpret(statements)}.to output("1.0\n").to_stdout
    end

    it 'initializes a variable to nil' do
      statements = make_statements('var a;print a;', subject)
      expect{subject.interpret(statements)}.to output("nil\n").to_stdout
    end

    it 'can handle variable re-assignment' do
      statements = make_statements("var a = 1;\nprint a;\na = 2;\nprint a;\n", subject)
      expect{subject.interpret(statements)}.to output("1.0\n2.0\n").to_stdout
    end

    it 'can handle blocks of statements and local scopes' do
      statements = make_statements("var a = 1.0;\nvar b = 2.0;\n{\nvar a = 10.0;\nprint a;\nprint b;\n}print a;\nprint b;\n", subject)
      expect{subject.interpret(statements)}.to output("10.0\n2.0\n1.0\n2.0\n").to_stdout
    end

    it 'can handle a true conditional statement' do
      statements = make_statements("var a = 10;if (a < 20) print a;", subject)
      expect{subject.interpret(statements)}.to output("10.0\n").to_stdout
    end

    it 'can handle a false conditional statement' do
      statements = make_statements("var a = 10;if (a < 10) print a; else print \"Not Less\";", subject)
      expect{subject.interpret(statements)}.to output("Not Less\n").to_stdout
    end

    it 'can handle a logical or statement' do
      statements = make_statements('print "hi" or 2;print nil or "yes";', subject)
      expect{subject.interpret(statements)}.to output("hi\nyes\n").to_stdout
    end

    it 'can handle a logical and statement' do
      statements = make_statements('print "hi" and "low";print "low" and nil;', subject)
      expect{subject.interpret(statements)}.to output("low\nnil\n").to_stdout
    end

    it 'can handle a while loop' do
      statements = make_statements('var i = 0;while(i < 5) { print i; i = i + 1; }', subject)
      expect{subject.interpret(statements)}.to output("0.0\n1.0\n2.0\n3.0\n4.0\n").to_stdout
    end

    it 'can process a for loop' do
      statements = make_statements('var i;for(i = 0;i < 5; i = i + 1) { print i; }', subject)
      expect{subject.interpret(statements)}.to output("0.0\n1.0\n2.0\n3.0\n4.0\n").to_stdout
    end

    it 'can process a simple function' do
      statements = make_statements('fun hi(first, last) { print "Hi, " + first + " " + last + "!"; } hi("Dear", "Reader");', subject)
      expect{subject.interpret(statements)}.to output("Hi, Dear Reader!\n").to_stdout
    end

    it 'can process a function with a return statement', force: true do
      statements = make_statements('fun addtwo(num) { return num + 2; } print addtwo(4);', subject)
      expect{subject.interpret(statements)}.to output("6.0\n").to_stdout
    end

    it 'can print a class name' do
      statements = make_statements('class Testing { test() { return "Success"; } } print Testing;', subject)
      expect{subject.interpret(statements)}.to output("Testing\n").to_stdout
    end

    it 'can instantiate a class' do
      statements = make_statements('class Testing {} var test = Testing(); print test;', subject)
      expect{subject.interpret(statements)}.to output("Testing instance\n").to_stdout
    end

    it 'can set and get a property' do
      statements = make_statements('class Testing {} var test = Testing(); test.data = "data"; print test.data;', subject)
      expect{subject.interpret(statements)}.to output("data\n").to_stdout
    end

    it 'can call a method on an instance' do
      statements = make_statements('class Testing { run() { print "Running!"; } } Testing().run();', subject)
      expect{subject.interpret(statements)}.to output("Running!\n").to_stdout
    end
  end
end
