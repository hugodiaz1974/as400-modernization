$global:missingPrograms = @()
$global:foundFiles = @()
$global:visited = @{}
$global:allTables = @{}

function Scan-Program($pgmName) {
    if ($global:visited[$pgmName]) { return }
    $global:visited[$pgmName] = $true

    $paths = @(
        "C:\Users\hugot\OneDrive\BACKUP ASUS 20221112\VARIOS\PROYECTOS AI\MIGRACION\CCA\CCACLP\$pgmName.clp",
        "C:\Users\hugot\OneDrive\BACKUP ASUS 20221112\VARIOS\PROYECTOS AI\MIGRACION\CCA\CCACBL\$pgmName.cbl",
        "C:\Users\hugot\OneDrive\BACKUP ASUS 20221112\VARIOS\PROYECTOS AI\MIGRACION\Modulo_Cierre_Ahorros\$pgmName.clp",
        "C:\Users\hugot\OneDrive\BACKUP ASUS 20221112\VARIOS\PROYECTOS AI\MIGRACION\Modulo_Cierre_Ahorros\$pgmName.cbl"
    )

    $foundFile = $null
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $foundFile = $p
            break
        }
    }

    if (-not $foundFile) {
        $global:missingPrograms += $pgmName
        return
    }

    $global:foundFiles += $foundFile
    
    $subcalls = @()
    # Extraer llamadas
    if ($foundFile -match "\.clp$") {
        $matches = Select-String -Pattern 'CALL\s+PGM\([^/]+/([^)]+)\)' -Path $foundFile
        foreach ($m in $matches) { $subcalls += $m.Matches.Groups[1].Value.Trim() }
        $matches2 = Select-String -Pattern 'CALL\s+PGM\(([^)/]+)\)' -Path $foundFile
        foreach ($m in $matches2) { $subcalls += $m.Matches.Groups[1].Value.Trim() }
        
        # Extraer archivos base de datos (OVRDBF y DCLF)
        $tbls = Select-String -Pattern 'OVRDBF\s+FILE\([^)]+\)\s+TOFILE\([^/]+/([^)]+)\)' -Path $foundFile
        foreach ($t in $tbls) { $global:allTables[$t.Matches.Groups[1].Value.Trim()] = $true }
    } else {
        $matches = Select-String -Pattern 'CALL\s+["'']([^"'''']+)["'']' -Path $foundFile
        foreach ($m in $matches) { $subcalls += $m.Matches.Groups[1].Value.Trim() }
        
        # Extraer archivos base de datos (ASSIGN TO DATABASE-)
        $tbls = Select-String -Pattern 'ASSIGN\s+TO\s+DATABASE-([A-Z0-9_]+)' -Path $foundFile
        foreach ($t in $tbls) { $global:allTables[$t.Matches.Groups[1].Value.Trim()] = $true }
    }

    foreach ($c in $subcalls) {
        if ($c -notmatch '^&') {
            Scan-Program $c
        }
    }
}

$topLevel = @("CCA201", "CCA205", "CCA500", "CCA502", "CCA510", "CCA513", "CCA520", "CCA530", "CCA540", "CCA545", "CCA550", "CCA560", "CCA565", "CCA580", "CCA590", "CCA599", "CCA601", "CCA602", "CCA606", "CCA630", "CCA660", "CCA661", "CCA662", "CCA664", "CCA671", "CCA672", "CCA710", "CCA711", "CCA760", "CCA765", "CCA770", "CCA800", "CCAACTREM")
foreach ($pgm in $topLevel) {
    Scan-Program $pgm
}

Write-Output "=== PROGRAMAS FALTANTES ==="
$global:missingPrograms | Sort-Object -Unique

Write-Output "=== ARCHIVOS / TABLAS UTILIZADOS ==="
$global:allTables.Keys | Sort-Object -Unique
