Function Get-KeyValuePair
{
    Param(
            [String] [Parameter(Mandatory=$true)] $Path
    )
    
    $content = (Get-Content $path).Trim() | ?{$_.length -gt 0}| ?{$_ -notlike "*!Include*" -and $_ -notlike "*#*"}
    
    $HT=@{}
    0..9|%{
            $Key, $Value = ($content[$_].split("=")).Trim()
            $HT.add($Key, $Value)
    }
    
    $IndexOfUserIncludes =  $content.IndexOf("USER_INCLUDES=\")
    $SourceValue = $Content[11..$($IndexOfUserIncludes-1)].replace('\','').trim()
    
    $HT.Add('SOURCES',$SourceValue)
    
    $HT.Add('USER_INCLUDES',$content[$($IndexOfUserIncludes+1)..$content.Count])
    
    Return $HT
}

$hashTable = Get-KeyValuePair 'C:\src\temp.txt'