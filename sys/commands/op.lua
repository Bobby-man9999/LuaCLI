dofile(base_dir .. "/sys/commands/piping.lua")

function CMD(args)
    local op = args[2]
    local a = resolve_arg(args[3])
    local b = resolve_arg(args[4])

    if not a or not b then
        print("Invalid numbers.")
        return
    end

    local result

    if op == "add" then
        result = a + b
    elseif op == "sub" then
        result = a - b
    elseif op == "mul" then
        result = a * b
    elseif op == "div" then
        if b == 0 then
            print("Cannot divide by zero.")
            return
        else
            result = a / b
        end
    elseif op == "fdv" then
        if b == 0 then
            print("Cannot divide by zero.")
            return
        else
            result = math.floor(a / b)
        end
    elseif op == "mod" then
        if b == 0 then
            print("Cannot divide by zero.")
            return
        else
            result = a % b
        end
    elseif op == "exp" then
        result = a ^ b
    elseif op == "tet" then
        if b < 0 then
            print("Negative height not supported.")
            return
        end
        if b % 1 ~= 0 then
            print("Decimal height is rounded down." .. math.floor(b))
        end
        if a % 1 ~= 0 then
            print("Decimal a is usually wacky, not recommended")
        end
        result = 1
        for i = 1, b do
            result = a ^ result
            if result == math.huge then
                print("Result too large (overflow at step " .. i .. ")")
                return
            end
        end
    else
        print("Unknown operation: " .. op)
        return
    end

    print("Result: " .. result)
    store_result(result)
end
