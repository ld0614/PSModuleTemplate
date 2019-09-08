#This script is designed for local development work, it builds the module,
#then loads it into the current session by working out the compiled source location and directly forcing an import

Import-Module ModuleBuilder -WarningAction SilentlyContinue #-RequiredVersion 1.1.0 #-MinimumVersion 1.1.0 #Direct from github as it contains important bug fixes over the psgallery version as of 16/02/2019

$BuildSettings = Import-PowerShellDataFile -Path "Build.psd1" -ErrorAction Stop

if ($null -ne $BuildSettings.OutputDirectory)
{
    #TODO: Ensure that we don't delete any really stupid places like original source or Windows
    Remove-Item -Path $BuildSettings.OutputDirectory -Recurse -Force -ErrorAction SilentlyContinue
}

#Increment Build Number
$ModuleData = Import-PowerShellDataFile -Path $BuildSettings.Path
$CurrentVersionString = $ModuleData.ModuleVersion
$CurrentVersion = [Version]::Parse($CurrentVersionString)
if ($null -ne $CurrentVersion)
{
    $NewVersion = [Version]::new($CurrentVersion.Major,$CurrentVersion.Minor,$CurrentVersion.Build+1,$CurrentVersion.Revision)

    $ModuleDataFile = Get-Content -Path $BuildSettings.Path
    Foreach ($line in $ModuleDataFile)
    {
        if ($line.StartsWith('ModuleVersion'))
        {
            $ModuleDataFile[$ModuleDataFile.IndexOf($line)] = "ModuleVersion = '$($NewVersion.ToString())'"
            break
        }
    }
    Set-Content -Path $BuildSettings.Path -Value $ModuleDataFile
}

Build-Module

#ZIP the module for easy upload
Compress-Archive -Path $BuildSettings.OutputDirectory -DestinationPath $BuildSettings.OutputDirectory.Trim('\') -Force

$ModulePath = Join-Path -Path (Join-Path -Path $BuildSettings.OutputDirectory -ChildPath $NewVersion.ToString()) -ChildPath Template.psd1
Import-Module -Name $ModulePath -Force
