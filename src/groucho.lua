--[[ imports and aliases ]]
local re = require 're'
local util = require 'util'

local table_remove, table_concat, io_open =
  table.remove, table.concat, io.open
local empty_on_nil, islist, escapehtml, atlinestart, split =
  util.empty_on_nil, util.islist, util.escapehtml, util.atlinestart, util.split
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
-- The state holds this information with the insection field, which should be
-- true when section-rendering code is being run, and false otherwise.
--
-- Parameters:
-- * state <table>: holds the shared state.
-- * func <any... -> any...>: the block of code to run.
--
-- Returns:
-- * <any... -> any...>: a function which takes the same parameters and
--     returns the same values as func, but sets state.insection to true
--     before executing func and false afterwards, but before returning for
--     good.
local function runInSection(state, func)
  return function (...)
    state.insection = true

    local results = { func(...) }

    state.insection = false
    return unpack(results)
  end
end

--- Resolves the given variable name in the given context.
-- Dotted names are considered a form of shorthand for sections, so 'a.b.c' is
-- interpreted as 'return the value of c in the context defined by b which is
-- in the context defined by a'. Any mismatch during the walking process will
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

--[[ exports ]]
--- The PEG which matches mustache templates and does the basic captures.
-- Some hooks are left to be populated later with the given context and
-- configuration to construct the actual LPeg pattern. They are:
-- * section <(string, integer, table) -> string>: a match-time capture which
--     will return the section fully rendered. The captured table holds some
--     fields to aid rendering:
--     ** tag <string>: the string to be looked up in the context.
--     ** textstart <integer>: the position in the full text where the section
--         starts.
--     ** textfinish <integer>: the position in the full text directly after
--         the section end.
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
  String    <- (!Hole !OpenSection !OpenInvertedSection !CloseSection
      !StandaloneOpenSection !StandaloneOpenInvertedSection !StandaloneCloseSection .)*
  Hole      <- Section / InvertedSection / Partial / Comment
            / UnescapedVar / Var
  Section   <- (
      {:tag: StandaloneOpenSection / OpenSection :}
      {:textstart: {} :}
      Template
      {:textfinish: {} :}
      (StandaloneCloseSectionWithTag / ({:finalspaces: %s* :} CloseSectionWithTag))) -> {} => section
  InvertedSection <- (
      {:tag: StandaloneOpenInvertedSection / OpenInvertedSection :}
      {:textstart: {} :}
      {~ Template ~}
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
  Partial         <- ('{{>' %s* { Name } %s* '}}') -> partial
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
-- * config   <table, optional>: a table holding some configurations.
--     The known configurations are:
-- ** template_path <string | nil>: the relative path where template files will
--         be searched. Defaults to '.'.
-- ** template_extension <string | nil>: the extension of the template files.
--         Defaults to 'mustache'. If set to nil or '', the files have no
--         extension.
-- * state    <table, optional>: a table holding state shared between capture
--     functions. The known fields are:
-- ** insection <boolean>: if the code is being run while processing a section.
--
-- Returns:
-- * <string> a rendered version of the template.
function render(template, context, config, state)
  config = setmetatable(config or {}, config_defaults)
  state = state or { insection = false }

  local patt = re.compile(grammar,
    { atlinestart = function (s, i) return not state.insection and atlinestart(s, i) end,
      unescapedVar = function (var)
        local resolvedvar = resolve(context, var)

        if type(resolvedvar) == 'function' then
          return empty_on_nil(render(resolvedvar(), context, config, state))
        end

        return empty_on_nil(resolvedvar)
      end,
      var = function (var)
        local resolvedvar = resolve(context, var)

        if type(resolvedvar) == 'function' then
          return escapehtml(empty_on_nil(render(resolvedvar(), context, config, state)))
        end

        return escapehtml(empty_on_nil(resolvedvar))
      end,
      comment = function (comment) return '' end,
      partial = function (partial)
        if not config.template_path then -- file not found
          return ''
        end

        -- load the {{partial}} mustache file
        local path, ext = config.template_path, empty_on_nil(config.template_extension)
        local location = path..'/'..partial..(#ext > 0 and '.'..ext or '')
        
        local text = assert(io_open(location, 'r')):read '*a'
        
        -- include it and evaluate it here
        return render(text, context, config, state)
      end,
      section = runInSection(state, function (s, i, section)
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
            for _, subctx in ipairs(ctx) do
              local newctx
              if type(subctx) == 'table' then
                newctx = setmetatable(subctx, { __index = context })
              elseif type(subctx) == 'string' or type(subctx) == 'number' then
                newctx = setmetatable(
                  { ['.'] = tostring(subctx) }, -- create the magic . variable
                  { __index = context })
              else
                error('Invalid type for context: '..type(subctx)..'!')
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
      invertedSection = runInSection(state, function (s, i, section)
        local ctx = resolve(context, section.tag)
        if ctx and (not islist(ctx) or #ctx > 0) then -- it's defined, nothing to do
          return i, ''
        end

        -- just spit out the text
        local finalspaces = empty_on_nil(section.finalspaces)
        local text = s:sub(section.textstart, (section.textfinish + #finalspaces) - 1)

        return i, render(text, context, config, state)
      end), })

  return patt:match(template)
end
