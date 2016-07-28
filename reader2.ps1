Function Get-KeyValuePair
{
    # Defining the Parameters
    [cmdletbinding()]
    Param([String] [Parameter(Mandatory=$true)] $Path)

    # Get the content from the source file
    $File = (Get-Content $path).Trim() | ?{$_.length -gt 0}
    
    # Separate !include from rest of the $content
    $Include = $File | ?{$_ -like "*!Include*"}
    $content = $File | ?{$_ -notlike "*!Include*" -and $_ -notlike "*#*"}
    
    # Define an Empty Hashtable
    $HashTable= @{}

    # Parsing and Key Value pairs for content other than !include
    Foreach($Item in ($content | ?{$_ -like "*=*"}))
    {
        # Split by '=' to get Key-Value Pair
        $Key, $Value = $Item.split("=")
        
        # Incase the Value is empty , like = SOURCES = \ , you're to parse the content below it to get the Valuees for the Key
        If(-not $Value.Replace("\","").trim())
        {
            $StartIndex = $content.IndexOf($Item) + 1 
            $NextKeyValuePair = $(($content[$StartIndex..$content.Count] | %{ if($PSItem -like "*=*"){Return $PSItem}}) | select -First 1)

            If(-not $NextKeyValuePair)
            {
                $EndIndex = $content.IndexOf($content[$content.Count-1])
            }
            else
            {
                $EndIndex = $content.IndexOf("$NextKeyValuePair") - 1 
            }

            $Value = $content[$StartIndex..$EndIndex]
        }

        # Removing backslash from the string
        $Value = $Value | %{if($PSItem.trim() -like "*\"){$PSItem.replace("\","")}else{$PSItem}}
        
        $PreviousValue = $HashTable."$Key"

        If($PreviousValue)
        {
            $HashTable.Remove("$Key")
            $Value = [Array]$PreviousValue + $Value
        }

        # Add key-Value Pair extracted from $Content
        $HashTable.add($Key, $Value.Trim())        
    }

    # Parsing and Key Value pairs for !Include
    If($Include) # Condtion to run the following block only when !Includes Exist
    {
        $IncludeValueArray = Foreach($Item in $Include)
        {
            # Grab the start index and length of Environment variable name
            $start = $Item.IndexOf('(') + 1
            $Length= $Item.IndexOf(')') - $start
            
            # Extract the substring to get the Environment variable Name, Like "INETROOT"
            $EnvVariableName = $Item.Substring($start, $Length)
        
            # Grab the value of Environment variable
            $EnvVariableValue = Invoke-Expression ('$env:'+"$EnvVariableName")
        
            If($EnvVariableValue) #If Environment variable exist and value is return, run the below code block to replace the "name" of Enviroment variable with "Value" of Enviroment variable.
            {
                (($Item.Split(' ')[1]).Replace('$(','')).Replace(')','') -replace "$EnvVariableName","$(Invoke-Expression ('$env:'+"$EnvVariableName"))"
            }
            else # Else 1) try to search the Environment variable in rest of Hash table and replace.  2) If not in hashtable replace it with Empty string
            {
                (($Item.Split(' ')[1]).Replace('$(','')).Replace(')','') -replace "$EnvVariableName","$($HashTable."$EnvVariableName")"
            }   
        }

        # Remove "\" - Backslash from the string
        $IncludeValueArray = $IncludeValueArray | %{if($PSItem.trim() -like "*\"){$PSItem.replace("\","")}else{$PSItem}}

        # Add the Key-Value pair to the Hashtable
        $HashTable.Add('Include',$IncludeValueArray)
    }

    Return $HashTable
}
$HT = Get-KeyValuePair E:\src\Azure\Compute-Move\private\common\environment\clusterlib\src\sources
Get-KeyValuePair E:\src\Azure\Compute-Move\private\common\environment\clusterlib\src\sources