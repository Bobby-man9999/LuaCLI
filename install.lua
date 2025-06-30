io.write("What version of LuaCLI should be installed? ")
local version = io.read()
local outdir = "LuaCLI_" .. version
local zipfile = "luacli_" .. version .. ".zip"
local url = "https://github.com/Bobby-man9999/luacli/releases/download/v" .. version .. "/" .. zipfile

-- Download the zip file using PowerShell (Windows)
local download_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'' .. url .. '\' -OutFile \'' .. zipfile .. '\'"'
local download_result = os.execute(download_cmd)

if download_result ~= 0 then
    print("Download failed!")
    os.exit(1)
end

-- Create output directory if it doesn't exist
os.execute('if not exist "' .. outdir .. '" mkdir "' .. outdir .. '"')

-- Unzip using tar (works on Windows 10+ and Unix)
local result = os.execute('tar -xf "' .. zipfile .. '" -C "' .. outdir .. '"')

if result == 0 then
    print("Unzip successful!")
else
    print("Unzip failed!")
end