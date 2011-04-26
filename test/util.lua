package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'util'

context('Util', function ()
  context('emptyifnil', function ()
    it('should return the same string it was given', function ()
      local template = '==> sbrubbles <=='
      local expected = template

      assert_equal(util.emptyifnil(template), expected)
    end)

    it('should return a stringified version of a non-nil non-string', function ()
      local template = 234567
      local expected = '234567'

      assert_equal(util.emptyifnil(template), expected)
    end)

    it('should return "false" when given the boolean false', function ()
      local template = false
      local expected = 'false'

      assert_equal(util.emptyifnil(template), expected)
    end)

    it('should return the empty string when given nil', function ()
      local template = nil
      local expected = ''

      assert_equal(util.emptyifnil(template), expected)
    end)
  end)

  context('islist', function ()
    it('should return true when fed a list with no holes', function ()
      local template = { 1, 2, 3, 4, 5, 6 }

      assert_true(util.islist(template))
    end)

    it('should return true when fed an empty list', function ()
      local template = {}

      assert_true(util.islist(template))
    end)

    it('should return false when fed a mixed table', function ()
      local template = { 1, 2, 3, sbrubbles = 4 }

      assert_false(util.islist(template))
    end)

    it('should return false when fed a mixed table with no array part', function ()
      local template = { sbrubbles = 4 }

      assert_false(util.islist(template))
    end)

    it('should return false when fed a sparse array', function ()
      local template = { [4] = 4 }

      assert_false(util.islist(template))
    end)
  end)

  context('escapehtml', function ()
    it('should escape &', function ()
      local template = 'Bert & Ernie'
      local expected = 'Bert &amp; Ernie'

      assert_equal(util.escapehtml(template), expected)
    end)

    it('should escape "', function ()
      local template = '1234567890\n"1234567890"'
      local expected = '1234567890\n&quot;1234567890&quot;'

      assert_equal(util.escapehtml(template), expected)
    end)

    it('should escape <', function ()
      local template = '1 < 3'
      local expected = '1 &lt; 3'

      assert_equal(util.escapehtml(template), expected)
    end)

    it('should escape >', function ()
      local template = '3 > 1'
      local expected = '3 &gt; 1'

      assert_equal(util.escapehtml(template), expected)
    end)

    it('should escape \\', function ()
      local template = 'sbrubbles\\something'
      local expected = 'sbrubbles&#92;something'

      assert_equal(util.escapehtml(template), expected)
    end)

    it('should escape all of them', function ()
      local template = 'sbrubbles\\something is "<whatever>" & "<insert insult here>"'
      local expected = 'sbrubbles&#92;something is &quot;&lt;whatever&gt;&quot; &amp; &quot;&lt;insert insult here&gt;&quot;'

      assert_equal(util.escapehtml(template), expected)
    end)

    it('should not escape other characters, no matter how odd', function ()
      local template = 'àáêõç\n\r\t'
      local expected = 'àáêõç\n\r\t'

      assert_equal(util.escapehtml(template), expected)
    end)

  end)

  context('atlinestart', function ()
    it('should return the index when at the beginning', function ()
      local template = '1234567890\n1234567890'
      local index = 12

      assert_equal(util.atlinestart(template, index), index)
    end)

    it('should return the index when at the beginning of the string', function ()
      local template = '1234567890\n1234567890'
      local index = 1

      assert_equal(util.atlinestart(template, index), index)
    end)

    it('should return false when not at the beginning', function ()
      local template = '1234567890\n1234567890'
      local index = 3

      assert_false(util.atlinestart(template, index))
    end)
  end)

  context('split', function ()
    it('should work :)', function () end)
  end)
end)