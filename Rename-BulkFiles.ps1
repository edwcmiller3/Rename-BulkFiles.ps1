<#
.SYNOPSIS
    Rename-BulkFiles: Mass rename files according to contents of a text file list.

.DESCRIPTION
    Takes as input the path of files to be renamed and the file containing the new names. 
    Applies new name from each line of NameList to files in FilePath. New names take the form
    "## - Name.extension" where ## is a 2 digit left 0 padded number and the extension is taken
    from the original file so as to avoid breaking the files during renaming.

.PARAMETER FileLocation
    Path of files to be renamed (e.g. '.\Test').

.PARAMETER NameList
    File to read new names from (e.g. '.\List.txt').

.EXAMPLE
    Rename-BulkFiles -FilePath 'I:\TV\Clannad\Clannad' -NameList '.\Clannad S1.txt'
    
    Call the Rename-BulkFiles cmdlet and take all the files from the Clannad folder and rename them
    according to the list of names in Clannad S1.txt.
#>

Function Rename-BulkFiles {

    [CmdletBinding()]
    Param (
        #Parameter for path of files to be renamed
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$FileLocation,

        #Parameter for input name file to read new names from
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [String]$NameList
    )

    Begin {
        #Set Files and Names to proper values from parameter input
        #Retrieve [only-FIX] files from FilePath path, and format Names to remove unwanted characters
        $Files = Get-ChildItem -Path $FileLocation -File
        $Names = Get-Content -Path $NameList | ForEach-Object { $_ -replace "[^1-9a-zA-Z()\.\s\']", '' }
    }
    
    Process {
        #Check that the number of files to be renamed and the number of names in the renaming list match 
        If ($Files.Count -ne $Names.Count) {
            Write-Error -Category InvalidData "Number of items in FilePath must match those in NameList."
            Exit
        } 
        Else {
            For ($i = 1; $i -lt $Files.Count+1; $i++) {
                #Create new name template as "## - NAME.EXT" and rename current item
                $TempName = ("{0} - {1}" -f $i.ToString('00'), $Names[$i-1] + $Files[$i-1].Extension)
                Rename-Item $Files[$i-1].FullName -NewName $TempName
            }
        }
    }
}