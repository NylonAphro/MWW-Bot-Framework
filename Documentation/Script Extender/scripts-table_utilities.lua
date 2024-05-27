---@meta

--utility mods
---Returns a string equal to the contents of ipairs
function TABLE_TO_STRING(table_) end

---Returns a string equal to the contents of a table with comma separation
function TABLE_TO_STRING_ONE_LINE(table_) end

---Returns a string equal to the contents of a table with comma separation
function PAIRS_TO_STRING_ONE_LINE(table_) end

---Returns a string equal to the contents of a table pairs
function PAIRS_TO_STRING(table_, max_depth_, tabs_, depth_, table_table_) end

---MWWSE
---@param table_ table
---@param max_depth_ integer|nil
---prints to log table
function PRINT_TABLE(table_, max_depth_, tabs_, depth_) end

---Returns a string equal to the contents of a table pairs
function MARKUP_PAIRS_TO_STRING(table_, max_depth_, tabs_, depth_, table_table_) end

---MWWSE
---@param table_ table
---@param max_depth_ integer|nil
---prints to log table
function PRINT_MARKUP_TABLE(table_, max_depth_, tabs_, depth_) end

---Returns a string equal to the contents of a table with delim separation
function TABLE_TO_STRING_DELIM(table_, delim) end

---MWWSE
---@param input string
---@param wanted_length integer
---@return string
---this is actually shet and i dunno why it is here
function FIT_TO(input, wanted_length) end

---comment
---@param input_string any
---@param max_length any
---@return string
function CUT_STRING(input_string, max_length) end

---MWWSE
---@param value any
---@param table table
---@param depth_ integer|nil
---@return boolean
---returns true if table/subtables contain value
function TABLE_CONTAINS_VALUE(value, table, depth_) end

---MWWSE
---@param name string|key
---@param table table
---@param depth_ integer|nil
---@return table
---returns table/list of all variables/sub tables with matching key
function RECURSIVE_SEARCH(name, table, depth_, found_items_) end

---MWWSE
---@param name string|key
---@param table table
---@param depth_ integer|nil
---@return boolean
---returns true if table/subtables contains key
function TABLE_CONTAINS_KEY(name, table, depth_) end

---MWWSE
---@param name string
---@param table table
---@param depth_ integer
---@return table
---returns table/list of all variables/sub tables with matching key in a given markup table
function RECURSIVE_SEARCH_MARKUP(name, table, depth_) end

---MWWSE
---@param table table
---@param depth any
---@param found_items_ any
---@return table
function MAP_MARKUP(table, depth_, found_items_) end

---MWWSE
---@param table table
---@param name string
---@param new_value any
---@param depth_ integer
---recursively sets every value per matching key/var pair in given table
---up to a max depth
function RECURSIVE_SET(table, name, new_value, depth_) end

---MWWSE
---@param tbl any
function DESTROY_TABLE(tbl, visited) end

---MWWSE
---@param tbl any
function DESTROY_MARKP_TABLE(tbl, visited) end

---MWWSE
---@param a table
---@param b table
---@param depth_ boolean|nil
---@return table
---returns table merged with b,
---b elements will overwrite a 
function MERGE_TABLE(a, b, depth_) end

---MWWSE
---custom comparison function for alphabetical sorting end

---custom comparison function for alphabetical sorting
function COMPARE_ALPHABETICALLY(a, b)  end

---MWWSE
---function to sort the table alphabetically end

---function to sort the table alphabetically
function SORT_TABLE_ALPHABETICALLY(input_table)  end

---MWWSE
---Function to filter the sorted table by prefix
function FILTER_TABLE_BY_PREFIX(input_table, prefix) end

---MWWSE
---@param tableToCount any
---@return unknown
---returns number of pairs in table
function COUNT_TABLE_PAIRS(tableToCount) end

---MWWSE
SE = SE or {}
SE.table_utilities = {
	---comment
	---@param input_table any
	clear_table = function(input_table)
		for k, v in pairs(input_table) do
			input_table[k] = nil
		end
	end,
}


