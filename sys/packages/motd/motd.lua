arg_count = 0

function CMD(args)
    local file = io.open(base_dir .. "sys/files/motd.txt", "r")
    if file then
        print("=== Message of the Day ===")
        print(file:read("*a"))
        file:close()
    else
        print("No MOTD found. You can create one using the fileman package:")
        print("package install fileman")
        print("fileman edit motd.txt")
    end
end
