-- LuaCLI Home Page Script
while true do
    print("=== LuaCLI Home ===")
    print("Type 'install' to install or update LuaCLI.")
    print("Type 'run' to run an existing LuaCLI installation.")
    print("Type 'exit' to quit.")
    io.write("> ")
    local cmd = io.read()

    if cmd == "install" then
        -- Download versions.txt
        local versions_url = "https://raw.githubusercontent.com/Bobby-man9999/luacli/main/versions.txt"
        local versions_csv = "versions.txt"
        local versions_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'"' .. versions_url .. "\' -OutFile \'" .. versions_csv .. "\'"
        local versions_result = os.execute(versions_cmd)

        if versions_result == 0 or versions_result == true then
            print("Available versions:")
            for line in io.lines(versions_csv) do
                print(line)
            end
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
        local outdir = "LuaCLI_" .. name
        local zipfile = "luacli_" .. version .. ".zip"
        local url = "https://raw.githubusercontent.com/Bobby-man9999/luacli/main/LuaCLI_" .. version .. ".zip"

        -- Download the zip file using PowerShell (Windows)
        local download_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'"' .. url .. '"\' -OutFile \'"' .. zipfile .. "\'"
        local download_result = os.execute(download_cmd)

        if download_result ~= 0 and download_result ~= true then
            print("Download failed!")
        else
            if mode == "u" then
                -- Update mode: extract to temp, copy all except commands
                local tempdir = "temp_update"
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
        end
    elseif cmd == "run" then
        -- List all LuaCLI installations
        print("Available installations:")
        local installations = {}
        local p = io.popen('dir /B /AD')
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
                local main_path = chosen .. "\\LuaCLI\\main.lua"
                print("Launching: lua " .. main_path)
                os.execute('lua "' .. main_path .. '"')
            end
        end
    elseif cmd == "exit" then
        print("Goodbye!")
        break
    else
        print("Unknown command.")
    end
end
