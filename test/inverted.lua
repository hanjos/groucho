package.path = '../src/?.lua;../src/?/init.lua;'..package.path

require 'telescope'
require 'groucho'

-- extracted from https://github.com/mustache/spec, v1.1.2

context('Inverted', function ()
  context('Basic', function ()
    --[=[
    - name: Falsey
      desc: Falsey sections should have their contents rendered.
      data: { boolean: false }
      template: '"{{^boolean}}This should be rendered.{{/boolean}}"'
      expected: '"This should be rendered."'
    --]=]
    it('Falsey', function ()
      local template = '"{{^boolean}}This should be rendered.{{/boolean}}"'
      local expected = '"This should be rendered."'
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Truthy
      desc: Truthy sections should have their contents omitted.
      data: { boolean: true }
      template: '"{{^boolean}}This should not be rendered.{{/boolean}}"'
      expected: '""'
    --]=]
    it('Truthy', function ()
      local template = '"{{^boolean}}This should not be rendered.{{/boolean}}"'
      local expected = '""'
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Context
      desc: Objects and hashes should behave like truthy values.
      data: { context: { name: 'Joe' } }
      template: '"{{^context}}Hi {{name}}.{{/context}}"'
      expected: '""'
    --]=]
    it('Context', function ()
      local template = '"{{^context}}Hi {{name}}.{{/context}}"'
      local expected = '""'
      local data = { context = { name = 'Joe' } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: List
      desc: Lists should behave like truthy values.
      data: { list: [ { n: 1 }, { n: 2 }, { n: 3 } ] }
      template: '"{{^list}}{{n}}{{/list}}"'
      expected: '""'
    --]=]
    it('List', function ()
      local template = '"{{^list}}{{n}}{{/list}}"'
      local expected = '""'
      local data = { list = { { n = 1 }, { n = 2 }, { n = 3 } } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Empty List
      desc: Empty lists should behave like falsey values.
      data: { list: [ ] }
      template: '"{{^list}}Yay lists!{{/list}}"'
      expected: '"Yay lists!"'
    --]=]
    it('Empty List', function ()
      local template = '"{{^list}}Yay lists!{{/list}}"'
      local expected = '"Yay lists!"'
      local data = { list = {} }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Doubled
      desc: Multiple inverted sections per template should be permitted.
      data: { bool: false, two: 'second' }
      template: |
        {{^bool}}
        * first
        {{/bool}}
        * {{two}}
        {{^bool}}
        * third
        {{/bool}}
      expected: |
        * first
        * second
        * third

     --]=]
    it('Doubled', function ()
      local template = "{{^bool}}\n* first\n{{/bool}}\n* {{two}}\n{{^bool}}\n* third\n{{/bool}}\n"
      local expected = "* first\n* second\n* third\n"
      local data = { bool = false, two = 'second' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Nested (Falsey)
      desc: Nested falsey sections should have their contents rendered.
      data: { bool: false }
      template: "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
      expected: "| A B C D E |"
    --]=]
    it('Nested (Falsey)', function ()
      local template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
      local expected = "| A B C D E |"
      local data = { bool = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Nested (Truthy)
      desc: Nested truthy sections should be omitted.
      data: { bool: true }
      template: "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
      expected: "| A  E |"
    --]=]
    it('Nested (Truthy)', function ()
      local template = "| A {{^bool}}B {{^bool}}C{{/bool}} D{{/bool}} E |"
      local expected = "| A  E |"
      local data = { bool = true }

      assert_equal(groucho.render(template, data), expected)
    end)
    
    --[=[
    - name: Context Misses
      desc: Failed context lookups should be considered falsey.
      data: { }
      template: "[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
      expected: "[Cannot find key 'missing'!]"
    --]=]
    it('Context Misses', function ()
      local template = "[{{^missing}}Cannot find key 'missing'!{{/missing}}]"
      local expected = "[Cannot find key 'missing'!]"
      local data = {}

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Dotted Names', function ()
    --[=[
    - name: Dotted Names - Truthy
      desc: Dotted names should be valid for Inverted Section tags.
      data: { a: { b: { c: true } } }
      template: '"{{^a.b.c}}Not Here{{/a.b.c}}" == ""'
      expected: '"" == ""'
    --]=]
    it('Dotted Names - Truthy', function ()
      local template = '"{{^a.b.c}}Not Here{{/a.b.c}}" == ""'
      local expected = '"" == ""'
      local data = { a = { b = { c = true } } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Falsey
      desc: Dotted names should be valid for Inverted Section tags.
      data: { a: { b: { c: false } } }
      template: '"{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here"'
      expected: '"Not Here" == "Not Here"'
    --]=]
    it('Dotted Names - Falsey', function ()
      local template = '"{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here"'
      local expected = '"Not Here" == "Not Here"'
      local data = { a = { b = { c = false } } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Broken Chains
      desc: Dotted names that cannot be resolved should be considered falsey.
      data: { a: { } }
      template: '"{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here"'
      expected: '"Not Here" == "Not Here"'
    --]=]
    it('Dotted Names - Broken Chains', function ()
      local template = '"{{^a.b.c}}Not Here{{/a.b.c}}" == "Not Here"'
      local expected = '"Not Here" == "Not Here"'
      local data = { a = {} }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Whitespace Sensitivity', function ()
    --[=[
    - name: Surrounding Whitespace
      desc: Inverted sections should not alter surrounding whitespace.
      data: { boolean: false }
      template: " | {{^boolean}}\t|\t{{/boolean}} | \n"
      expected: " | \t|\t | \n"
    --]=]
    it('Surrounding Whitespace', function ()
      local template = " | {{^boolean}}\t|\t{{/boolean}} | \n"
      local expected = " | \t|\t | \n"
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Internal Whitespace
      desc: Inverted should not alter internal whitespace.
      data: { boolean: false }
      template: " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
      expected: " |  \n  | \n"
    --]=]
    it('Internal Whitespace', function ()
      local template = " | {{^boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
      local expected = " |  \n  | \n"
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Indented Inline Sections
      desc: Single-line sections should not alter surrounding whitespace.
      data: { boolean: false }
      template: " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
      expected: " NO\n WAY\n"
    --]=]
    it('Indented Inline Sections', function ()
      local template = " {{^boolean}}NO{{/boolean}}\n {{^boolean}}WAY{{/boolean}}\n"
      local expected = " NO\n WAY\n"
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Lines
      desc: Standalone lines should be removed from the template.
      data: { boolean: false }
      template: |
        | This Is
        {{^boolean}}
        |
        {{/boolean}}
        | A Line
      expected: |
        | This Is
        |
        | A Line
    --]=]
    it('Standalone Lines', function ()
      local template = [[
      | This Is
      {{^boolean}}
      |
      {{/boolean}}
      | A Line]]
      local expected = [[
      | This Is
      |
      | A Line]]
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Indented Lines
      desc: Standalone indented lines should be removed from the template.
      data: { boolean: false }
      template: |
        | This Is
          {{^boolean}}
        |
          {{/boolean}}
        | A Line
      expected: |
        | This Is
        |
        | A Line
    --]=]
    it('Standalone Indented Lines', function ()
      local template = [[
      | This Is
        {{^boolean}}
      |
        {{/boolean}}
      | A Line]]
      local expected = [[
      | This Is
      |
      | A Line]]
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Line Endings
      desc: '"\r\n" should be considered a newline for standalone tags.'
      data: { boolean: false }
      template: "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
      expected: "|\r\n|"
    --]=]
    it('Standalone Line Endings', function ()
      local template = "|\r\n{{^boolean}}\r\n{{/boolean}}\r\n|"
      local expected = "|\r\n|"
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Without Previous Line
      desc: Standalone tags should not require a newline to precede them.
      data: { boolean: false }
      template: "  {{^boolean}}\n^{{/boolean}}\n/"
      expected: "^\n/"
    --]=]
    it('Standalone Without Previous Line', function ()
      local template = "  {{^boolean}}\n^{{/boolean}}\n/"
      local expected = "^\n/"
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Without Newline
      desc: Standalone tags should not require a newline to follow them.
      data: { boolean: false }
      template: "^{{^boolean}}\n/\n  {{/boolean}}"
      expected: "^\n/\n"
    --]=]
    it('Standalone Without Newline', function ()
      local template = "^{{^boolean}}\n/\n  {{/boolean}}"
      local expected = "^\n/\n"
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Whitespace Insensitivity', function ()
    --[=[
    - name: Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { boolean: false }
      template: '|{{^ boolean }}={{/ boolean }}|'
      expected: '|=|'
    --]=]
    it('Padding', function ()
      local template = '|{{^ boolean }}={{/ boolean }}|'
      local expected = '|=|'
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)
end)