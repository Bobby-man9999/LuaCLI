function CMD(args)
    table.remove(args, 1)
    local echo = table.concat(args, ' ')
    print(echo)
end