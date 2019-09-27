# Install Updated Modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

#Install-PackageProvider -Name NuGet -Force -Scope CurrentUser #Configured PowerShellGet to allow silent installation of new modules

Install-Module -Name ModuleBuilder -Force -Scope CurrentUser #Used to Generate Module
Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck #Use Pester to check that the deployment was successful
Install-Module -Name Nupkg -Force -Scope CurrentUser #Use Nupkg to generate a nuget project file to allow upload to the Artifacts store
