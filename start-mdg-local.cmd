@echo off
start "mdg-create localhost:8080" cmd /k "cd /d C:\Users\JTikal\Documents\MDG\mdg-create\mdgcreaterequest && npm.cmd run start-local"
timeout /t 5 /nobreak >nul
start "mdg-search localhost:8081" cmd /k "cd /d C:\Users\JTikal\Documents\MDG\mdg-search && npm.cmd run start-local"
