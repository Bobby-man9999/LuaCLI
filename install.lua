-- Download versions.csv
local versions_url = "https://raw.githubusercontent.com/Bobby-man9999/luacli/main/versions.csv"
local versions_csv = "versions.csv"
local versions_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'' .. versions_url .. '\' -OutFile \'' .. versions_csv .. '\'"'
local versions_result = os.execute(versions_cmd)

print("versions_result:", versions_result)
if versions_result == 0 or versions_result == true then
    print("Available versions:")
    for line in io.lines(versions_csv) do
        print(line)
    end
else
    print("Could not fetch available versions.")
end

io.write("What version of LuaCLI should be installed? ")
local version = io.read()
local outdir = "LuaCLI_" .. version
local zipfile = "luacli_" .. version .. ".zip"
local url = "https://raw.githubusercontent.com/Bobby-man9999/luacli/main/LuaCLI_" .. version .. ".zip"

-- Download the zip file using PowerShell (Windows)
local download_cmd = 'powershell -Command "Invoke-WebRequest -Uri \'' .. url .. '\' -OutFile \'' .. zipfile .. '\'"'
local download_result = os.execute(download_cmd)

print("download_result:", download_result)
if download_result ~= 0 and download_result ~= true then
    print("Download failed!")
    os.exit(1)
end

-- Create output directory if it doesn't exist
os.execute('if not exist "' .. outdir .. '" mkdir "' .. outdir .. '"')

-- Unzip using tar (works on Windows 10+ and Unix)
local result = os.execute('tar -xf "' .. zipfile .. '" -C "' .. outdir .. '"')

if result == 0 or result == true then
    print("Unzip successful!")
else
    print("Unzip failed!")
end
