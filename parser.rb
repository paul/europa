
require 'parslet'

class EuropaParser < Parslet::Parser

  rule(:script)               { (statement | comment).repeat }

  rule(:statement)            { atom.repeat(1) >> eol }

  rule(:atom)                 { identifier | literal }

  rule(:identifier)           { match['a-z_'].repeat(1) }

  rule(:literal)              { number | string | symbol }

  rule(:number)               { integer >> ( str('.') >> integer ).maybe }

  rule(:integer)              { match['0-9'].repeat(1) }

  rule(:string)               { single_quoted_string | double_quoted_string }

  rule(:single_quoted_string) {
    single_quote >> (single_quote.absnt? >> any).repeat >> single_quote
  }

  rule(:double_quoted_string) {
    double_quote >> (double_quote.absnt? >> any).repeat >> double_quote
  }

  rule(:symbol)               { str(':') >> (identifier | string) }

  rule(:comment)              {
    (space.maybe >> str('#') >> (eol.absnt? >> any).repeat >> eol).repeat(1)
  }

  rule(:eol)                  { match('[\r\n]').repeat(1) }
  rule(:space)                { match['\\s'].repeat(1) }
  rule(:space?)               { space.maybe }

  rule(:single_quote)         { str("'") }
  rule(:double_quote)         { str('"') }

  root(:script)
end

if $0 == __FILE__
  require 'minitest/autorun'

  class ParserTest < MiniTest::Unit::TestCase

    def setup
      @parser = EuropaParser.new
    end

    def assert_parses(code)
      begin
        @parser.parse code
      rescue Parslet::ParseFailed => err
        raise MiniTest::Assertion, err.to_s + "\n" + @parser.root.error_tree.to_s
      end
    end

    def test_comment
      assert_parses <<-CODE
# comment
      CODE
    end

    def test_multiline_comment
      assert_parses <<-CODE
#######################
# Fancy Comment Block #
#######################
      CODE
    end

    def test_indented_comment
      assert_parses <<-CODE
        # indent
      CODE
    end

    def test_integer
      assert_parses <<-CODE
42
      CODE
    end

    def test_number
      assert_parses <<-CODE
42.0
      CODE
    end

    def test_single_quoted_string
      assert_parses <<-CODE
'hello, world!'
      CODE
    end

    def test_double_quoted_string
      assert_parses <<-CODE
"hello, world!"
      CODE
    end

    def test_escaping_in_strings
      skip "Implement escaped quotes"
      assert_parses <<-CODE
"hello, \\\"world\\\""
      CODE
    end

    def test_symbol
      assert_parses <<-CODE
:symbol
      CODE
    end

    def test_string_symbols
      assert_parses <<-CODE
:"42"
:'illegal-identifier'
      CODE
    end


  end

end

