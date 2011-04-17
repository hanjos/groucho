package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

-- extracted from https://github.com/mustache/spec, v1.1.2

context('Comments', function ()
  --[[
  - name: Inline
    desc: Comment blocks should be removed from the template.
    data: { }
    template: '12345{{! Comment Block! }}67890'
    expected: '1234567890'
  --]]
  it('Inline', function ()
    local template = '12345{{! Comment Block! }}67890'
    local expected = '1234567890'
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Multiline
    desc: Multiline comments should be permitted.
    data: { }
    template: |
      12345{{!
        This is a
        multi-line comment...
      }}67890
    expected: |
      1234567890
  --]=]
  it('Multiline', function ()
    local template = [[
12345{{!
  This is a
  multi-line comment...
}}67890]]
    local expected = '1234567890'
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Standalone
    desc: All standalone comment lines should be removed.
    data: { }
    template: |
      Begin.
      {{! Comment Block! }}
      End.
    expected: |
      Begin.
      End.
  --]=]
  it('Standalone', function ()
    local template = [[
Begin.
{{! Comment Block! }}
End.]]
    local expected = [[
Begin.
End.]]
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Indented Standalone
    desc: All standalone comment lines should be removed.
    data: { }
    template: |
      Begin.
        {{! Indented Comment Block! }}
      End.
    expected: |
      Begin.
      End.
  --]=]
  it('Indented Standalone', function ()
    local template = [[
Begin.
  {{! Comment Block! }}
End.]]
    local expected = [[
Begin.
End.]]
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Standalone Line Endings
    desc: '"\r\n" should be considered a newline for standalone tags.'
    data: { }
    template: "|\r\n{{! Standalone Comment }}\r\n|"
    expected: "|\r\n|"
  --]=]
  it('Standalone Line Endings', function ()
    local template = '|\r\n{{! Standalone Comment }}\r\n|'
    local expected = '|\r\n|'
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Standalone Without Previous Line
    desc: Standalone tags should not require a newline to precede them.
    data: { }
    template: "  {{! I'm Still Standalone }}\n!"
    expected: "!"
  --]=]
  it('Standalone Without Previous Line', function ()
    local template = "  {{! I'm Still Standalone }}\n!"
    local expected = '!'
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Standalone Without Newline
    desc: Standalone tags should not require a newline to follow them.
    data: { }
    template: "!\n  {{! I'm Still Standalone }}"
    expected: "!\n"
  --]=]
  it('Standalone Without Newline', function ()
    local template = "!\n  {{! I'm Still Standalone }}"
    local expected = '!\n'
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Multiline Standalone
    desc: All standalone comment lines should be removed.
    data: { }
    template: |
      Begin.
      {{!
      Something's going on here...
      }}
      End.
    expected: |
      Begin.
      End.
  --]=]
  it('Multiline Standalone', function ()
    local template = [[
Begin.
{{!
Something's going on here...
}}
End.]]
    local expected = [[
Begin.
End.]]
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Indented Multiline Standalone
    desc: All standalone comment lines should be removed.
    data: { }
    template: |
      Begin.
        {{!
          Something's going on here...
        }}
      End.
    expected: |
      Begin.
      End.
  --]=]
  it('Indented Multiline Standalone', function ()
    local template = [[
Begin.
  {{!
    Something's going on here...
  }}
End.]]
    local expected = [[
Begin.
End.]]
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Indented Inline
    desc: Inline comments should not strip whitespace
    data: { }
    template: "  12 {{! 34 }}\n"
    expected: "  12 \n"
  --]=]
  it('Indented Inline', function ()
    local template = "  12 {{! 34 }}\n"
    local expected = "  12 \n"
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

  --[=[
  - name: Surrounding Whitespace
    desc: Comment removal should preserve surrounding whitespace.
    data: { }
    template: '12345 {{! Comment Block! }} 67890'
    expected: '12345  67890'
  --]=]
  it('Surrounding Whitespace', function ()
    local template = '12345 {{! Comment Block! }} 67890'
    local expected = '12345  67890'
    local data = {}

    assert_equal(groucho.render(template, data), expected)
  end)

end)