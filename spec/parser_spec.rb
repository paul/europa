require File.expand_path('../../lib/europa/parser', __FILE__)
require 'parslet/rig/rspec'

describe Europa::Parser do

  before do
    @parser = Europa::Parser.new
  end

  describe 'comments' do

    subject do
      @parser.comment
    end

    it { should parse %{# this is a comment} }
    it { should parse %{# this is a\n# multiline comment} }
    it { should parse %{    # an indented comment} }
    it { should parse %{    # a multiline\n    # indented comment} }

  end

  describe 'numbers' do

    subject do
      @parser.number
    end

    it { should parse %{42} }
    it { should parse %{42.0} }
    it { should parse %{0xdeadbeef} }
    it { should parse %{6.02e23} }
    it { should parse %{6.02E23} }

  end

  describe 'strings' do
    subject do
      @parser.string
    end

    it { should parse %{'single-quoted string'} }
    it { should parse %{'multiline\nsingle-quoted string'} }
    it { should parse %{"double-quoted string"} }
    it { should parse %{"double-quoted string with \\\"escapes\\\""} }
    it { should parse %{"multiline\ndouble-quoted string"} }
  end

  describe 'labels' do
    subject do
      @parser.symbol
    end

    it { should parse %{:simple} }
    it { should_not parse %{:invalid-label} }
    it { should parse %{:"quoted-label"} }
  end

  describe 'atoms' do
    subject do
      @parser.atom
    end

    it { should parse %{variable} }
    it { should parse %{underscored_variable} }
    it { should parse %{_prefixed_variable} }
    it { should parse %{CamelCaseVariable} }
    it { should parse %{CAPITALIZED_VARIABLE} }

    it { should_not parse %{dashed-variable} }
    it { should_not parse %{1numbered_variable} }
  end

  describe 'calling methods' do

    subject do
      @parser.method
    end

    it { should parse %{my_method} }
    it { should parse %{my_method 42} }
    it { should parse %{my_method 42, answer} }
    it { should parse %{my_method()} }
    it { should parse %{my_method(42)} }
    it { should parse %{my_method(42, :answer)} }
    it { should parse %{my_method( 42 )} }
    it { should parse %{my_method(\n    42\n  )} }
    it { should_not parse %{do_something() another_method} }

  end

  describe 'expressions' do

    subject do
      @parser.expression
    end

    it { should parse %{user} }
    it { should parse %{user.login} }
    it { should parse %{user.login()} }
    it { should parse %{user(true).login(42)} }
    it { should parse %{user.\nlogin} }
    it { should_not parse %{do_something() if true} }

  end

  describe 'statement' do

    subject do
      @parser.statement
    end

    it { should parse %{do_something() if true} }

  end

end
