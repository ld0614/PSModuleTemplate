# Install Updated Modules
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser #Configured PowerShellGet to allow silent installation of new modules

Install-Module -Name ModuleBuilder -Force -Scope CurrentUser #Used to Generate Module
Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck #Use Pester to check that the deployment was successful
