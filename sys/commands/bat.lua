function CMD(args)
    local path = base_dir .. "sys/files/" .. args[2]
    if not file_exists(path) then
        print("Batch file not found:", args[2])
        return
    end

    local file = io.open(path, "r")
    if not file then
        print("Failed to open file.")
        return
    end

    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$") -- Trim whitespace
        if line ~= "" then
            print(">> " .. line)
            args = split(line)
            run(args[1])
        end
    end

    file:close()
end
