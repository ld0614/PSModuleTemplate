$ContentRoot = Split-Path -Path $PSScriptRoot -Parent
$ModuleRoot = Join-Path -Path $ContentRoot -ChildPath "Output"
$ModulePath = Join-Path -Path $ModuleRoot -ChildPath $Env:ModuleName
$ModuleVersionPath = Join-Path -Path $ModulePath -ChildPath $env:Version
$ModuleDataPath = Join-Path -Path $ModuleVersionPath -ChildPath "$($Env:ModuleName).psm1"

$SecureString = ConvertTo-SecureString -String $env:PFXPassword -AsPlainText -Force

$SignCert = Get-PfxCertificate -FilePath $env:CODESIGNPFX_SECUREFILEPATH -Password $SecureString

Set-AuthenticodeSignature -PSPath $ModuleDataPath -Certificate $SignCert
