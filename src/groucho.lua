--[[ imports and aliases ]]
local re = require 're'
local util = require 'util'

local table_remove, table_concat, io_open =
  table.remove, table.concat, io.open
local emptyifnil, islist, escapehtml, atlinestart, split =
  util.emptyifnil, util.islist, util.escapehtml, util.atlinestart, util.split
local assert, error, ipairs, setmetatable, tostring, type, unpack =
  assert, error, ipairs, setmetatable, tostring, type, unpack

local print = print

--- A vanilla Mustache implementation for Lua.
-- Check http://mustache.github.com/mustache.5.html for the specification.
--
-- @author Humberto Anjos
module 'groucho'

--[[ helper code ]]
--- The metatable for configuration tables with its default values.
local config_defaults = {
  __index = { template_path = '.', template_extension = 'mustache' }
}

--- Makes sure the given function is run in a section.
-- The state holds this information with the inSection field, which should be
-- true when section-rendering code is being run, and false otherwise.
--
-- Parameters:
-- * state <table>: holds the shared state.
-- * func <any... -> any...>: the block of code to run.
--
-- Returns:
-- * <any... -> any...>: a function which takes the same parameters and
--     returns the same values as func, but sets state.inSection to true
--     before executing func and false afterwards, but before returning for
--     good.
local function inSection(state, func)
  return function (...)
    state.inSection = true

    local results = { func(...) }

    state.inSection = false
    return unpack(results)
  end
end

--- Resolves the given variable name in the given context.
-- Dotted names are considered a form of shorthand for sections, so "a.b.c" is
-- interpreted as "return the value of c in the context defined by b which is
-- in the context defined by a". Any mismatch during the walking process will
-- return nil.
--
-- Parameters:
-- * context <table>: the initial context for variable lookup.
-- * var <string>: the variable name, or a dotted name holding the variable's
--     location.
--
-- Returns:
-- * <any> nil if var could not be resolved against context, the value found
--     otherwise.
local function resolve(context, var)
  -- check for the internal iterator . first
  if var == '.' then
    return context['.']
  end

  local path = split(var, '.')

  if #path == 0 then
    return nil
  elseif #path == 1 then
    return context[var]
  end

  -- iterate until the next to last name, since all of these names must
  -- resolve to hash tables
  local currentctx = context
  for i = 1, #path - 1 do
    local newctx = currentctx[ path[i] ]

    if newctx == nil
    or type(newctx) ~= 'table'
    or islist(newctx) then -- lookup fail, nothing found
      return nil
    end

    currentctx = newctx
  end

  return currentctx[path[#path]]
end

--- Searches for the file in the given path and with the given extension.
--
-- Parameters:
-- * filename <string>: the name of the file.
-- * config   <table>: a table holding some configuration options.
--     The known configurations are:
-- ** template_path <string>: the relative path where template
--     files will be searched.
-- ** template_extension <string (optional)>: the extension of the template
--     files. If set to nil or '', the files have no extension.
--
-- Returns:
-- * <file>: a read-only open file handle to the partial file.
--
-- Panics:
-- * the file does not exist.
-- * the file exists, but could not be opened for reading.
local function findpartialfile(filename, config)
  local path, ext = config.template_path, emptyifnil(config.template_extension)
  local location = path..'/'..filename..(#ext > 0 and '.'..ext or '')

  return assert(io_open(location, 'r'))
end

--- Indents all lines in the given text with the given indentation.
--
-- Parameters:
-- * text <string>: an amount of text.
-- * indentation <string>: the indentation to be added to every line.
--
-- Returns:
-- * <string>: text, with all its lines indented.
local function addindentation(text, indentation)
  if not indentation or indentation == '' then
    return text
  end

  local lastchar = text:sub(-1)
  return indentation..text:sub(1, -2):gsub('\n', '\n'..indentation)..lastchar
end

--- Finds the given partial file and returns its text after indentation.
--
-- Parameters:
-- * filename <string>: the name of the file.
-- * indentation <string>: the indentation to be added to every line of the
--     file's text.
-- * config <table>: a table holding some configuration options, as described
--     in [[findpartialfile]]'s documentation.
--
-- Returns:
-- * <string>: the partial file's text, with all its lines indented.
--
-- Panics:
-- * for the same reasons findpartialfile panics.
local function processpartial(filename, indentation, config)
  local file = findpartialfile(filename, config)
    local text = file:read '*a'
  file:close()
  
  return addindentation(text, indentation)
end

--[[ exports ]]
--- The PEG which matches mustache templates and does the basic captures.
-- Some hooks are left to be populated later with the given context and
-- configuration to construct the actual LPeg pattern. They are:
-- * section <(string, integer, table) -> string>: a match-time capture which
--     will return the section fully rendered. The captured table holds some
--     fields to aid rendering:
-- ** tag <string>: the string to be looked up in the context.
-- ** textstart <integer>: the position in the full text where the section
--     starts.
-- ** textfinish <integer>: the position in the full text directly after the
--     section end.
-- ** finalspaces <string (optional)>: the spaces just before the closing tag.
--     Exists only if the closing tag is not standalone.
-- * invertedSection <(string, integer, table) -> string>: a match-time capture
--     just like section, but applied to inverted sections.
-- * partial <string -> string>: renders partial captures, receiving the
--     template to search for.
-- * comment <string -> string>: renders comments.
-- * unescapedVar <string -> string>: renders unescaped variables.
-- * var <string -> string>: renders normal variables.
-- * atlinestart <(string, integer) -> (integer | boolean)>: an LPeg
--     function pattern to check if the index is at the beginning of the
--     template or of a line.
grammar = [[
  Start     <- {~ Template ~} !.
  Template  <- (String (Hole String)*)
  Body      <- (String (InnerHole String)*)
  String    <- (!Hole !InnerPartial !OpenSection !OpenInvertedSection !CloseSection
      !StandaloneOpenSection !StandaloneOpenInvertedSection !StandaloneCloseSection .)*
  Hole      <- Section / InvertedSection / Partial / Comment
            / UnescapedVar / Var
  InnerHole <- Section / InvertedSection / InnerPartial / Comment
            / UnescapedVar / Var
  Section   <- (
      {:tag: StandaloneOpenSection / OpenSection :}
      {:textstart: {} :}
      Body
      {:textfinish: {} :}
      (StandaloneCloseSectionWithTag / ({:finalspaces: %s* :} CloseSectionWithTag))) -> {} => section
  InvertedSection <- (
      {:tag: StandaloneOpenInvertedSection / OpenInvertedSection :}
      {:textstart: {} :}
      Body
      {:textfinish: {} :}
      (StandaloneCloseSectionWithTag / ({:finalspaces: %s* :} CloseSectionWithTag))) -> {} => invertedSection
    OpenSection         <- '{{#' %s* { Name } %s* '}}'
    OpenInvertedSection <- '{{^' %s* { Name } %s* '}}'
    CloseSection        <- '{{/' %s* Name %s* '}}'
    CloseSectionWithTag <- '{{/' %s* =tag %s* '}}'
    StandaloneOpenSection         <- %atlinestart (!%nl %s)* OpenSection         (!%nl %s)* %nl
    StandaloneOpenInvertedSection <- %atlinestart (!%nl %s)* OpenInvertedSection (!%nl %s)* %nl
    StandaloneCloseSection        <- %atlinestart (!%nl %s)* CloseSection        (!%nl %s)* (%nl / !.)
    StandaloneCloseSectionWithTag <- %atlinestart (!%nl %s)* CloseSectionWithTag (!%nl %s)* (%nl / !.)
  Partial         <- (StandalonePartial / InlinePartial) -> {} -> partial
    StandalonePartial <- %atlinestart {:indentation: (!%nl %s)* :} InlinePartial (!%nl %s)* (%nl / !.)
    InlinePartial     <- '{{>' %s* { Name } %s* '}}'
  InnerPartial    <- (StandalonePartial / InlinePartial) -> {} -> innerPartial
  Comment         <- (StandaloneComment / InlineComment) -> comment
    StandaloneComment <- %atlinestart (!%nl %s)* InlineComment (!%nl %s)* (%nl / !.)
    InlineComment     <- '{{!' (!'}}' .)* '}}'
  UnescapedVar    <- ('{{{' %s* { (!(%s* '}}}') .)* } %s* '}}}'
                  / '{{&' %s* { Name } %s* '}}') -> unescapedVar
  Var             <- ('{{' ![!#>/{&^] %s* { Name } %s* '}}') -> var
  Name  <- (!(%s* '}}') .)*
]]

--- Returns a rendered string with all tags populated with the given context.
--
-- Parameters:
-- * template <string>: a template.
-- * context  <table>: a table holding the values for replacement.
-- * config   <table (optional)>: a table holding some configuration options.
--     The known configurations are:
-- ** template_path <string (optional)>: the relative path where template
--     files will be searched. Defaults to '.'.
-- ** template_extension <string (optional)>: the extension of the template
--     files. Defaults to 'mustache'. If set to nil or '', the files have no
--     extension.
-- * state    <table (optional)>: a table holding state shared between capture
--     functions. The known fields are:
-- ** inSection <boolean>: if the code is being run while processing a section.
--
-- Returns:
-- * <string> a rendered version of the template.
--
-- Panics:
-- * the partial file does not exist.
-- * the partial file exists, but could not be opened for reading.
-- * a section resolves to a list which has elements that are neither a table,
--     a string, a boolean nor a number.
function render(template, context, config, state)
  config = setmetatable(config or {}, config_defaults)
  state = state or { inSection = false }

  local patt = re.compile(grammar,
    { atlinestart = function (s, i) return not state.inSection and atlinestart(s, i) end,
      unescapedVar = function (var)
        local resolvedvar = resolve(context, var)

        if type(resolvedvar) == 'function' then
          return emptyifnil(render(resolvedvar(), context, config, state))
        end

        return emptyifnil(resolvedvar)
      end,
      var = function (var)
        local resolvedvar = resolve(context, var)

        if type(resolvedvar) == 'function' then
          return escapehtml(emptyifnil(render(resolvedvar(), context, config, state)))
        end

        return escapehtml(emptyifnil(resolvedvar))
      end,
      comment = function (comment) return '' end,
      partial = function (partial)
        if not config.template_path then -- file not found
          return ''
        end

        local text = processpartial(partial[1], partial.indentation or '', config)

        -- include it and evaluate it here
        return render(text, context, config, state)
      end,
      innerPartial = function (partial)
        if not config.template_path then -- file not found
          return ''
        end

        local name, indentation = partial[1], partial.indentation or ''
        local text = processpartial(name, indentation, config)

        -- HACK: substitute this partial to an unescaped variable with a
        -- similar known name, and map this variable to a function which
        -- will return the partial's text. It will be called later when
        -- section is resolved.
        context['partial: '..name] = function () return text end

        return '{{{ partial: '..name..' }}}'
      end,
      section = inSection(state, function (s, i, section)
          local ctx = resolve(context, section.tag)

          if not ctx then -- undefined value, nothing to do
            return i, ''
          end

          local text = s:sub(section.textstart, section.textfinish - 1)

          if type(ctx) == 'function' then -- call it to provide the result
            return i, render(ctx(text), context, config, state)
          end

          if type(ctx) ~= 'table' then -- only the truth matters
            return i, render(text, context, config, state)
          end

          if islist(ctx) then
            if #ctx == 0 then -- empty list, nothing to do
              return i, ''
            end

            -- render text for each subcontext and accumulate the results
            local results = {}
            for index, subctx in ipairs(ctx) do
              local typectx = type(subctx)
              local newctx
              if typectx == 'table' then
                newctx = setmetatable(subctx, { __index = context })
              elseif typectx == 'string'
                  or typectx == 'number'
                  or typectx == 'boolean' then
                newctx = setmetatable(
                  { ['.'] = tostring(subctx) }, -- create the magic . variable
                  { __index = context })
              else
                error('The context in section '..section.tag..' at index '
                  ..index..' has an invalid type ('..typectx..')!')
              end


              results[#results + 1] = render(text, newctx, config, state)
            end

            -- use the spaces
            return i, table_concat(results, section.finalspaces or '')
          end

          -- ctx is a hash table, use it as the new context, which can also
          -- access variables defined in context
          return
            i,
            render(text,
              setmetatable(ctx, { __index = context }),
              config,
              state)
        end),
      invertedSection = inSection(state, function (s, i, section)
        local ctx = resolve(context, section.tag)
        if ctx and (not islist(ctx) or #ctx > 0) then -- it's defined, nothing to do
          return i, ''
        end

        -- render the inner text
        local finalspaces = emptyifnil(section.finalspaces)
        local text = s:sub(section.textstart, (section.textfinish + #finalspaces) - 1)

        return i, render(text, context, config, state)
      end), })

  return patt:match(template)
end
