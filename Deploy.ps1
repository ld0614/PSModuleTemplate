$RepoURL = "https://pkgs.dev.azure.com/PSDayUK/_packaging/PSDayUK/nuget/v2"


if ($null -eq (Get-PackageProvider -Name NuGet))
{
    #Force PowerShellGet to allow silent installation of new modules
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
}

#Microsoft keep breaking the silent authentication workflows: https://github.com/PowerShell/PowerShellGet/issues/499
#Hardcoding a specific know working version https://github.com/PowerShell/PowerShellGet/issues/499#issuecomment-517467942 until such time they fix the latest versions
if ($null -eq (Get-Module -ListAvailable -Name PackageManagement | Where-Object {$_.Version -eq "1.4.2"}))
{
    Install-module PackageManagement -RequiredVersion 1.4.2 -Force -AllowClobber -Scope CurrentUser
}

if ($null -eq (Get-Module -ListAvailable -Name PowerShellGet | Where-Object {$_.Version -eq "2.1.5"}))
{
    Install-Module PowerShellGet -RequiredVersion 2.1.5 -Force -AllowClobber -Scope CurrentUser
}

if (Get-Module -Name PowerShellGet)
{
    Remove-Module -Name PowerShellGet
}

if (Get-Module -Name PackageManagement)
{
    Remove-Module -Name PackageManagement
}

Import-Module -Name PackageManagement -RequiredVersion 1.4.2 -ErrorAction Stop
Import-Module -Name PowerShellGet -RequiredVersion 2.1.5 -ErrorAction Stop

$script = Invoke-WebRequest -Uri https://raw.githubusercontent.com/microsoft/artifacts-credprovider/master/helpers/installcredprovider.ps1

$TempFile = New-TemporaryFile
$OldTempFile = $TempFile.ToString()
$TempFile = $TempFile.ToString().Replace($TempFile.Extension,".ps1")
Remove-Item -Path $OldTempFile -Force

Out-File -InputObject $script.Content -FilePath $TempFile
<#
When this script was written this was the parameter block for the installcredprovider.ps1 script
param(
    # whether or not to install netfx folder for nuget
    [switch]$AddNetfx,
    # override existing cred provider with the latest version
    [switch]$Force,
    # install the version specified
    [string]$Version
)

The following line executes with -AddNetFx and -Force to allow it to work with NuGet directly (NetFx) and to update to the latest version (Force)
#>
Invoke-Command -ScriptBlock {powershell.exe -file $TempFile -AddNetFx -Force}

Remove-Item -Path $TempFile -Force

if (Get-PSRepository -Name PSDayUK -ErrorAction SilentlyContinue)
{
    Unregister-PSRepository -Name PSDayUK
}
Register-PSRepository -Name PSDayUK -SourceLocation $RepoURL -PublishLocation $RepoURL -InstallationPolicy Trusted