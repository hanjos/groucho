package.path = '../src/?.lua;../src/?/init.lua;'..package.path

require 'telescope'
require 'groucho'

-- extracted from https://github.com/mustache/spec, v1.1.2

context('Lambdas', function ()
  context('Interpolation', function ()
    --[=[
    - name: Interpolation
      desc: A lambda's return value should be interpolated.
      data:
        lambda: !code
          ruby:   'proc { "world" }'
          perl:   'sub { "world" }'
          js:     'function() { return "world" }'
          php:    'return "world";'
          python: 'lambda: "world"'
      template: "Hello, {{lambda}}!"
      expected: "Hello, world!"
    --]=]
    it('Interpolation', function ()
      local template = "Hello, {{lambda}}!"
      local expected = "Hello, world!"
      local data = { lambda = function () return 'world' end }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Interpolation - Expansion
      desc: A lambda's return value should be parsed.
      data:
        planet: "world"
        lambda: !code
          ruby:   'proc { "{{planet}}" }'
          perl:   'sub { "{{planet}}" }'
          js:     'function() { return "{{planet}}" }'
          php:    'return "{{planet}}";'
          python: 'lambda: "{{planet}}"'
      template: "Hello, {{lambda}}!"
      expected: "Hello, world!"
    --]=]
    it('Interpolation - Expansion', function ()
      local template = "Hello, {{lambda}}!"
      local expected = "Hello, world!"
      local data = { lambda = function () return '{{planet}}' end, planet = 'world' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Interpolation - Alternate Delimiters
      desc: A lambda's return value should parse with the default delimiters.
      data:
        planet: "world"
        lambda: !code
          ruby:   'proc { "|planet| => {{planet}}" }'
          perl:   'sub { "|planet| => {{planet}}" }'
          js:     'function() { return "|planet| => {{planet}}" }'
          php:    'return "|planet| => {{planet}}";'
          python: 'lambda: "|planet| => {{planet}}"'
      template: "{{= | | =}}\nHello, (|&lambda|)!"
      expected: "Hello, (|planet| => world)!"
    --]=]
    --[[ TODO: uncomment when Set Delimiters is implemented
    it('Interpolation - Alternate Delimiters', function ()
      local template = "{{= | | =}}\nHello, (|&lambda|)!"
      local expected = "Hello, (|planet| => world)!"
      local data = { lambda = function () return "|planet| => {{planet}}" end, planet = 'world' }

      assert_equal(groucho.render(template, data), expected)
    end)
    --]]
    --[=[
    - name: Interpolation - Multiple Calls
      desc: Interpolated lambdas should not be cached.
      data:
        lambda: !code
          ruby:   'proc { $calls ||= 0; $calls += 1 }'
          perl:   'sub { no strict; $calls += 1 }'
          js:     'function() { return (g=(function(){return this})()).calls=(g.calls||0)+1 }'
          php:    'global $calls; return ++$calls;'
          python: 'lambda: globals().update(calls=globals().get("calls",0)+1) or calls'
      template: '{{lambda}} == {{{lambda}}} == {{lambda}}'
      expected: '1 == 2 == 3'
    --]=]
    it('Interpolation - Multiple Calls', function ()
      local template = '{{lambda}} == {{{lambda}}} == {{lambda}}'
      local expected = '1 == 2 == 3'
      local calls = 0
      local data = { lambda = function () calls = calls + 1; return calls end }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Escaping
      desc: Lambda results should be appropriately escaped.
      data:
        lambda: !code
          ruby:   'proc { ">" }'
          perl:   'sub { ">" }'
          js:     'function() { return ">" }'
          php:    'return ">";'
          python: 'lambda: ">"'
      template: "<{{lambda}}{{{lambda}}}"
      expected: "<&gt;>"
    --]=]
    it('Escaping', function ()
      local template = "<{{lambda}}{{{lambda}}}"
      local expected = "<&gt;>"
      local data = { lambda = function () return '>' end }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Sections', function ()
    --[=[
    - name: Section
      desc: Lambdas used for sections should receive the raw section string.
      data:
        x: 'Error!'
        lambda: !code
          ruby:   'proc { |text| text == "{{x}}" ? "yes" : "no" }'
          perl:   'sub { $_[0] eq "{{x}}" ? "yes" : "no" }'
          js:     'function(txt) { return (txt == "{{x}}" ? "yes" : "no") }'
          php:    'return ($text == "{{x}}") ? "yes" : "no";'
          python: 'lambda text: text == "{{x}}" and "yes" or "no"'
      template: "<{{#lambda}}{{x}}{{/lambda}}>"
      expected: "<yes>"
    --]=]
    it('Section', function ()
      local template = "<{{#lambda}}{{x}}{{/lambda}}>"
      local expected = "<yes>"
      local data = { lambda = function (text) return text == '{{x}}' and 'yes' or 'no' end, x = 'Error!' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Section - Expansion
      desc: Lambdas used for sections should have their results parsed.
      data:
        planet: "Earth"
        lambda: !code
          ruby:   'proc { |text| "#{text}{{planet}}#{text}" }'
          perl:   'sub { $_[0] . "{{planet}}" . $_[0] }'
          js:     'function(txt) { return txt + "{{planet}}" + txt }'
          php:    'return $text . "{{planet}}" . $text;'
          python: 'lambda text: "%s{{planet}}%s" % (text, text)'
      template: "<{{#lambda}}-{{/lambda}}>"
      expected: "<-Earth->"
    --]=]
    it('Section - Expansion', function ()
      local template = "<{{#lambda}}-{{/lambda}}>"
      local expected = "<-Earth->"
      local data = { lambda = function (text) return text..'{{planet}}'..text end, planet = 'Earth' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Section - Alternate Delimiters
      desc: Lambdas used for sections should parse with the current delimiters.
      data:
        planet: "Earth"
        lambda: !code
          ruby:   'proc { |text| "#{text}{{planet}} => |planet|#{text}" }'
          perl:   'sub { $_[0] . "{{planet}} => |planet|" . $_[0] }'
          js:     'function(txt) { return txt + "{{planet}} => |planet|" + txt }'
          php:    'return $text . "{{planet}} => |planet|" . $text;'
          python: 'lambda text: "%s{{planet}} => |planet|%s" % (text, text)'
      template: "{{= | | =}}<|#lambda|-|/lambda|>"
      expected: "<-{{planet}} => Earth->"
    --]=]
    --[=[ TODO: uncomment when Set Delimiters is implemented
    it('Section - Alternate Delimiters', function ()
      local template = "{{= | | =}}<|#lambda|-|/lambda|>"
      local expected = "<-{{planet}} => Earth->"
      local data = { lambda = function (text) return text.."{{planet}} => |planet|"..text end, planet = 'Earth' }

      assert_equal(groucho.render(template, data), expected)
    end)
    --]=]
    --[=[
    - name: Section - Multiple Calls
      desc: Lambdas used for sections should not be cached.
      data:
        lambda: !code
          ruby:   'proc { |text| "__#{text}__" }'
          perl:   'sub { "__" . $_[0] . "__" }'
          js:     'function(txt) { return "__" + txt + "__" }'
          php:    'return "__" . $text . "__";'
          python: 'lambda text: "__%s__" % (text)'
      template: '{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}'
      expected: '__FILE__ != __LINE__'
    --]=]
    it('Section - Multiple Calls', function ()
      local template = '{{#lambda}}FILE{{/lambda}} != {{#lambda}}LINE{{/lambda}}'
      local expected = '__FILE__ != __LINE__'
      local data = { lambda = function (text) return "__"..text.."__" end }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Inverted Section
      desc: Lambdas used for inverted sections should be considered truthy.
      data:
        static: 'static'
        lambda: !code
          ruby:   'proc { |text| false }'
          perl:   'sub { 0 }'
          js:     'function(txt) { return false }'
          php:    'return false;'
          python: 'lambda text: 0'
      template: "<{{^lambda}}{{static}}{{/lambda}}>"
      expected: "<>"
    --]=]
    it('Inverted Section', function ()
      local template = "<{{^lambda}}{{static}}{{/lambda}}>"
      local expected = "<>"
      local data = { lambda = function (text) return false end, static = 'static' }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)
end)