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
        local base = 'Hello from {Mustache}!'
        local expected = 'Hello from {Mustache}!'
        local context = {}

        assert_equal(expected, groucho.render(base, context))
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
        local base = 'Hello, {{subject}}!'
        local expected = 'Hello, world!'
        local context = { subject = 'world' }

        assert_equal(expected, groucho.render(base, context))
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
        local base = 'These characters should be HTML escaped: {{forbidden}}'
        local expected = 'These characters should be HTML escaped: &amp; &quot; &lt; &gt;'
        local context = { forbidden = '& " < >' }

        assert_equal(expected, groucho.render(base, context))
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
        local base = 'These characters should not be HTML escaped: {{{forbidden}}}'
        local expected = 'These characters should not be HTML escaped: & " < >'
        local context = { forbidden = '& " < >' }

        assert_equal(expected, groucho.render(base, context))
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
        local base = 'These characters should not be HTML escaped: {{&forbidden}}'
        local expected = 'These characters should not be HTML escaped: & " < >'
        local context = { forbidden = '& " < >' }

        assert_equal(expected, groucho.render(base, context))
      end)

      --[=[
      - name: Basic Integer Interpolation
        desc: Integers should interpolate seamlessly.
        data: { mph: 85 }
        template: '"{{mph}} miles an hour!"'
        expected: '"85 miles an hour!"'
      --]=]
      it('Basic Integer Interpolation', function ()
        local base = '"{{mph}} miles an hour!"'
        local expected = '"85 miles an hour!"'
        local context = { mph = 85 }

        assert_equal(expected, groucho.render(base, context))
      end)

      --[=[
      - name: Triple Mustache Integer Interpolation
        desc: Integers should interpolate seamlessly.
        data: { mph: 85 }
        template: '"{{{mph}}} miles an hour!"'
        expected: '"85 miles an hour!"'
      --]=]
      it('Basic Integer Interpolation', function ()
        local base = '"{{{mph}}} miles an hour!"'
        local expected = '"85 miles an hour!"'
        local context = { mph = 85 }

        assert_equal(expected, groucho.render(base, context))
      end)

      --[=[
      - name: Ampersand Integer Interpolation
        desc: Integers should interpolate seamlessly.
        data: { mph: 85 }
        template: '"{{&mph}} miles an hour!"'
        expected: '"85 miles an hour!"'
      --]=]
      it('Ampersand Integer Interpolation', function ()
        local base = '"{{&mph}} miles an hour!"'
        local expected = '"85 miles an hour!"'
        local context = { mph = 85 }

        assert_equal(expected, groucho.render(base, context))
      end)

      --[=[
      - name: Basic Decimal Interpolation
        desc: Decimals should interpolate seamlessly with proper significance.
        data: { power: 1.210 }
        template: '"{{power}} jiggawatts!"'
        expected: '"1.21 jiggawatts!"'
      --]=]
      it('Basic Decimal Interpolation', function ()
        local base = '"{{power}} jiggawatts!"'
        local expected = '"1.21 jiggawatts!"'
        local context = { power = 1.210 }

        assert_equal(expected, groucho.render(base, context))
      end)

      --[=[
      - name: Triple Mustache Decimal Interpolation
        desc: Decimals should interpolate seamlessly with proper significance.
        data: { power: 1.210 }
        template: '"{{{power}}} jiggawatts!"'
        expected: '"1.21 jiggawatts!"'
      --]=]
      it('Triple Mustache Decimal Interpolation', function ()
        local base = '"{{{power}}} jiggawatts!"'
        local expected = '"1.21 jiggawatts!"'
        local context = { power = 1.210 }

        assert_equal(expected, groucho.render(base, context))
      end)

      --[=[
      - name: Ampersand Decimal Interpolation
        desc: Decimals should interpolate seamlessly with proper significance.
        data: { power: 1.210 }
        template: '"{{&power}} jiggawatts!"'
        expected: '"1.21 jiggawatts!"'
      --]=]
      it('Ampersand Decimal Interpolation', function ()
        local base = '"{{&power}} jiggawatts!"'
        local expected = '"1.21 jiggawatts!"'
        local context = { power = 1.210 }

        assert_equal(expected, groucho.render(base, context))
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
      local base = 'I ({{cannot}}) be seen!'
      local expected = 'I () be seen!'
      local context = {}

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Triple Mustache Context Miss Interpolation
      desc: Failed context lookups should default to empty strings.
      data: { }
      template: "I ({{{cannot}}}) be seen!"
      expected: "I () be seen!"
    --]=]
    it('Triple Mustache Context Miss Interpolation', function ()
      local base = 'I ({{{cannot}}}) be seen!'
      local expected = 'I () be seen!'
      local context = {}

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Ampersand Context Miss Interpolation
      desc: Failed context lookups should default to empty strings.
      data: { }
      template: "I ({{&cannot}}) be seen!"
      expected: "I () be seen!"
    --]=]
    it('Ampersand Context Miss Interpolation', function ()
      local base = 'I ({{&cannot}}) be seen!'
      local expected = 'I () be seen!'
      local context = {}

      assert_equal(expected, groucho.render(base, context))
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
      local base = '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      local expected = '"Joe" == "Joe"'
      local context = { person = { name = 'Joe' } }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Dotted Names - Triple Mustache Interpolation
      desc: Dotted names should be considered a form of shorthand for sections.
      data: { person: { name: 'Joe' } }
      template: '"{{{person.name}}}" == "{{#person}}{{{name}}}{{/person}}"'
      expected: '"Joe" == "Joe"'
    --]=]
    it('Dotted Names - Triple Mustache Interpolation', function ()
      local base = '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      local expected = '"Joe" == "Joe"'
      local context = { person = { name = 'Joe' } }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Dotted Names - Ampersand Interpolation
      desc: Dotted names should be considered a form of shorthand for sections.
      data: { person: { name: 'Joe' } }
      template: '"{{&person.name}}" == "{{#person}}{{&name}}{{/person}}"'
      expected: '"Joe" == "Joe"'
    --]=]
    it('Dotted Names - Ampersand Interpolation', function ()
      local base = '"{{person.name}}" == "{{#person}}{{name}}{{/person}}"'
      local expected = '"Joe" == "Joe"'
      local context = { person = { name = 'Joe' } }

      assert_equal(expected, groucho.render(base, context))
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
      local base = '"{{a.b.c.d.e.name}}" == "Phil"'
      local expected = '"Phil" == "Phil"'
      local context = { a = { b = { c = { d = { e = { name = 'Phil' } } } } } }

      assert_equal(expected, groucho.render(base, context))
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
      local base = '"{{a.b.c}}" == ""'
      local expected = '"" == ""'
      local context = { a = {} }

      assert_equal(expected, groucho.render(base, context))
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
      local base = '"{{a.b.c.name}}" == ""'
      local expected = '"" == ""'
      local context = {
        a = { b = {} },
        c = { name = 'Jim' } }

      assert_equal(expected, groucho.render(base, context))
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
      local base = '"{{#a}}{{b.c.d.e.name}}{{/a}}" == "Phil"'
      local expected = '"Phil" == "Phil"'
      local context = {
        a = { b = { c = { d = { e = { name = 'Phil' } } } } },
        b = { c = { d = { e = { name = 'Wrong' } } } } }

      assert_equal(expected, groucho.render(base, context))
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
      local base = '| {{string}} |'
      local expected = '| --- |'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Triple Mustache - Surrounding Whitespace
      desc: Interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: '| {{{string}}} |'
      expected: '| --- |'
    --]=]
    it('Triple Mustache - Surrounding Whitespace', function ()
      local base = '| {{{string}}} |'
      local expected = '| --- |'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Ampersand - Surrounding Whitespace
      desc: Interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: '| {{&string}} |'
      expected: '| --- |'
    --]=]
    it('Ampersand - Surrounding Whitespace', function ()
      local base = '| {{&string}} |'
      local expected = '| --- |'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Interpolation - Standalone
      desc: Standalone interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: "  {{string}}\n"
      expected: "  ---\n"
    --]=]
    it('Interpolation - Standalone', function ()
      local base = '  {{string}}\n'
      local expected = '  ---\n'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Triple Mustache - Standalone
      desc: Standalone interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: "  {{{string}}}\n"
      expected: "  ---\n"
    --]=]
    it('Triple Mustache - Standalone', function ()
      local base = '  {{{string}}}\n'
      local expected = '  ---\n'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Ampersand - Standalone
      desc: Standalone interpolation should not alter surrounding whitespace.
      data: { string: '---' }
      template: "  {{&string}}\n"
      expected: "  ---\n"
    --]=]
    it('Ampersand - Standalone', function ()
      local base = '  {{&string}}\n'
      local expected = '  ---\n'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
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
      local base = '|{{ string }}|'
      local expected = '|---|'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Triple Mustache With Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { string: "---" }
      template: '|{{{ string }}}|'
      expected: '|---|'
    --]=]
    it('Triple Mustache With Padding', function ()
      local base = '|{{{ string }}}|'
      local expected = '|---|'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)

    --[=[
    - name: Ampersand With Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { string: "---" }
      template: '|{{& string }}|'
      expected: '|---|'
    --]=]
    it('Ampersand With Padding', function ()
      local base = '|{{& string }}|'
      local expected = '|---|'
      local context = { string = '---' }

      assert_equal(expected, groucho.render(base, context))
    end)
  end)
end)