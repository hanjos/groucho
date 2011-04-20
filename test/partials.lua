package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

-- extracted from https://github.com/mustache/spec, v1.1.2

context('Partials', function ()
  context('Basic', function ()
    --[=[
    - name: Basic Behavior
      desc: The greater-than operator should expand to the named partial.
      data: { }
      template: '"{{>text}}"'
      partials: { text: 'from partial' }
      expected: '"from partial"'
    --]=]
    it('Basic Behavior', function ()
      local template = '"{{>basic-behavior}}"'
      local expected = '"from partial"'
      local data = {}
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Context
      desc: The greater-than operator should operate within the current context.
      data: { text: 'content' }
      template: '"{{>partial}}"'
      partials: { partial: '*{{text}}*' }
      expected:
    --]=]
    it('Context', function ()
      local template = '"{{>context}}"'
      local expected = '"*content*"'
      local data = { text = 'content' }
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Recursion
      desc: The greater-than operator should properly recurse.
      data: { content: "X", nodes: [ { content: "Y", nodes: [] } ] }
      template: '{{>node}}'
      partials: { node: '{{content}}<{{#nodes}}{{>node}}{{/nodes}}>' }
      expected: 'X<Y<>>'
    --]=]
    it('Recursion', function ()
      local template = '{{>recursion}}'
      local expected = 'X<Y<>>'
      local data = { content = 'X', nodes = { { content = 'Y', nodes = {} } } }
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)
  end)

  context('Whitespace Sensitivity', function ()
    --[=[
    - name: Surrounding Whitespace
      desc: The greater-than operator should not alter surrounding whitespace.
      data: { }
      template: '| {{>partial}} |'
      partials: { partial: "\t|\t" }
      expected: "| \t|\t |"
    --]=]
    it('Surrounding Whitespace', function ()
      local template = '| {{>surrounding-whitespace}} |'
      local expected = "| \t|\t |"
      local data = {}
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Inline Indentation
      desc: Whitespace should be left untouched.
      data: { data: '|' }
      template: "  {{data}}  {{> partial}}\n"
      partials: { partial: ">\n>" }
      expected: "  |  >\n>\n"
    --]=]
    it('Inline Indentation', function ()
      local template = "  {{data}}  {{> inline-indentation}}\n"
      local expected = "  |  >\n>\n"
      local data = { data = '|' }
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Standalone Line Endings
      desc: '"\r\n" should be considered a newline for standalone tags.'
      data: { }
      template: "|\r\n{{>partial}}\r\n|"
      partials: { partial: ">" }
      expected: "|\r\n>|"
    --]=]
    it('Standalone Line Endings', function ()
      local template = "|\r\n{{>standalone-line-endings}}\r\n|"
      local expected = "|\r\n>|"
      local data = {}
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Standalone Without Previous Line
      desc: Standalone tags should not require a newline to precede them.
      data: { }
      template: "  {{>partial}}\n>"
      partials: { partial: ">\n>"}
      expected: "  >\n  >>"
    --]=]
    it('Standalone Without Previous Line', function ()
      local template = "  {{>standalone-without-previous-line}}\n>"
      local expected = "  >\n  >>"
      local data = {}
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Standalone Without Newline
      desc: Standalone tags should not require a newline to follow them.
      data: { }
      template: ">\n  {{>partial}}"
      partials: { partial: ">\n>" }
      expected: ">\n  >\n  >"
    --]=]
    it('Standalone Without Newline', function ()
      local template = ">\n  {{>standalone-without-newline}}"
      local expected = ">\n  >\n  >"
      local data = {}
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)

    --[=[
    - name: Standalone Indentation
      desc: Each line of the partial should be indented before rendering.
      data: { content: "<\n->" }
      template: |
        \
         {{>partial}}
        /
      partials:
        partial: |
          |
          {{{content}}}
          |
      expected: |
        \
         |
         <
        ->
         |
        /
    --]=]
    it('Standalone Indentation', function ()
      local template = "\\\n {{>standalone-indentation}}\n/\n"
      local expected = "\\\n |\n <\n->\n |\n/\n"
      local data = { content = '<\n->' }
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)
  end)

  context('Whitespace Insensitivity', function ()
    --[=[
    - name: Padding Whitespace
      desc: Superfluous in-tag whitespace should be ignored.
      data: { boolean: true }
      template: "|{{> partial }}|"
      partials: { partial: "[]" }
      expected: '|[]|'
    --]=]
    it('Padding Whitespace', function ()
      local template = "|{{> padding-whitespace }}|"
      local expected = '|[]|'
      local data = { boolean = true }
      local config = { template_path = 'fixtures' }

      assert_equal(groucho.render(template, data, config), expected)
    end)
  end)
end)
