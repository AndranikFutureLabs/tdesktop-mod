@echo off
call "C:\Program Files\Microsoft Visual Studio\18\Insiders\VC\Auxiliary\Build\vcvars64.bat"
cd /d C:\tdesctop
set Platform=x64
python Telegram\build\prepare\prepare.py qt6 silent
