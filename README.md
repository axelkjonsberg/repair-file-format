# Repair-FileFormat

`Repair-FileFormat` is a PowerShell command designed to normalize and standardize text file formats by performing the following actions:

- **Remove Byte Order Marks (BOMs):** Ensures files do not contain unwanted BOMs.
- **Convert Line Endings:** Normalizes line endings to either Unix (LF) or Windows (CRLF) styles.
- **Convert Encoding:** Adjusts file encoding to a specified format (e.g., `UTF8NoBOM`).
- **Remove Control Characters:** Strips out non-printable, control characters from file content.

## Requirements

- PowerShell 5.1 or higher (Windows) or PowerShell 7+ (cross-platform).
- Appropriate permissions to read and write to the files you are modifying.

## Installation

### Through PowerShell Gallery

Follow instructions at: <https://www.powershellgallery.com/packages/RepairFileFormat/1.0.0>

### Manually

1. Place the `.psm1` file containing the `Repair-FileFormat` function in a directory included in your `$env:PSModulePath`. For example:

    ```powershell
   $env:PSModulePath += ";C:\Users\<username>\Documents\WindowsPowerShell\Modules\"
    ```

2. Import the module:

    ```powershell
    Import-Module .\RepairFileFormat.psm1
    ```

## Usage

```powershell
Repair-FileFormat -Path "<file-or-directory-path>" [-Recurse] [-Encoding "<encoding>"]
```

### Parameters

- **`-Path`** *(String, Mandatory)*  
  The file or directory path you wish to repair.  
  - If a single file is specified, it applies the fixes to that file.
  - If a directory is specified without `-Recurse`, it processes only the immediate files in that directory.
  - If a directory is specified with `-Recurse`, it processes all files in that directory and its subdirectories.

- **`-Recurse`** *(Switch, Optional)*  
  When provided, `Repair-FileFormat` will also process files within all subdirectories of the specified path. If omitted, only the top-level directory is processed.

- **`-Encoding`** *(String, Optional)*  
  Changes the file encoding to the specified format. The default encoding is `UTF8NoBOM`. Other common encodings include `UTF8`, `ASCII`, `Unicode`, etc.

- **`-LineEnding`** *(String, Optional, ValidateSet: "Unix","Windows")*  
  Normalizes the line endings of the file(s). Defaults to Unix (`LF`) if not specified.
  - `Unix` will ensure all line endings are `\n`.
  - `Windows` will ensure all line endings are `\r\n`.

## Examples

### Example 1: Convert a Single File

```powershell
# Removes BOM, normalizes line endings to Unix, removes control chars.
Repair-FileFormat -Path "C:\project\script.sh"
```

### Example 2: Process and Entire Directory Recursively

```powershell
# Recursively process a directory, removing BOMs, normalizing to Windows line endings, and
# converting files to UTF8NoBOM encoding.
Repair-FileFormat -Path "C:\project\source" -Recurse -LineEnding Windows -Encoding UTF8NoBOM
```

## Logging

`Repair-FileFormat` logs its actions to `${global:RepairFileFormatLog}`, an array of strings detailing the modifications made to each file. You can review this log after running the command:

```powershell
$global:RepairFileFormatLog | ForEach-Object { $_ }
```

## Contributing

- Consider submitting a pull request if you have improvements or bug fixes.
