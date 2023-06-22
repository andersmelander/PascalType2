echo off

set OUTPUT=..
set UCD=..\UCD

rem compile UDExtract.dpr
rem dcc32 UDExtract.dpr -U..\..\jcl\source\windows;..\..\jcl\source\common -I..\..\jcl\source\include -N0. -E.

rem execute UDExtract.dpr no compression
UDExtract.exe %UCD%\UnicodeData.txt %OUTPUT%\Unicode.rc /c=%UCD%\SpecialCasing.txt /f=%UCD%\CaseFolding.txt /d=%UCD%\DerivedNormalizationProps.txt /p=%UCD%\PropList.txt

rem execute UDExtract.dpr zlib compression
UDExtract.exe %UCD%\UnicodeData.txt %OUTPUT%\UnicodeZLib.rc /z /c=%UCD%\SpecialCasing.txt /f=%UCD%\CaseFolding.txt /d=%UCD%\DerivedNormalizationProps.txt /p=%UCD%\PropList.txt

rem execute UDExtract.dpr bzip2 compression
rem UDExtract.exe UnicodeData.txt UnicodeBzip2.rc /bz /c=SpecialCasing.txt /f=CaseFolding.txt /d=DerivedNormalizationProps.txt /p=PropList.txt

rem compiling JclUnicode.rc
rem brcc32 Unicode.rc -foUnicode.res
rem brcc32 UnicodeZLib.rc -foUnicodeZLib.res
rem brcc32 UnicodeBZip2.rc -foUnicodeBZip2.res
