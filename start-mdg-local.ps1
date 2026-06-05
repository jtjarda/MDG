$createPath = "C:\Users\JTikal\Documents\MDG\mdg-create\mdgcreaterequest"
$searchPath = "C:\Users\JTikal\Documents\MDG\mdg-search"

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd `"$createPath`"; npm.cmd run start-local"
)

Start-Sleep -Seconds 5

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd `"$searchPath`"; npm.cmd run start-local"
)
