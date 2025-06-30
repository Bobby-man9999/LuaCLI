function CMD(args)
    print("Setting prompt to: " .. args[2])
    local file = io.open(base_dir .. "/sys/data/prompt", "w")  -- "w" = write (overwrite)
    file:write(args[2])
    file:close()
    print("Reload for changes to take effect.")
end