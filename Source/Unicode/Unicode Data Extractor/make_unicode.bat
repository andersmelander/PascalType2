echo off

set BIN=.
set OUTPUT=..\..
set UCD=..\UCD

rem compile UDExtract.dpr
rem dcc32 UDExtract.dpr -U..\..\jcl\source\windows;..\..\jcl\source\common -I..\..\jcl\source\include -N0. -E.

rem execute UDExtract.dpr no compression
%BIN%\UDExtract.exe /all /verbose /source:%UCD% /target:%OUTPUT%\PascalType.Unicode.rc

rem execute UDExtract.dpr zlib compression
%BIN%\UDExtract.exe /all /verbose /source:%UCD% /target:%OUTPUT%\PascalType.UnicodeZLib.rc /zip

rem execute UDExtract.dpr bzip2 compression
rem %BIN%\UDExtract.exe /all /verbose /source:%UCD% /target:%OUTPUT%\PascalType.UnicodeBZLib.rc /bzip

rem compiling JclUnicode.rc
brcc32 %OUTPUT%\PascalType.Unicode.rc -fo%OUTPUT%\PascalType.Unicode.res
brcc32 %OUTPUT%\PascalType.UnicodeZLib.rc -fo%OUTPUT%\PascalType.UnicodeZLib.res
rem brcc32 %OUTPUT%\PascalType.UnicodeZLib.rc -fo%OUTPUT%\PascalType.UnicodeBZLib.res

