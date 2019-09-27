$ContentRoot = Split-Path -Path $PSScriptRoot -Parent
$ModuleRoot = Join-Path -Path $ContentRoot -ChildPath "Output"
$ModulePath = Join-Path -Path $ModuleRoot -ChildPath $Env:ModuleName

describe 'Testing Template Module' {
	context 'Module Loads Successfully' {
		it 'Template Module can load' {
			{ Import-Module $ModulePath -ErrorAction Stop } | Should -Not -Throw
		}
	}
}