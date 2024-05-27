---@meta

---MWWSE
---@param text string
---@param delimiter string
---@return string
function STRING_AFTER(text, delimiter) end

---MWWSE
---@param text string
---@param delimiter string
---@return string
function STRING_BEFORE(text, delimiter) end

---MWWSE
---@param s string
---@param start string
---@return boolean
function STRING_STARTS_WITH(s, start) end

---MWWSE
---@param s string
---@param start string
---@return boolean
function STRING_ENDS_WITH(s, start) end

function STRING_CONTAINS(main_string, sub_string) end

---MWWSE
---@param input_string string The input string where replacements will be made.
---@param search string The substring to search for within the input string.
---@param replace string The replacement string to substitute for each occurrence of 'search'.
---@return string result A new string with all occurrences of 'search' replaced by 'replace'.
--- Replace all occurrences of a substring in a given string.
function REPLACE_ALL_OCCURRENCES(input_string, search, replace) end

--- Splits a given input string into chunks while attempting to maintain word integrity.
--- Lines are split based on two criteria: an absolute maximum line size (`max_line_size`)
--- and a desired line size (`wanted_line_size`). Words are wrapped if adding a new word
--- would exceed the current line's length. Lines are split and wrapped as needed to
--- adhere to the desired line size, while staying within the absolute maximum line size.
---
--- @param input_string string The input string to be split into chunks.
--- @param max_line_size number The absolute maximum size that a line can have (including word wrapping).
--- @param wanted_line_size number The desired length for each line (attempted for word wrapping).
--- @return table An array of strings representing the split chunks of the input string.
function SPLIT_STRING_INTO_CHUNKS(input_string, max_line_size, wanted_line_size) end

---MWWSE
---@param input_string any
---@return table
---Splits string into chuncks at newlines characters 
---and returns a table with the chuncks
function SPLIT_STRING_AT_NEWLINE(input_string) end

function REMOVE_SUBSTRING(original_string, substring) end

---MWWSE
---returns date as string in format "DD/MMM/YYYY"
---@return string|osdate
function GET_DATE() end

---MWWSE
---returns date as string in format "DD/MMM/YYYY"
---@return string|osdate
function GET_DATE_AND_TIME() end

function POINT_TO_STRING(point) end

-- helper function to capitalize the first letter of each word in a string end

-- helper function to capitalize the first letter of each word in a string
function CAPITALIZE_WORDS(inputString) end

