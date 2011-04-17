package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

-- extracted from https://github.com/mustache/spec, v1.1.2

context('Interpolation', function ()
  context('Basic', function ()
      --[=[
      - name: No Interpolation
        desc: Mustache-free templates should render as-is.
        data: { }
        template: |
          Hello from {Mustache}!
        expected: |
          Hello from {Mustache}!
      --]=]
      it('No Interpolation', function ()
        local template = 'Hello from {Mustache}!'
        local expected = 'Hello from {Mustache}!'
        local data = {}

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Basic Interpolation
        desc: Unadorned tags should interpolate content into the template.
        data: { subject: "world" }
        template: |
          Hello, {{subject}}!
        expected: |
          Hello, world!
      --]=]
      it('Basic Interpolation', function ()
        local template = 'Hello, {{subject}}!'
        local expected = 'Hello, world!'
        local data = { subject = 'world' }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: HTML Escaping
        desc: Basic interpolation should be HTML escaped.
        data: { forbidden: '& " < >' }
        template: |
          These characters should be HTML escaped: {{forbidden}}
        expected: |
          These characters should be HTML escaped: &amp; &quot; &lt; &gt;
      --]=]
      it('HTML Escaping', function ()
        local template = 'These characters should be HTML escaped: {{forbidden}}'
        local expected = 'These characters should be HTML escaped: &amp; &quot; &lt; &gt;'
        local data = { forbidden = '& " < >' }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Triple Mustache
        desc: Triple mustaches should interpolate without HTML escaping.
        data: { forbidden: '& " < >' }
        template: |
          These characters should not be HTML escaped: {{{forbidden}}}
        expected: |
          These characters should not be HTML escaped: & " < >
      --]=]
      it('Triple Mustache', function ()
        local template = 'These characters should not be HTML escaped: {{{forbidden}}}'
        local expected = 'These characters should not be HTML escaped: & " < >'
        local data = { forbidden = '& " < >' }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Ampersand
        desc: Ampersand should interpolate without HTML escaping.
        data: { forbidden: '& " < >' }
        template: |
          These characters should not be HTML escaped: {{&forbidden}}
        expected: |
          These characters should not be HTML escaped: & " < >
      --]=]
      it('Ampersand', function ()
        local template = 'These characters should not be HTML escaped: {{&forbidden}}'
        local expected = 'These characters should not be HTML escaped: & " < >'
        local data = { forbidden = '& " < >' }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Basic Integer Interpolation
        desc: Integers should interpolate seamlessly.
        data: { mph: 85 }
        template: '"{{mph}} miles an hour!"'
        expected: '"85 miles an hour!"'
      --]=]
      it('Basic Integer Interpolation', function ()
        local template = '"{{mph}} miles an hour!"'
        local expected = '"85 miles an hour!"'
        local data = { mph = 85 }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Triple Mustache Integer Interpolation
        desc: Integers should interpolate seamlessly.
        data: { mph: 85 }
        template: '"{{{mph}}} miles an hour!"'
        expected: '"85 miles an hour!"'
      --]=]
      it('Basic Integer Interpolation', function ()
        local template = '"{{{mph}}} miles an hour!"'
        local expected = '"85 miles an hour!"'
        local data = { mph = 85 }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Ampersand Integer Interpolation
        desc: Integers should interpolate seamlessly.
        data: { mph: 85 }
        template: '"{{&mph}} miles an hour!"'
        expected: '"85 miles an hour!"'
      --]=]
      it('Ampersand Integer Interpolation', function ()
        local template = '"{{&mph}} miles an hour!"'
        local expected = '"85 miles an hour!"'
        local data = { mph = 85 }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Basic Decimal Interpolation
        desc: Decimals should interpolate seamlessly with proper significance.
        data: { power: 1.210 }
        template: '"{{power}} jiggawatts!"'
        expected: '"1.21 jiggawatts!"'
      --]=]
      it('Basic Decimal Interpolation', function ()
        local template = '"{{power}} jiggawatts!"'
        local expected = '"1.21 jiggawatts!"'
        local data = { power = 1.210 }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Triple Mustache Decimal Interpolation
        desc: Decimals should interpolate seamlessly with proper significance.
        data: { power: 1.210 }
        template: '"{{{power}}} jiggawatts!"'
        expected: '"1.21 jiggawatts!"'
      --]=]
      it('Triple Mustache Decimal Interpolation', function ()
        local template = '"{{{power}}} jiggawatts!"'
        local expected = '"1.21 jiggawatts!"'
        local data = { power = 1.210 }

        assert_equal(groucho.render(template, data), expected)
      end)

      --[=[
      - name: Ampersand Decimal Interpolation
        desc: Decimals should interpolate seamlessly with proper significance.
        data: { power: 1.210 }
        template: '"{{&power}} jiggawatts!"'
        expected: '"1.21 jiggawatts!"'
      --]=]
      it('Ampersand Decimal Interpolation', function ()
        local template = '"{{&power}} jiggawatts!"'
        local expected = '"1.21 jiggawatts!"'
        local data = { power = 1.210 }

        assert_equal(groucho.render(template, data), expected)
      end)
  end)

  context('Context Miss', function ()
    --[=[
    - name: Basic Context Miss Interpolation
      desc: Failed context lookups should default to empty strings.
      data: { }
      template: "I ({{cannot}}) be seen!"
      expected: "I () be seen!"
    --]=]
    it('Basic Context Miss Interpolation', function ()
      local template = 'I ({{cannot}}) be seen!'
      local expected = 'I () be seen!'
      local data = {}

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Triple Mustache Context Miss Interpolation
      desc: Failed context lookups should default to empty strings.
      data: { }
      template: "I ({{{cannot}}}) be seen!"
      expected: "I () be seen!"
    --]=]
    it('Triple Mustache Context Miss Interpolation', function ()
      local template = 'I ({{{cannot}}}) be seen!'
      local expected = 'I () be seen!'
      local data = {}

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Ampersand Context Miss Interpolation
      desc: Failed context lookups should default to empty strings.
      data: { }
      template: "I ({{&cannot}}) be seen!"
      expected: "I () be seen!"
    --]=]
    it('Ampersand Context Miss Interpolation', function ()
      local template = 'I ({{&cannot}}) be seen!'
      local expected = 'I () be seen!'
      local data = {}

      assert_equal(groucho.render(template, data), expected)
    end)
  end)
  -- Dotted Names

  context('Dotted Names', function ()
    --[=[
    - name: Dotted Names - Basic Interpolation
      desc: Dotted names should be considered a form of shorthand for sections.
      data: { person: { name: 'Joe' } }
      template: '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      expected: '"Joe" == "Joe"'
    --]=]
    it('Dotted Names - Basic Interpolation', function ()
      local template = '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      local expected = '"Joe" == "Joe"'
      local data = { person = { name = 'Joe' } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Triple Mustache Interpolation
      desc: Dotted names should be considered a form of shorthand for sections.
      data: { person: { name: 'Joe' } }
      template: '"{{{person.name}}}" == "{{#person}}{{{name}}}{{/person}}"'
      expected: '"Joe" == "Joe"'
    --]=]
    it('Dotted Names - Triple Mustache Interpolation', function ()
      local template = '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      local expected = '"Joe" == "Joe"'
      local data = { person = { name = 'Joe' } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Ampersand Interpolation
      desc: Dotted names should be considered a form of shorthand for sections.
      data: { person: { name: 'Joe' } }
      template: '"{{&person.name}}" == "{{#person}}{{&name}}{{/person}}"'
      expected: '"Joe" == "Joe"'
    --]=]
    it('Dotted Names - Ampersand Interpolation', function ()
      local template = '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      local expected = '"Joe" == "Joe"'
      local data = { person = { name = 'Joe' } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Arbitrary Depth
      desc: Dotted names should be functional to any level of nesting.
      data:
        a: { b: { c: { d: { e: { name: 'Phil' } } } } }
      template: '"{{a.b.c.d.e.name}}" == "Phil"'
      expected: '"Phil" == "Phil"'
    --]=]
    it('Dotted Names - Arbitrary Depth', function ()
      local template = '"{{a.b.c.d.e.name}}" == "Phil"'
      local expected = '"Phil" == "Phil"'
      local data = { a = { b = { c = { d = { e = { name = 'Phil' } } } } } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Broken Chains
      desc: Any falsey value prior to the last part of the name should yield ''.
      data:
        a: { }
      template: '"{{a.b.c}}" == ""'
      expected: '"" == ""'
    --]=]
    it('Dotted Names - Broken Chains', function ()
      local template = '"{{a.b.c}}" == ""'
      local expected = '"" == ""'
      local data = { a = {} }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Broken Chain Resolution
      desc: Each part of a dotted name should resolve only against its parent.
      data:
        a: { b: { } }
        c: { name: 'Jim' }
      template: '"{{a.b.c.name}}" == ""'
      expected: '"" == ""'
    --]=]
    it('Dotted Names - Broken Chain Resolution', function ()
      local template = '"{{a.b.c.name}}" == ""'
      local expected = '"" == ""'
      local data = {
        a = { b = {} },
        c = { name = 'Jim' } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Initial Resolution
      desc: The first part of a dotted name should resolve as any other name.
      data:
        a: { b: { c: { d: { e: { name: 'Phil' } } } } }
        b: { c: { d: { e: { name: 'Wrong' } } } }
      template: '"{{#a}}{{b.c.d.e.name}}{{/a}}" == "Phil"'
      expected: '"Phil" == "Phil"'
    --]=]
    it('Dotted Names - Initial Resolution', function ()
      local template = '"{{#a}}{{b.c.d.e.name}}{{/a}}" == "Phil"'
      local expected = '"Phil" == "Phil"'
      local data = {
        a = { b = { c = { d = { e = { name = 'Phil' } } } } },
        b = { c = { d = { e = { name = 'Wrong' } } } } }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Whitespace Sensitivity', function ()
    --[=[
    - name: Interpolation - Surrounding Whitespace
      desc: Interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: '| {{string}} |'
      expected: '| --- |'
    --]=]
    it('Interpolation - Surrounding Whitespace', function ()
      local template = '| {{string}} |'
      local expected = '| --- |'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Triple Mustache - Surrounding Whitespace
      desc: Interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: '| {{{string}}} |'
      expected: '| --- |'
    --]=]
    it('Triple Mustache - Surrounding Whitespace', function ()
      local template = '| {{{string}}} |'
      local expected = '| --- |'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Ampersand - Surrounding Whitespace
      desc: Interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: '| {{&string}} |'
      expected: '| --- |'
    --]=]
    it('Ampersand - Surrounding Whitespace', function ()
      local template = '| {{&string}} |'
      local expected = '| --- |'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Interpolation - Standalone
      desc: Standalone interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: "  {{string}}\n"
      expected: "  ---\n"
    --]=]
    it('Interpolation - Standalone', function ()
      local template = '  {{string}}\n'
      local expected = '  ---\n'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Triple Mustache - Standalone
      desc: Standalone interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: "  {{{string}}}\n"
      expected: "  ---\n"
    --]=]
    it('Triple Mustache - Standalone', function ()
      local template = '  {{{string}}}\n'
      local expected = '  ---\n'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Ampersand - Standalone
      desc: Standalone interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: "  {{&string}}\n"
      expected: "  ---\n"
    --]=]
    it('Ampersand - Standalone', function ()
      local template = '  {{&string}}\n'
      local expected = '  ---\n'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Whitespace Insensitivity', function ()
    --[=[
    - name: Interpolation With Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { string: "---" }
      template: '|{{ string }}|'
      expected: '|---|'
    --]=]
    it('Interpolation With Padding', function ()
      local template = '|{{ string }}|'
      local expected = '|---|'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Triple Mustache With Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { string: "---" }
      template: '|{{{ string }}}|'
      expected: '|---|'
    --]=]
    it('Triple Mustache With Padding', function ()
      local template = '|{{{ string }}}|'
      local expected = '|---|'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Ampersand With Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { string: "---" }
      template: '|{{& string }}|'
      expected: '|---|'
    --]=]
    it('Ampersand With Padding', function ()
      local template = '|{{& string }}|'
      local expected = '|---|'
      local data = { string = '---' }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Lua Specifics', function ()
    it("Doesn't See Non-String Variables", function ()
      local template = [[
        * {{1}}
        * {{{2}}}
        * {{3}}]]

      local expected = [[
        * Chris
        * 29
        * ]]

      local data = {
        ['1'] = "Chris",
        [1] = "Angela",
        ['2'] = "29",
        [2] = "40, but gosh doesn't she look like she's 29?",
        [3] = "Help! I'm invisible!",
      }

      assert_equal(groucho.render(template, data), expected)
    end)

    it('Variables with Non-Letter Characters in the Name', function ()
      local template = [[
        * {{name?}}
        * {{age!}}
        * {{123company_in_bold}}
        * {{& =1+2}}]]

      local expected = [[
        * Chris
        * 29
        * &lt;b&gt;GitHub&lt;/b&gt;
        * <b>GitHub</b>]]

      local data = {
        ['name?'] = "Chris",
        ['age!'] = "29",
        ['123company_in_bold'] = "<b>GitHub</b>",
        ['=1+2'] = "<b>GitHub</b>",
      }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)
end)