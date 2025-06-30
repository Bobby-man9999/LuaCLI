function CMD(args)
    local cmd = (args[2] or ""):lower()
    local target = args[3]
    if (target) then
        if target:find("%.%.") or target:find("[/\\]") then
            print("Invalid file or folder name.")
            return
        end
        full_path = base_dir .. "sys/files/" .. target
    end

    if cmd == "new" then
        local f = io.open(full_path, "w")
        if f then f:close() print("Created file:", target)
        else print("Failed to create file:", target) end

    elseif cmd == "mkdir" then
        os.execute("mkdir \"" .. full_path .. "\"")
        print("Created directory:", target)

    elseif cmd == "del" then
        if file_exists(full_path) then
            os.remove(full_path)
            print("Deleted:", target)
        else
            print("File does not exist:", target)
        end

    elseif cmd == "edit" then
        print("Enter content (type ':done' on a new line to finish):")
        local lines = {}
        while true do
            io.write("> ")
            local line = io.read()
            if line == ":done" then break end
            table.insert(lines, line)
        end

        local f = io.open(full_path, "w")
        if f then
            for _, l in ipairs(lines) do
                f:write(l .. "\n")
            end
            f:close()
            print("File saved.")
        else
            print("Failed to write file.")
        end

    elseif cmd == "append" then
        io.write("Text to append (':done' to finish):\n")
        local lines = {}
        while true do
            io.write("> ")
            local line = io.read()
            if line == ":done" then break end
            table.insert(lines, line)
        end

        local f = io.open(full_path, "a")
        if f then
            for _, l in ipairs(lines) do
                f:write(l .. "\n")
            end
            f:close()
            print("Appended.")
        else
            print("Failed to append.")
        end

    elseif cmd == "empty" then
        local f = io.open(full_path, "w")
        if f then f:close() print("File emptied.")
        else print("Failed to empty file.") end

    elseif cmd == "lua" then
        if file_exists(full_path) then
            print("Running Lua script:", target)
            dofile(full_path)
        else
            print("Script not found:", target)
        end
    elseif cmd == "read" then
        if not file_exists(full_path) then
            print("File not found:", target)
            return
        end

        local f = io.open(full_path, "r")
        if f then
            print("=== " .. target .. " ===")
            for line in f:lines() do
                print(line)
            end
            f:close()
        else
            print("Failed to open file.")
        end
    elseif cmd == "uninstall" then
        local confirm = io.read()
        if confirm and confirm:lower() == "y" then
            purge(base_dir .. "sys/files")
            os.remove(base_dir .. "sys/commands/fileman.lua")
            print("fileman uninstalled and all files deleted.")
        else
            print("Uninstall cancelled.")
        end
    elseif cmd == "copy" then
        local to = args[4]
        if not to then
            print("Usage: fileman copy <source> <target>")
        else
            local from_path = full_path
            local to_path = base_dir .. "sys/files/" .. to
            local ok, err = copy_file(from_path, to_path)
            if ok then
                print("Copied to:", to)
            else
                print("Copy failed:", err)
            end
        end
    elseif cmd == "ls" then
        local dir = args[3]
        print(" === files ===")
        print(table.concat(list_files(base_dir .. "sys/files/" .. dir), "\n"))
    else
        print("Unknown subcommand: " .. cmd)
        print("Valid subcommands: new, mkdir, del, edit, append, empty, lua")
    end
end
