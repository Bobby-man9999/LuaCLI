arg_count = 1

function CMD(args)
    dofile(base_dir .. "/sys/commands/piping.lua")

    for i = 2, #args do
        local line = args[i]
        local parts = {}
        for part in string.gmatch(line, "([^%s]+)") do
            table.insert(parts, part)
        end

        local cmd = parts[1]
        local full_path = base_dir .. "sys/commands/" .. cmd .. ".lua"

        if not file_exists(full_path) then
            print("Command not found: " .. cmd)
        else
            dofile(full_path)
            CMD(parts)
        end
    end
end
