require 'spec_helper'

RSpec.describe Ringo::Interpreter::LoxInterpreter do
  subject { Ringo::Interpreter::LoxInterpreter.new }

  describe '#interpret' do
    it 'can evaluate an addition expression' do
      statements = make_statements('print 2 + 4;')
      expect{subject.interpret(statements)}.to output("6.0\n").to_stdout
    end

    it 'can evaluate a string contatenation expression' do
      statements = make_statements('print "Hello," + " world!";')
      expect{subject.interpret(statements)}.to output("Hello, world!\n").to_stdout
    end

    it 'can evaluate a grouping expression correctly' do
      statements = make_statements('print (5 - 1) * 4;')
      expect{subject.interpret(statements)}.to output("16.0\n").to_stdout
    end

    it 'can evaluate a greater than expression correctly' do
      statements = make_statements('print 5 >= 9;')
      expect{subject.interpret(statements)}.to output("false\n").to_stdout
    end

    it 'can evaluate greater expression correctly' do
      statements = make_statements('print 5 > 2;')
      expect{subject.interpret(statements)}.to output("true\n").to_stdout
    end

    it 'can evaluate a less than expression correctly' do
      statements = make_statements('print 9 <= 8;')
      expect{subject.interpret(statements)}.to output("false\n").to_stdout
    end

    it 'can evaluate less expression correctly' do
      statements = make_statements('print 2 < 5;')
      expect{subject.interpret(statements)}.to output("true\n").to_stdout
    end

    it 'can evaluate an equivalence expression' do
      statements = make_statements('print 1 == 1;')
      expect{subject.interpret(statements)}.to output("true\n").to_stdout
    end

    it 'can evaluate a not equal expression' do
      statements = make_statements('print 1 != 1;')
      expect{subject.interpret(statements)}.to output("false\n").to_stdout
    end

    it 'can evaluate a comma expression' do
      statements = make_statements('print 2 - 1, 3 * 5;')
      expect{subject.interpret(statements)}.to output("15.0\n").to_stdout
    end

    it 'can evaluate a true conditional expression' do
      statements = make_statements('print 1 <= 2 ? 3 + 3 : 4 + 4;')
      expect{subject.interpret(statements)}.to output("6.0\n").to_stdout
    end

    it 'can evaluate a false conditional expression' do
      statements = make_statements('print 1 >= 2 ? 3 + 3 : 4 + 4;')
      expect{subject.interpret(statements)}.to output("8.0\n").to_stdout
    end

    it 'can handle variable declarations' do
      statements = make_statements('var a = 1;print a;')
      expect{subject.interpret(statements)}.to output("1.0\n").to_stdout
    end

    it 'initializes a variable to nil' do
      statements = make_statements('var a;print a;')
      expect{subject.interpret(statements)}.to output("nil\n").to_stdout
    end

    it 'can handle variable re-assignment' do
      statements = make_statements("var a = 1;\nprint a;\na = 2;\nprint a;\n")
      expect{subject.interpret(statements)}.to output("1.0\n2.0\n").to_stdout
    end

    it 'can handle blocks of statements and local scopes' do
      statements = make_statements("var a = 1.0;\nvar b = 2.0;\n{\nvar a = 10.0;\nprint a;\nprint b;\n}print a;\nprint b;\n")
      expect{subject.interpret(statements)}.to output("10.0\n2.0\n1.0\n2.0\n").to_stdout
    end

    it 'can handle a true conditional statement' do
      statements = make_statements("var a = 10;if (a < 20) print a;")
      expect{subject.interpret(statements)}.to output("10.0\n").to_stdout
    end

    it 'can handle a false conditional statement' do
      statements = make_statements("var a = 10;if (a < 10) print a; else print \"Not Less\";")
      expect{subject.interpret(statements)}.to output("Not Less\n").to_stdout
    end
  end
end
