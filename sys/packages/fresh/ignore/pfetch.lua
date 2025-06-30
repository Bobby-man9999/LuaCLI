function CMD(args)
    if #args < 4 then
        print("Usage: pfetch <user/repo> <branch> <zipname>")
        return
    end

    local user_repo = args[2]
    local branch = args[3]
    local zipname = args[4]

    -- Derive useful paths
    local zip_url = "https://github.com/" .. user_repo .. "/raw/" .. branch .. "/" .. zipname
    local zip_path = base_dir .. "sys/files/temp_fetch.zip"
    local extract_path = base_dir .. "sys/files/temp_extract"
    local target_name = zipname:gsub("%.zip$", "")
    local target_folder = base_dir .. "sys/packages/" .. target_name

    print("Downloading ZIP from GitHub...")
    local download_cmd = 'curl -L -o "' .. zip_path .. '" "' .. zip_url .. '"'
    if os.execute(download_cmd) ~= 0 then
        print("Download failed.")
        return
    end

    print("Extracting ZIP...")
    local unzip_cmd = 'powershell -command "Expand-Archive -Force \'' .. zip_path .. '\' \'' .. extract_path .. '\'"'
    if os.execute(unzip_cmd) ~= 0 then
        print("Extraction failed.")
        return
    end

    -- Copy extracted contents to package folder
    print("Copying package folder to sys/packages/" .. target_name .. " ...")
    os.execute('mkdir "' .. target_folder .. '" >nul 2>&1')
    copy_files(extract_path, target_folder)

    print("Cleaning up...")
    os.remove(zip_path)
    os.execute('rmdir /S /Q "' .. extract_path .. '"')

    print("Package fetched and installed successfully to sys/packages/" .. target_name)
end
