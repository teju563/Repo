Function Get-KeyValuePair
{
    Param(
            [String] [Parameter(Mandatory=$true)] $Path
    )

    $File = (Get-Content $path).Trim() | ?{$_.length -gt 0}
    
    $INCLUDE = $File | ?{$_ -like "*!Include*"}

    $content = $File | ?{$_ -notlike "*!Include*" -and $_ -notlike "*#*"}
    
    $HT=@{}
    0..9|%{
            $Key, $Value = ($content[$_].split("=")).Trim()
            $HT.add($Key, $Value)
    }
    
    $IndexOfUserIncludes =  $content.IndexOf("USER_INCLUDES=\")
    $SourceValue = $Content[11..$($IndexOfUserIncludes-1)].replace('\','').trim()
    
    $HT.Add('SOURCES',$SourceValue)
    
    $USER_INCLUDES_Value = $content[$($IndexOfUserIncludes+1)..$($content.Count-2)].replace('\','').Replace(';','')
    $USER_INCLUDES_Value += $content[-1]
     
    $HT.Add('USER_INCLUDES',$USER_INCLUDES_Value)

    
    If($env:INETROOT)
    {
        $INclude_1 = (($INCLUDE[0].Split(' ')[1]).Replace('$(','')).Replace(')','') -replace "INETROOT","$env:INETROOT"    
    }
    else
    {
        $INclude_1 = (($INCLUDE[0].Split(' ')[1]).Replace('$(','')).Replace(')','') -replace "INETROOT",$HT.INETROOT
    }

    If($env:APSDKLIB)
    {
        $INclude_2 = (($INCLUDE[1].Split(' ')[2]).Replace('$(','')).Replace(')','') -replace "APSDKLIB","$env:APSDKLIB"    
    }
    else
    {
        $INclude_2 = (($INCLUDE[1].Split(' ')[2]).Replace('$(','')).Replace(')','') -replace "APSDKLIB",$HT.APSDKLIB
    }
    
    
    Return $HT, $INclude_1, $Include_2
    }

Get-KeyValuePair 'C:\src\temp.txt'
