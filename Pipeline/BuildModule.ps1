#This script is designed for local development work, it builds the module,
#then loads it into the current session by working out the compiled source location and directly forcing an import

Import-Module ModuleBuilder -WarningAction SilentlyContinue #-RequiredVersion 1.1.0 #-MinimumVersion 1.1.0 #Direct from github as it contains important bug fixes over the psgallery version as of 16/02/2019

$BuildRoot = Split-Path -Path $PSScriptRoot -Parent
$BuildData = Join-Path -Path $BuildRoot -ChildPath "Build.psd1"
$BuildOutput = Join-Path -Path (Join-Path -Path $BuildRoot -ChildPath "Output") -ChildPath $Env:ModuleName

$BuildSettings = Import-PowerShellDataFile -Path $BuildData -ErrorAction Stop

#Increment Build Number
$FullBuildPath = Join-Path -Path $BuildRoot -ChildPath $BuildSettings.Path

$NewVersion = [Version]::new($env:Version)

$ModuleDataFile = Get-Content -Path $FullBuildPath
Foreach ($line in $ModuleDataFile)
{
    if ($line.StartsWith('ModuleVersion'))
    {
        $ModuleDataFile[$ModuleDataFile.IndexOf($line)] = "ModuleVersion = '$($NewVersion.ToString())'"
        break
    }
}
Set-Content -Path $FullBuildPath -Value $ModuleDataFile

Write-Verbose "Output Directory: $BuildOutput"

Build-Module -OutputDirectory $BuildOutput -SourcePath $BuildRoot
