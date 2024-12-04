@{
    ModuleVersion = '1.0.0'
    GUID = '2854aec3-adb7-4217-8bc8-961c9cdb1c92'
    Author = 'Axel M. Kjønsberg'
    Description = 'Functions for repairing common file formatting issues when working between Windows and Unix systems.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Remove-Bom',
        'Convert-LineEndings',
        'Convert-Encoding',
        'Remove-ControlCharacters',
        'Repair-FileFormat'
    )
    RootModule = 'RepairFileFormat.psm1'
    RequiredModules = @()
    RequiredAssemblies = @()
    ScriptsToProcess = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    PrivateData = @{}
}
