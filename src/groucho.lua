--[[ imports and aliases ]]
local re = require 're'

local table_remove, table_concat, io_open =
  table.remove, table.concat, io.open
local assert, ipairs, pairs, tostring, type =
  assert, ipairs, pairs, tostring, type

local print = print

--[[ module declaration ]]
module 'groucho'

--[[ helper code ]]
local function empty_on_nil(v, f)
  return v ~= nil and (f ~= nil and f(tostring(v)) or tostring(v)) or ''
end

-- escapes & \ " < >
local function escapehtml(v)
  return v:gsub('&', '&amp;'):gsub('\\', '&#92;')
          :gsub('"', '&quot;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end

local function islist(t)
  if type(t) ~= 'table' then
    return false
  end

  local key_count = 0
  for _ in pairs(t) do key_count = key_count + 1 end

  local index_count = 0
  for _ in ipairs(t) do index_count = index_count + 1 end

  return index_count == key_count
end

local grammar = [[
  Start     <- {~ Template ~} !.
  Template  <- (String (Hole String)*)
  String    <- (!Hole !OpenSection !OpenInvertedSection !CloseSection .)*
  Hole      <- Section / InvertedSection / Partial / UnescapedVar / Comment / Var
  Section         <- (
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
  CloseSectionWithTag <- %s* '{{/' =tag '}}'
  Partial         <- ('{{>' %s* { (!(%s* '}}') .)* } %s* '}}') -> partial
  Comment         <- ('{{!' (!'}}' .)* '}}') -> comment
  UnescapedVar    <- ('{{{' { Name } '}}}' / '{{&' { Name } '}}') -> unescapedVar
  Var             <- ('{{' { Name } '}}') -> var
  Name      <- [a-zA-Z_][0-9a-zA-Z_]*
]]

--[[ exports ]]
local config_defaults = { template_path = '.', template_extension = 'mustache' }

function render(template, view, config)
  config = config or config_defaults

  local patt = re.compile(grammar,
    { unescapedVar = function (var) return empty_on_nil(view[var]) end,
      var = function (var) return empty_on_nil(view[var], escapehtml) end,
      comment = function (comment) return '' end,
      partial = function (partial)
        if not config.template_path then -- file not found
          return ''
        end

        -- load the {{partial}}.mustache file
        local path, ext = config.template_path, empty_on_nil(config.template_extension)
        --print('>>', path, ext, view.template_path, view.template_extension)
        local location = path..'/'..partial..(#ext > 0 and '.'..ext or '')
        
        local text = assert(io_open(location, 'r')):read '*a'
        
        -- include it and evaluate it here
        return render(text, view, config)
      end,
      section = function (s, i, section)
        local ctx = view[section.tag]
        if not ctx then -- undefined value, nothing to do
          return i, ''
        end

        local text = s:sub(section.textstart, section.textfinish - 1)

        if type(ctx) == 'function' then -- call it to provide the result
          return i, ctx(text, view, config)
        end

        assert(type(ctx) == 'table',
          'ctx expected to be a table, not a '..type(ctx)..': '..tostring(ctx))

        if islist(ctx) then
          if #ctx == 0 then -- empty list, nothing to do
            return i, ''
          end

          -- render text for each subcontext and accumulate the results
          local results = {}
          for _, subctx in ipairs(ctx) do
            results[#results + 1] = render(text, subctx, config)
          end

          return i, table_concat(results, '\n')
        end

        -- ctx is a hash table
        return i, render(text, ctx, config)
      end,
      invertedSection = function (s, i, section)
        local ctx = view[section.tag]
        if ctx and (not islist(ctx) or #ctx > 0) then -- defined, nothing to do
          return i, ''
        end

        -- just spit out the text
        return i, s:sub(section.textstart, section.textfinish - 1)
      end, })

  return patt:match(template)
end
