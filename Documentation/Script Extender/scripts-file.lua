---@meta

--returns true if file exists
function FILE_EXISTS(file) end

---MWWSE
---@param file string path
---@return string
---Returns string of file contents given path
function LOAD_FILE(file) end

---MWWSE
---@param file string path
---@return table
---Returns table of lines as string given path
function LINES_FROM(file) end

---MWWSE
---@param s any
---@return table
---returns a table of words/strings from a string splitting at commas
function LINE_TO_TABLE(s) end

---MWWSE
---@param _lines any
---@return table
---loads a .csv file and returns as a table
function CSV_TO_TABLE(_lines) end

---MWWSE
---@param file_name any
---@param _table any
---saves a .csv file given a table (must be a table of tables)
function TABLE_TO_CSV(file_name, _table) end

---MWWSE
---@param file string path
---@return string
---Returns table of lines as string given path 
---DEPRECATED
function LINES_FROM_BLOCK(file) end

---MWWSE
---@param file_name string
---@param contents string
---Writes file to disk given path and contents
function SAVE_FILE(file_name, contents) end

---MWWSE
---@param file_name string
---@param contents string
---Writes file to disk given path and contents
function SAVE_FILE_AND_PATH(file_name, contents) end

    --Extract directory path from file_name
        --Create directory path if it doesn't exist
    --Opens a file in write mode
        --Closes the open file
---MWWSE
---@param file_name string
---@param text string
---Appends string to file
function APPEND_FILE(file_name, text) end

---MWWSE
---@param file_name string
---@param text string
---DEPRECATED
function APPEND_FILE_NO_SPACE(file_name, text) end

---MWWSE
---@param mod_name string
---@param contents table
---@param encrypt_me_ boolean|nil
---adds save data/table to the mod settings file, encrypt_me_ is optional if will be
---stored in hidden settings file
function SAVE_GLOBAL_MOD_SETTINGS(mod_name, contents, encrypt_me_) end

---MWWSE
---@param mod_name string
---@param default_settings table
---@param encrypted_ boolean|nil
---@return table
---loads the global mod settings file and returns the table for the given mod name
function LOAD_GLOBAL_MOD_SETTINGS(mod_name, default_settings, encrypted_) end

