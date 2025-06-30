files = io.open(base_dir .. "sys/startup/startup.csv", "r")
files = files:read("*all")
files = split(files, ",")
for _, file in ipairs(files) do
    local path = base_dir .. "sys/startup/" .. file
    if file:sub(-4) == ".lua" then
        local f = io.open(path, "r")
        if f then
            f:close()
            dofile(path)
        else
            print("Error: Could not open startup file: " .. path)
        end
    else
        print("Skipping non-Lua file in startup: " .. file)
    end
end