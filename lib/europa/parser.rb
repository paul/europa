require 'parslet'

module Europa

  class Parser < Parslet::Parser

    rule(:script)               { (space? >> statement | space? >> comment).repeat }

    rule(:statement)            {
      expression >> (space? >> expression).maybe

    }

    rule(:expression)           {
      method >> message.repeat
    }

    rule(:message)              {
      str('.') >> space? >> method.as(:message)
    }

    rule(:method)               {
      identifier >> space >> arguments |
      identifier >> str('(') >> space? >> arguments.maybe >> space? >> str(')') |
      identifier
    }

    rule(:arguments)            {
      identifier >> (space? >> str(',') >> space? >> identifier).repeat
    }

    rule(:identifier)           { atom | literal }

    rule(:atom)                 { match['a-zA-Z_'].repeat(1) }

    rule(:literal)              { number | string | symbol }

    rule(:number)               { exponential | hexadecimal | decimal | integer }

    rule(:integer)              { match['0-9'].repeat(1) }

    rule(:decimal)              { integer >> str('.') >> integer }

    rule(:hexadecimal)          { str('0x') >> match['0-9a-f'].repeat(1) }

    rule(:exponential)          { (decimal | integer) >> (str('e') | str('E')) >> (decimal | integer) }

    rule(:string)               { single_quoted_string | double_quoted_string }

    rule(:single_quoted_string) {
      str("'") >>
      (
        (str('\\') >> any) |
        (str("'").absnt? >> any)
      ).repeat.as(:single_quoted_string) >>
      str("'")
    }

    rule(:double_quoted_string) {
      str('"') >>
      (
        (str('\\') >> any) |
        (str('"').absnt? >> any)
      ).repeat.as(:double_quoted_string) >>
      str('"')
    }

    rule(:symbol)               { str(':') >> (identifier | string) }

    rule(:comment)              { multiline_comment | singleline_comment }

    rule(:singleline_comment)   {
      space? >>
      ((str('#') >> (eol.absnt? >> any).repeat >> eol.maybe).repeat(1)).as(:comment)
    }

    rule(:multiline_comment)    {
      singleline_comment.repeat(2).as(:comment)
    }

    rule(:eol)                  { match('[\r\n]').repeat(1) }
    rule(:space)                { match['\\s'].repeat(1) }
    rule(:space?)               { space.maybe }

    root(:script)

  end

end
