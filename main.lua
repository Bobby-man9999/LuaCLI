-- Get path of this running script
local path = debug.getinfo(1, "S").source:sub(2)
base_dir = path:match("^(.*[\\/])")
local prompt_file = io.open(base_dir .. "/sys/data/prompt", "r")
prompt = prompt_file:read("*l") or "$>"
prompt_file:close()
EXIT = false
os.execute('cls')

function crash()
    print('A fatal error has occurred. Restarting LuaCLI.')
    restart()
end

function split(input, sep)
    local result = {}
    sep = sep or "%s"
    for part in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(result, part)
    end
    return result
end

function restart()
    local script_path = debug.getinfo(1, "S").source:sub(2)

    -- If running on Windows, you may need to escape backslashes or quote the path
    local is_windows = package.config:sub(1, 1) == "\\"
    local lua_cmd = "lua \"" .. script_path .. "\""

    print("Restarting...")

    -- Execute the same script again
    os.execute(lua_cmd)

    -- Terminate the current instance
    os.exit()
end

function refresh()
    print("Reloading...")
    local prompt_file = io.open(base_dir .. "/sys/data/prompt", "r")
    prompt = prompt_file:read("*l") or "$>"
    prompt_file:close()
    print("Reload finished")
end



function file_exists(name)
    local f = io.open(name, "r")
    if f then f:close() return true else return false end
end

function read_lines(filename)
    local lines = {}
    local file = io.open(filename, "r")
    if not file then return nil, "Could not open file: " .. filename end

    for line in file:lines() do
        table.insert(lines, line)
    end

    file:close()
    return lines
end

function purge(folder)
    -- Ensure folder ends with backslash
    if not folder:match("[\\/]$") then folder = folder .. "\\" end

    -- Delete all files
    os.execute('del /F /Q "' .. folder .. '*"')

    -- Delete all subdirectories
    os.execute('for /D %i in ("' .. folder .. '*") do @rmdir /S /Q "%i"')
end

function copy_files(source_dir, target_dir)
    -- Ensure trailing backslashes
    if not source_dir:match("[\\/]$") then source_dir = source_dir .. "\\" end
    if not target_dir:match("[\\/]$") then target_dir = target_dir .. "\\" end

    -- Create the destination folder if it doesn't exist
    os.execute("if not exist \"" .. target_dir .. "\" mkdir \"" .. target_dir .. "\"")

    -- Copy all files (non-recursive)
    local cmd = "xcopy \"" .. source_dir .. "*\" \"" .. target_dir .. "\" /Y /Q"
    os.execute(cmd)
end

function copy_file(from_path, to_path)
    local infile = io.open(from_path, "rb")
    if not infile then
        return false, "Cannot open source file: " .. from_path
    end

    local content = infile:read("*a")
    infile:close()

    local outfile = io.open(to_path, "wb")
    if not outfile then
        return false, "Cannot open destination file: " .. to_path
    end

    outfile:write(content)
    outfile:close()

    return true
end


function list_files(dir)
    local files = {}

    -- Use Windows 'dir /B' to get file list (bare format, no headers)
    local cmd = 'dir "' .. dir .. '" /B /A:-D'  -- /A:-D means "exclude directories"
    local pipe = io.popen(cmd, 'r')

    if not pipe then
        return nil, "Failed to open directory"
    end

    for line in pipe:lines() do
        table.insert(files, line)
    end

    pipe:close()
    return files
end

function is_directory_empty(path)
    local is_windows = package.config:sub(1,1) == "\\"
    local check_cmd

    if is_windows then
        -- /B = bare format, /A = show all (even hidden)
        check_cmd = 'dir "' .. path .. '" /B /A 2>nul'
    else
        -- -A = list all except . and ..
        check_cmd = 'ls -A "' .. path .. '" 2>/dev/null'
    end

    local handle = io.popen(check_cmd)
    local output = handle:read("*a")
    handle:close()

    -- Trim whitespace
    output = output:match("^%s*(.-)%s*$")

    return output == ""  -- true if no contents
end

function install_package(package)
    if (file_exists(base_dir .. "/sys/packages/" .. package .. "/install.lua")) then
        dofile(base_dir .. "/sys/packages/" .. package .. "/install.lua")
    else
        copy_files(base_dir .. "/sys/packages/" .. package, base_dir .. "/sys/commands")
    end
end

function run(cmd)
    local full_path = base_dir .. "sys/commands/" .. cmd .. ".lua"
    if not file_exists(full_path) then
        print("Command not found: " .. cmd)
    end

    ok, err = pcall(function()
        dofile(full_path)
        if (#args ~= arg_count) then
            CMD(args)
        else
            print(cmd .. " requires " .. arg_count .. " args.")
        end
    end)
end




-- The actual script
print('Running LuaCLI on "' .. _VERSION .. '"')
-- Get version as a number, like 5.4 or 5.1
local major, minor = _VERSION:match("Lua (%d)%.(%d)")
local version_num = tonumber(major) + tonumber(minor) / 10

if version_num < 5.1 then
    error("Your lua version (" .. _VERSION .. ") is too old. Please use Lua 5.1 or higher.")
end


if (not file_exists(base_dir .. "sys\\commands\\package.lua")) then
    copy_files(base_dir .. "sys\\packages\\fresh\\", base_dir .. "sys\\commands\\")
    print("Please install the luacli package with \"package install luacli\"")
end

if (file_exists(base_dir .. "sys/startup/startup.lua")) then
    dofile(base_dir .. "sys/startup/startup.lua")
end

while true do
    if (EXIT) then
        break
    end
    io.write(prompt .. ' ')
    local cmd = io.read()
    if not cmd then break end
    if cmd == "exit" then break end
    if cmd == "er" then copy_files(base_dir .. "sys\\packages\\fresh\\", base_dir .. "sys\\commands\\") end
--[[
    args = split(cmd)
    if #args == 0 then print("Please enter a cmd") end
    
    run(args[1])
]]
    for raw_cmd in string.gmatch(cmd, "([^;]+)") do
        args = split(raw_cmd)
        if #args == 0 then
            print("Please enter a cmd")
        else
            run(args[1])
        end

        if not ok then
            if err then print("Error: " .. err)
            else print("An unknown error occurred") end
        end
    end

    if not ok then
        if (err) then
            print("Error: " .. err)
        else
            print("An unknown error occurred")
        end
    end
    if (EXIT) then
        break
    end
end