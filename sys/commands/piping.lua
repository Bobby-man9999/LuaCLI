function resolve_arg(arg)
    if arg == "_" then
        local f = io.open(base_dir .. "/sys/data/last_result", "r")
        if not f then return nil end
        local val = tonumber(f:read("*l"))
        f:close()
        return val
    else
        return tonumber(arg)
    end
end

function store_result(val)
    local f = io.open(base_dir .. "/sys/data/last_result", "w")
    f:write(tostring(val))
    f:close()
end