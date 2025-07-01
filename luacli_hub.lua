-- LuaCLI Home Page Script
while true do
    print("=== LuaCLI Home ===")
    print("Type 'install' to install or update an instance of LuaCLI.")
    print("Type 'copy' to duplicate an instance of LuaCLI.")
    print("Type 'delete' to delete an instance of LuaCLI.")
    print("Type 'run' to run an existing instance of LuaCLI installation.")
    print("Type 'exit' to quit.")
    print("Type 'update' to update the LuaCLI hub.")
    io.write("$> ")
    local cmd = io.read()
    local function show_loading()
        io.write("loading...")
    end
    local function clear_loading()
        io.write("\r           \r")
    end
    -- Get script directory for all operations
    local this_path = debug.getinfo(1, "S").source:sub(2)
    local script_dir = this_path:match("^(.*)[/\\][^/\\]-$") or "."

    show_loading()

    if cmd == "install" then
        
        -- Download versions.txt
        local versions_url = "https://raw.githubusercontent.com/Bobby-man9999/luacli/main/versions.txt"
        local versions_csv = script_dir .. "/versions.txt"
        local versions_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'"' .. versions_url .. "\' -OutFile \'" .. versions_csv .. "\'"
        local versions_result = os.execute(versions_cmd)
        clear_loading()
        if versions_result == 0 or versions_result == true then
            print("Available versions:")
            for line in io.lines(versions_csv) do
                print(line)
            end
            -- Delete versions.txt after use
            os.remove(versions_csv)
        else
            print("Could not fetch available versions.")
        end

        io.write("What version of LuaCLI should be installed? ")
        local version = io.read()
        io.write("Install mode: (n)ew or (u)pdate? ")
        local mode = io.read()
        io.write("Installation name (leave blank to use version): ")
        local name = io.read()
        if name == nil or name == "" then
            name = version
        end
        local outdir = script_dir .. "/LuaCLI_" .. name
        local zipfile = script_dir .. "/luacli_" .. version .. ".zip"
        local url = "https://raw.githubusercontent.com/Bobby-man9999/luacli/main/LuaCLI_" .. version .. ".zip"

        -- Download the zip file using PowerShell (Windows)
        local download_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'"' .. url .. "\' -OutFile \'" .. zipfile .. "\'"
        local download_result = os.execute(download_cmd)

        if download_result ~= 0 and download_result ~= true then
            print("Download failed!")
        else
            if mode == "u" then
                -- Update mode: extract to temp, copy all except commands
                local tempdir = script_dir .. "/temp_update"
                os.execute('if not exist "' .. tempdir .. '" mkdir "' .. tempdir .. '"')
                local unzip_result = os.execute('tar -xf "' .. zipfile .. '" -C "' .. tempdir .. '"')
                if unzip_result == 0 or unzip_result == true then
                    print("Unzip to temp successful!")
                    -- Move commands folder out of the way if it exists
                    local commands_path = outdir .. "\\commands"
                    local commands_temp = tempdir .. "_commands_backup"
                    if os.execute('if exist "' .. commands_path .. '" move "' .. commands_path .. '" "' .. commands_temp .. '"') then
                        print("Moved existing commands folder out of the way.")
                    end
                    -- Copy everything from tempdir to outdir
                    os.execute('xcopy /E /I /Y "' .. tempdir .. '\*" "' .. outdir .. '\"')
                    -- Move commands folder back
                    if os.execute('if exist "' .. commands_temp .. '" move "' .. commands_temp .. '" "' .. commands_path .. '"') then
                        print("Restored commands folder.")
                    end
                    -- Clean up tempdir
                    os.execute('rmdir /S /Q "' .. tempdir .. '"')
                    print("Update complete! (commands folder preserved)")
                else
                    print("Unzip to temp failed!")
                end
            else
                
                -- New install: normal unzip
                os.execute('if not exist "' .. outdir .. '" mkdir "' .. outdir .. '"')
                local result = os.execute('tar -xf "' .. zipfile .. '" -C "' .. outdir .. '"')
                if result == 0 or result == true then
                    print("Unzip successful!")
                else
                    print("Unzip failed!")
                end
            end
            -- Delete zip file after use
            os.remove(zipfile)
        end
    elseif cmd == "run" then
        clear_loading()
        -- List all LuaCLI installations in script_dir
        print("Available installations:")
        local installations = {}
        local p = io.popen('dir /B /AD "' .. script_dir .. '"')
        for folder in p:lines() do
            if folder:match("^LuaCLI_.*") then
                table.insert(installations, folder)
                print("[" .. #installations .. "] " .. folder)
            end
        end
        p:close()
        if #installations == 0 then
            print("No installations found.")
        else
            io.write("Select installation number: ")
            local sel = tonumber(io.read())
            local chosen = installations[sel]
            if not chosen then
                print("Invalid selection.")
            else
                -- Run the main.lua in the chosen installation
                local main_path = script_dir .. "/" .. chosen .. "/LuaCLI/main.lua"
                print("Launching: lua " .. main_path)
                os.execute('lua "' .. main_path .. '"')
            end
        end
    elseif cmd == "delete" then
        clear_loading()
        -- List all LuaCLI installations in script_dir
        print("Available installations:")
        local installations = {}
        local p = io.popen('dir /B /AD "' .. script_dir .. '"')
        for folder in p:lines() do
            if folder:match("^LuaCLI_.*") then
                table.insert(installations, folder)
                print("[" .. #installations .. "] " .. folder)
            end
        end
        p:close()
        if #installations == 0 then
            print("No installations found.")
        else
            io.write("Select installation number to delete: ")
            local sel = tonumber(io.read())
            local chosen = installations[sel]
            if not chosen then
                print("Invalid selection.")
            else
                io.write("Are you sure you want to delete '" .. chosen .. "'? (y/n): ")
                local confirm = io.read()
                if confirm == "y" or confirm == "Y" then
                    local del_cmd = 'rmdir /S /Q "' .. script_dir .. '/' .. chosen .. '"'
                    local result = os.execute(del_cmd)
                    if result == 0 or result == true then
                        print("Deleted '" .. chosen .. "'.")
                    else
                        print("Failed to delete '" .. chosen .. "'.")
                    end
                else
                    print("Delete cancelled.")
                end
            end
        end
    elseif cmd == "copy" then
        clear_loading()
        -- List all LuaCLI installations in script_dir
        print("Available installations:")
        local installations = {}
        local p = io.popen('dir /B /AD "' .. script_dir .. '"')
        for folder in p:lines() do
            if folder:match("^LuaCLI_.*") then
                table.insert(installations, folder)
                print("[" .. #installations .. "] " .. folder)
            end
        end
        p:close()
        if #installations == 0 then
            print("No installations found.")
        else
            io.write("Select installation number to copy: ")
            local sel = tonumber(io.read())
            local chosen = installations[sel]
            if not chosen then
                print("Invalid selection.")
            else
                io.write("Enter new installation name: ")
                local newname = io.read()
                if not newname or newname == "" then
                    print("No name entered. Copy cancelled.")
                else
                    local dest = script_dir .. "\\LuaCLI_" .. newname
                    local src = script_dir .. "\\" .. chosen
                    -- Remove destination if it exists
                    os.execute('if exist "' .. dest .. '" rmdir /S /Q "' .. dest .. '"')
                    local copy_cmd = 'xcopy /E /I /Y "' .. src .. '\\*" "' .. dest .. '\\"'
                    local result = os.execute(copy_cmd)
                    if result == 0 or result == true then
                        print("Copied '" .. chosen .. "' to 'LuaCLI_" .. newname .. "'.")
                    else
                        print("Failed to copy installation.")
                    end
                end
            end
        end
    elseif cmd == "exit" then
        clear_loading()
        print("Goodbye!")
        break
    else
        print("Unknown command.")
    end
end
