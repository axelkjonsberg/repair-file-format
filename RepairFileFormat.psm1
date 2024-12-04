${global:RepairFileFormatLog} = @()

###
# CONSTANTS
$CONTROL_CHAR_PATTERN = '[\x00-\x08\x0B\x0C\x0E-\x1F]'
$DEFAULT_ENCODING = 'UTF8NoBOM'
$DEFAULT_LINE_ENDING = 'Unix'
$BOMS = @{
    UTF8 = [byte[]](0xEF,0xBB,0xBF)
    UTF16LE = [byte[]](0xFF,0xFE)
    UTF16BE = [byte[]](0xFE,0xFF)
    UTF32LE = [byte[]](0xFF,0xFE,0x00,0x00)
    UTF32BE = [byte[]](0x00,0x00,0xFE,0xFF)
}
###

###
# HELPER FUNCTIONS
function Remove-Bom {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,ValueFromPipeline = $true,Position = 0)]
        [string]$Path
    )
    process {
        try {
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path

            if (-not (Test-Path -Path $resolvedPath -PathType Leaf)) {
                ${global:RepairFileFormatLog} += "File does not exist: $resolvedPath"
                return
            }

            if ((Get-Item $resolvedPath).IsReadOnly) {
                ${global:RepairFileFormatLog} += "File is read-only and cannot be modified: $resolvedPath"
                return
            }

            $bytes = [System.IO.File]::ReadAllBytes($resolvedPath)

            $bomRemoved = $false

            foreach ($encoding in $BOMS.Keys) {
                $bom = $BOMS[$encoding]
                if ($bytes.Length -ge $bom.Length -and $bytes[0..($bom.Length - 1)] -ieq $bom) {
                    # Remove the BOM
                    $newBytes = $bytes[$bom.Length..($bytes.Length - 1)]
                    # and write the bytes back to the file without the BOM
                    [System.IO.File]::WriteAllBytes($resolvedPath,$newBytes)
                    ${global:RepairFileFormatLog} += "Removed BOM ($encoding) from file: $resolvedPath"
                    $bomRemoved = $true
                    break
                }
            }

            if (-not $bomRemoved) {
                ${global:RepairFileFormatLog} += "No BOM found in file: $resolvedPath"
            }
        } catch {
            ${global:RepairFileFormatLog} += "Error in Remove-Bom for file ${resolvedPath}: $_"
        }
    }
}

function Convert-LineEndings {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Unix","Windows")]
        [string]$To = $DEFAULT_LINE_ENDING
    )
    process {
        try {
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path

            if (-not (Test-Path -Path $resolvedPath -PathType Leaf)) {
                ${global:RepairFileFormatLog} += "File does not exist: $resolvedPath"
                return
            }

            if ((Get-Item $resolvedPath).IsReadOnly) {
                ${global:RepairFileFormatLog} += "File is read-only and cannot be modified: $resolvedPath"
                return
            }

            $content = Get-Content -LiteralPath $resolvedPath -Raw

            if ($To -eq "Unix") {
                $newContent = $content -replace "`r`n","`n" -replace "`r","`n"
                if ($newContent -ne $content) {
                    Set-Content -LiteralPath $resolvedPath -Value $newContent -NoNewline
                    ${global:RepairFileFormatLog} += "Converted line endings to Unix (LF) in file: $resolvedPath"
                } else {
                    ${global:RepairFileFormatLog} += "Line endings already Unix (LF) in file: $resolvedPath"
                }
            } elseif ($To -eq "Windows") {
                $newContent = $content -replace "`r?`n","`r`n" -replace "`r(?!`n)","`r`n"
                if ($newContent -ne $content) {
                    Set-Content -LiteralPath $resolvedPath -Value $newContent -NoNewline
                    ${global:RepairFileFormatLog} += "Converted line endings to Windows (CRLF) in file: $resolvedPath"
                } else {
                    ${global:RepairFileFormatLog} += "Line endings already Windows (CRLF) in file: $resolvedPath"
                }
            }
        } catch {
            ${global:RepairFileFormatLog} += "Error in Convert-LineEndings for file ${resolvedPath}: $_"
        }
    }
}

function Convert-Encoding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [string]$Encoding = $DEFAULT_ENCODING
    )
    process {
        try {
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path

            if (-not (Test-Path -Path $resolvedPath -PathType Leaf)) {
                ${global:RepairFileFormatLog} += "File does not exist: $resolvedPath"
                return
            }

            if ((Get-Item $resolvedPath).IsReadOnly) {
                ${global:RepairFileFormatLog} += "File is read-only and cannot be modified: $resolvedPath"
                return
            }

            $content = Get-Content -LiteralPath $resolvedPath -Raw

            ${global:RepairFileFormatLog} += "Converting encoding of file $resolvedPath to $Encoding"

            Set-Content -LiteralPath $resolvedPath -Value $content -Encoding $Encoding -NoNewline
            ${global:RepairFileFormatLog} += "Converted encoding to $Encoding for file: $resolvedPath"
        } catch {
            ${global:RepairFileFormatLog} += "Error in Convert-Encoding for file ${resolvedPath}: $_"
        }
    }
}

function Remove-ControlCharacters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Path
    )
    process {
        try {
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path

            if (-not (Test-Path -Path $resolvedPath -PathType Leaf)) {
                ${global:RepairFileFormatLog} += "File does not exist: $resolvedPath"
                return
            }

            $content = Get-Content -LiteralPath $resolvedPath -Raw

            $newContent = ($content -replace $CONTROL_CHAR_PATTERN,'')

            if ($newContent -ne $content) {
                Set-Content -LiteralPath $resolvedPath -Value $newContent -NoNewline
                ${global:RepairFileFormatLog} += "Removed control characters from file: $resolvedPath"
            } else {
                ${global:RepairFileFormatLog} += "No control characters found in file: $resolvedPath"
            }
        } catch {
            ${global:RepairFileFormatLog} += "Error in Remove-ControlCharacters for file ${resolvedPath}: $_"

        }
    }
}
###

function Repair-FileFormat {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,Position = 0)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [switch]$Recurse,
        [Parameter(Mandatory = $false)]
        [string]$Encoding,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Unix","Windows")]
        [string]$LineEnding
    )
    process {
        try {
            ${global:RepairFileFormatLog} = @()
            $resolvedPath = Resolve-Path -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path

            if ([string]::IsNullOrEmpty($LineEnding)) {
                $LineEnding = $DEFAULT_LINE_ENDING
            }

            if (Test-Path -Path $resolvedPath -PathType Leaf) {
                $items = Get-Item -LiteralPath $resolvedPath
            } elseif (Test-Path -Path $resolvedPath -PathType Container) {
                if ($Recurse) {
                    $items = Get-ChildItem -LiteralPath $resolvedPath -Recurse -File
                } else {
                    $items = Get-ChildItem -LiteralPath $resolvedPath -File
                }
            } else {
                ${global:RepairFileFormatLog} += "Invalid path: $resolvedPath"
                return
            }

            foreach ($item in $items) {
                Remove-Bom -Path $item.FullName
                Convert-LineEndings -Path $item.FullName -To $LineEnding

                if ($PSBoundParameters.ContainsKey('Encoding')) {
                    Convert-Encoding -Path $item.FullName -Encoding $Encoding
                }

                Remove-ControlCharacters -Path $item.FullName
            }

            Write-Host "Repair File Format Log:"
            ${global:RepairFileFormatLog} | ForEach-Object { Write-Host $_ }

        } catch {
            Write-Error "An error occurred in Repair-FileFormat: $_"
        }
    }
}

