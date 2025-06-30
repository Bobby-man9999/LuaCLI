function CMD(args)
    print("Deleting command " .. args[2])
    os.remove(base_dir .. "sys/commands/" .. args[2] .. ".lua")
    print("Command deleted.")
end