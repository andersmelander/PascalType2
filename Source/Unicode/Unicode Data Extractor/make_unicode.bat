echo off

set BIN=.
set OUTPUT=..\..
set UCD=..\UCD

rem compile UDExtract.dpr
rem dcc32 UDExtract.dpr -U..\..\jcl\source\windows;..\..\jcl\source\common -I..\..\jcl\source\include -N0. -E.

rem execute UDExtract.dpr no compression
%BIN%\UDExtract.exe %UCD%\UnicodeData.txt %OUTPUT%\PascalType.Unicode.rc /a=%UCD%\ArabicShaping.txt /c=%UCD%\SpecialCasing.txt /f=%UCD%\CaseFolding.txt /d=%UCD%\DerivedNormalizationProps.txt /p=%UCD%\PropList.txt

rem execute UDExtract.dpr zlib compression
%BIN%\UDExtract.exe %UCD%\UnicodeData.txt %OUTPUT%\PascalType.UnicodeZLib.rc /z /a=%UCD%\ArabicShaping.txt /c=%UCD%\SpecialCasing.txt /f=%UCD%\CaseFolding.txt /d=%UCD%\DerivedNormalizationProps.txt /p=%UCD%\PropList.txt

rem execute UDExtract.dpr bzip2 compression
rem UDExtract.exe UnicodeData.txt UnicodeBzip2.rc /bz /c=SpecialCasing.txt /f=CaseFolding.txt /d=DerivedNormalizationProps.txt /p=PropList.txt

rem compiling JclUnicode.rc
brcc32 %OUTPUT%\PascalType.Unicode.rc -fo%OUTPUT%\PascalType.Unicode.res
brcc32 %OUTPUT%\PascalType.UnicodeZLib.rc -fo%OUTPUT%\PascalType.UnicodeZLib.res
rem brcc32 UnicodeBZip2.rc -foUnicodeBZip2.res
