--[[ imports and aliases ]]
local ipairs, pairs, select, tostring, type =
  ipairs, pairs, select, tostring, type

local lpeg = require 'lpeg'
local re = require 're'

--- Some utility functions.
--
-- @author Humberto Anjos
module 'groucho.util'

--- Packs the arguments in a table.
--
-- Parameters:
-- * ... <any...>: the values to pack.
--
-- Returns:
-- * <table> a table holding the values in ... .
-- * <integer> the amount of values given.
function pack(...)
  return { ... }, select('#', ...)
end

--- Converts v to a string (the empty string if v is nil).
--
-- Parameters:
-- * v <any>: the value to be converted to a string.
--
-- Returns:
-- * <string> the empty string if v is nil, v stringified otherwise.
function blankifnil(v)
  return v ~= nil and tostring(v) or ''
end

--- Checks if t is a list.
-- t is considered a list if it is a table and pairs and ipairs iterate over
-- t the same amount of times.
--
-- Parameters:
-- * t <any>: a value.
--
-- Returns:
-- * <boolean> true if t is a list, false otherwise.
function islist(t)
  if type(t) ~= 'table' then
    return false
  end

  local key_count = 0
  for _ in pairs(t) do key_count = key_count + 1 end

  local index_count = 0
  for _ in ipairs(t) do index_count = index_count + 1 end

  return index_count == key_count
end

--- Escapes &, \, ", <, and > into their HTML counterparts.
--
-- Parameters:
-- * v <string>: a string.
--
-- Returns:
-- * <string> v with the forementioned characters escaped into HTML entities.
function escapehtml(v)
  return v:gsub('&', '&amp;'):gsub('\\', '&#92;')
          :gsub('"', '&quot;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end

-- Pattern to detect line breaks.
local NL = re.compile '%nl'

--- Detects if the index is at the beginning of the string or of a line.
-- This function is an re-compatible pattern.
--
-- Parameters:
-- * s <string>: the string to analyze.
-- * i <integer>: the index.
--
-- Returns:
-- * <integer | boolean> i, if it's at the beginning of a line, or false
--     otherwise.
function atlinestart(s, i)
  return (i == 1 or NL:match(s:sub(i - 1, i - 1))) and i or false
end

--- Splits a string using a given LPeg pattern as separator.
-- Extracted from http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html, section
-- Splitting a string.
--
-- Parameters:
-- * s <string>: the string to split.
-- * sep <string | LPeg pattern>: the separator.
--
-- Returns:
-- * <table> a list of all the elements split by sep in s.
function split (s, sep)
  sep = lpeg.P(sep)
  local elem = lpeg.C((1 - sep)^0)
  local p = lpeg.Ct(elem * (sep * elem)^0)   -- make a table capture
  return lpeg.match(p, s)
end