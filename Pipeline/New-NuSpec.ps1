$ContentRoot = Split-Path -Path $PSScriptRoot -Parent
$ModuleRoot = Join-Path -Path $ContentRoot -ChildPath "Output"
$ModulePath = Join-Path -Path $ModuleRoot -ChildPath $Env:ModuleName
$ModuleVersionPath = Join-Path -Path $ModulePath -ChildPath $env:Version
$ModuleInformationPath = Join-Path -Path $ModuleVersionPath -ChildPath "$($Env:ModuleName).psd1"
$NuSpecPath = Join-Path -Path $ModuleVersionPath -ChildPath "$($Env:ModuleName).nuspec"

Function New-XmlTextNode
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlDocument]
        $Document,
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]
        $RootNode,
        [Parameter(Mandatory=$true)]
        [String]
        $NodeName,
        [Parameter(Mandatory=$true)]
        [String]
        $Value
    )

    $Node = $Document.CreateElement($NodeName,$RootNode.NamespaceURI)
    $Node.AppendChild($xml.CreateTextNode($Value)) | Out-Null
    $RootNode.AppendChild($Node) | Out-Null
    return
}

Function New-NuSpecProperty
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlDocument]
        $Document,
        [Parameter(Mandatory=$true)]
        [System.Xml.XmlElement]
        $RootNode,
        [Parameter(Mandatory=$true)]
        [String]
        $NodeName,
        [Parameter()]
        [String]
        $Value,
        [Switch]
        $Required
    )
    if ([string]::IsNullOrEmpty($Value))
    {
        if ($Required)
        {
            throw "$NodeName is a required NuSpec Value"
        }
        else 
        {
            return    
        }
    }
    New-XmlTextNode -Document $xml -RootNode $MetaDataNode -NodeName $NodeName -Value $Value
    return
}

#Generate Root and Metadata tags
[Xml]$xml = [xml]::new()
$xmlDec = $xml.CreateXmlDeclaration("1.0","utf-8", $null)
$xml.AppendChild($xmlDec) | Out-Null
$rootNode = $xml.CreateElement("package","http://schemas.microsoft.com/packaging/2013/05/nuspec.xsd")
$xml.AppendChild($rootNode) | Out-Null
$MetaDataNode = $xml.CreateElement("metadata",$rootNode.NamespaceURI)
$rootNode.AppendChild($MetaDataNode) | Out-Null

#import the data from psd1 file
$ModuleInformation = Import-PowerShellDataFile -Path $ModuleInformationPath

#Populate where the data is in the module psd1 file
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "id" -Value $Env:ModuleName -Required
#NuSpec only supports versions in the format 0.0.0 not 0.0.0.0
$ModuleVersion = [version]::Parse($ModuleInformation.ModuleVersion)
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "version" -Value "$($ModuleVersion.Major).$($ModuleVersion.Minor).$($ModuleVersion.Build)" -Required
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "description" -Value $ModuleInformation.Description -Required
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "authors" -Value $ModuleInformation.Author -Required
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "owners" -Value $ModuleInformation.Author -Required

#Optional data pulled from module information file
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "copyright" -Value $ModuleInformation.Copyright

if ($null -ne $ModuleInformation.PrivateData.PSData.Tags)
{
    New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "tags" -Value ([string]::join(" ", $ModuleInformation.PrivateData.PSData.Tags))
}
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "licenseUrl" -Value $ModuleInformation.PrivateData.PSData.LicenseUri
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "projectUrl" -Value $ModuleInformation.PrivateData.PSData.ProjectUri
New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "releaseNotes" -Value $ModuleInformation.PrivateData.PSData.ReleaseNotes
if ($null -eq $ModuleInformation.PrivateData.PSData.LicenseUri)
{
    New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "requireLicenseAcceptance" -Value "false"    
}
else 
{
    New-NuSpecProperty -Document $xml -RootNode $MetaDataNode -NodeName "requireLicenseAcceptance" -Value "true"
}

$xml.Save($NuSpecPath)