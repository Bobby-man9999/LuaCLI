function CMD(args)
    print(table.concat(list_files(base_dir .. "sys\\commands"), "\n"))
end