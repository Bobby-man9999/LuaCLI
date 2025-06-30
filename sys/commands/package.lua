function CMD(args)
    if args[2] == "install" then
        print("Installing package " .. args[3])
        install_package(args[3])

    elseif args[2] == "copy" then
        print("Copying package " .. args[3])
        copy_files(base_dir .. "sys\\packages\\" .. args[3], base_dir .. "sys\\commands\\")

    elseif args[2] == "cmd" then
        print("Copying cmd " .. args[4] .. " from " .. args[3])
        copy_file(
            base_dir .. "sys/packages/" .. args[3] .. "/" .. args[4] .. ".lua",
            base_dir .. "sys/commands/" .. args[4] .. ".lua"
        )

    elseif args[2] == "clear" then
        io.write("ARE YOU SURE? (Y/N) ")
        local inp = io.read()
        if inp == "Y" or inp == "y" then
            print("Purging...")
            purge(base_dir .. "sys/commands")
            print("Installing fresh package...")
            install_package("fresh")
            print("Please install luacli to get the default commands back.")
        end

    elseif args[2] == "set" then
        io.write("ARE YOU SURE? (Y/N) ")
        local inp = io.read()
        if inp == "Y" or inp == "y" then
            local pkg = args[3]
            print("Purging...")
            purge(base_dir .. "sys/commands")
            print("Installing " .. pkg .. " package...")
            install_package(pkg)
        end

    elseif args[2] == "info" then
        local file = io.open(base_dir .. "sys\\packages\\" .. args[3] .. "\\about.txt", "r")
        if file then
            print(file:read("*a"))
            file:close()
        else
            print("No about.txt found for package " .. args[3])
        end

    else
        print("Unknown package subcommand: " .. tostring(args[2]))
    end

    -- Clean up install or about files if they accidentally get copied
    os.remove(base_dir .. "sys/commands/install.lua")
    os.remove(base_dir .. "sys/commands/about.txt")

    print("Package command finished")
end
