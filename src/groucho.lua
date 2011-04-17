--[[ imports and aliases ]]
local re = require 're'
local util = require 'util'

local table_remove, table_concat, io_open =
  table.remove, table.concat, io.open
local empty_on_nil, islist, escapehtml =
  util.empty_on_nil, util.islist, util.escapehtml
local assert, ipairs, setmetatable, tostring, type =
  assert, ipairs, setmetatable, tostring, type

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
-- * partial <string -> string>: renders partial captures, recieving the
--     template to search for.
-- * comment <string -> string>: renders comments.
-- * unescapedVar <string -> string>: renders unescaped variables.
-- * var <string -> string>: renders normal variables.
grammar = [[
  Start     <- {~ Template ~} !.
  Template  <- (String (Hole String)*)
  String    <- (!Hole !OpenSection !OpenInvertedSection !CloseSection .)*
  Hole      <- Section / InvertedSection / Partial / Comment
            / UnescapedVar / Var
  Section   <- (
    {:tag: OpenSection :}
    {:textstart: {} :}
    Template
    {:textfinish: {} :}
    CloseSectionWithTag) -> {} => section
  InvertedSection <- (
    {:tag: OpenInvertedSection :}
    {:textstart: {} :}
    Template
    {:textfinish: {} :}
    CloseSectionWithTag) -> {} => invertedSection
  OpenSection         <- '{{#' { Name } '}}' %s*
  OpenInvertedSection <- '{{^' { Name } '}}' %s*
  CloseSection        <- %s* '{{/' Name '}}'
  CloseSectionWithTag <- {:finalspaces: { %s* } :} '{{/' =tag '}}'
  Partial         <- ('{{>' %s* { Name } %s* '}}') -> partial
  Comment         <- ('{{!' { (!'}}' .)* } '}}') -> comment
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
--     There are two:
-- ** template_path <string | nil>: the relative path where template files will
--         be searched. Defaults to '.'.
-- ** template_extension <string | nil>: the extension of the template files.
--         Defaults to 'mustache'. If set to nil or '', the files have no
--         extension.
--
-- Returns:
-- * <string> a rendered version of the template.
function render(template, context, config)
  config = setmetatable(config or {}, config_defaults)

  local patt = re.compile(grammar,
    { unescapedVar = function (var) return empty_on_nil(context[var]) end,
      var = function (var) return escapehtml(empty_on_nil(context[var])) end,
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
        return render(text, context, config)
      end,
      section = function (s, i, section)
        local ctx = context[section.tag]

        if not ctx then -- undefined value, nothing to do
          return i, ''
        end

        local text = s:sub(section.textstart, section.textfinish - 1)

        if type(ctx) == 'function' then -- call it to provide the result
          return i, ctx(text, context, config)
        end

        if type(ctx) ~= 'table' then -- only the truth matters
          return i, render(text, context, config)
        end

        if islist(ctx) then
          if #ctx == 0 then -- empty list, nothing to do
            return i, ''
          end

          -- render text for each subcontext and accumulate the results
          local results = {}
          for _, subctx in ipairs(ctx) do
            results[#results + 1] = render(text, subctx, config)
          end

          -- use the spaces 
          return i, table_concat(results, section.finalspaces)
        end

        -- ctx is a hash table, use it as the new context
        return i, render(text, ctx, config)
      end,
      invertedSection = function (s, i, section)
        local ctx = context[section.tag]
        if ctx and (not islist(ctx) or #ctx > 0) then -- it's defined, nothing to do
          return i, ''
        end

        -- just spit out the text
        return i, s:sub(section.textstart, section.textfinish - 1)
      end, })

  return patt:match(template)
end
