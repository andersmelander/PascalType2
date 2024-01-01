echo off

set BIN=.
set OUTPUT=..\..
set UCD=..\UCD

rem execute UDExtract.dpr no compression
%BIN%\UDExtract.exe /all /verbose /source:%UCD% /target:%OUTPUT%\PascalType.Unicode.rc

rem execute UDExtract.dpr zlib compression
%BIN%\UDExtract.exe /all /verbose /source:%UCD% /target:%OUTPUT%\PascalType.UnicodeZLib.rc /zip

rem compiling Unicode.rc
brcc32 %OUTPUT%\PascalType.Unicode.rc -fo%OUTPUT%\PascalType.Unicode.res
brcc32 %OUTPUT%\PascalType.UnicodeZLib.rc -fo%OUTPUT%\PascalType.UnicodeZLib.res

