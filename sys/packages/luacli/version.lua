function CMD(args)
    local lines = read_lines(base_dir .. "sys/data/version")
    if (args[2]) then print(lines[tonumber(args[2])]) else print(lines[1]) print("Use 1-4 to get levels of detail in your version ids.") end
end