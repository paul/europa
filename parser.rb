
require 'parslet'

class EuropaParser < Parslet::Parser

  rule(:script)     { (comment).repeat }

  rule(:comment)    { (space.maybe >> str('#') >> (eol.absnt? >> any).repeat >> eol).repeat(1) }

  rule(:eol)        { match('[\r\n]').repeat(1) }
  rule(:space)      { str(' ').repeat(1) }
  rule(:space?)     { space.maybe }

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



  end

end

