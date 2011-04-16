--[[ imports and aliases ]]
local ipairs, pairs, tostring, type = ipairs, pairs, tostring, type 

--- Some utility functions.
--
-- @author Humberto Anjos
module 'util'

--[[ exports ]]
--- Converts v to a string (the empty string if v is nil).
--
-- Parameters:
-- * v <any>: the value to be converted to a string.
--
-- Returns:
-- * <string>: the empty string if v is nil, v stringified otherwise.
function empty_on_nil(v)
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
-- * <string>: v with the forementioned characters escaped into HTML entities.
function escapehtml(v)
  return v:gsub('&', '&amp;'):gsub('\\', '&#92;')
          :gsub('"', '&quot;'):gsub('<', '&lt;'):gsub('>', '&gt;')
end
