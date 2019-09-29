Function New-PublicFunction
{
    [CmdletBinding()]
    Param
    ()

    Write-Output "Starting Private Function"
    New-PrivateFunction 
    Write-Output "New-PublicFunction complete!"
}