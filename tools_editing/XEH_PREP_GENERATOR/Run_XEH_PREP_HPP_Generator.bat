@echo off
setlocal

cd /d "%~dp0"

py -3.11 xeh_prep_hpp_generator.py 2>nul && goto :eof
py -3.10 xeh_prep_hpp_generator.py 2>nul && goto :eof
py -3.9  xeh_prep_hpp_generator.py 2>nul && goto :eof
py -3.8  xeh_prep_hpp_generator.py 2>nul && goto :eof

echo Could not run the script via the Python launcher (py).
echo Try running: python xeh_prep_hpp_generator.py
pause
