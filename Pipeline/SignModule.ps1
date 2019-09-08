$ModuleName = "Template"
$ContentRoot = Split-Path -Path $PSScriptRoot -Parent
$ModuleRoot = Join-Path -Path $PSScriptRoot -ChildPath "Output"
$ModulePath = Join-Path -Path $ModuleRoot -ChildPath $ModuleName
$ModuleVersionPath = Join-Path -Path $ModulePath -ChildPath $env:Version.Revision

$SignCert = Get-PfxCertificate -FilePath $(codeSignPFX.secureFilePath) -Password $env:PFXPassword

Set-AuthenticodeSignature -PSPath .\ToBeSigned.ps1 -Certificate $SignCert
