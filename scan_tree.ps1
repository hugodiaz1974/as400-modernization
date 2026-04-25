$global:visited = @{}
$global:callTree = @{}

function Get-Calls($pgmName) {
    if ($global:visited[$pgmName]) { return @() }
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

    $subcalls = @()
    if ($foundFile) {
        # Para clp buscar CALL PGM(...)
        if ($foundFile -match "\.clp$") {
            $matches = Select-String -Pattern 'CALL\s+PGM\([^/]+/([^)]+)\)' -Path $foundFile
            foreach ($m in $matches) { $subcalls += $m.Matches.Groups[1].Value.Trim() }
            
            $matches2 = Select-String -Pattern 'CALL\s+PGM\(([^)/]+)\)' -Path $foundFile
            foreach ($m in $matches2) { $subcalls += $m.Matches.Groups[1].Value.Trim() }
        } else {
            # Para cbl buscar CALL "..."
            $matches = Select-String -Pattern 'CALL\s+["'']([^"'''']+)["'']' -Path $foundFile
            foreach ($m in $matches) { $subcalls += $m.Matches.Groups[1].Value.Trim() }
        }
    }

    $subcalls = $subcalls | Select-Object -Unique | Where-Object { $_ -notmatch '^&' }
    
    $node = @{}
    foreach ($c in $subcalls) {
        $node[$c] = Get-Calls $c
    }
    return $node
}

$topLevel = @("CCA201", "CCA205", "CCA500", "CCA502", "CCA510", "CCA513", "CCA520", "CCA530", "CCA540", "CCA545", "CCA550", "CCA560", "CCA565", "CCA580", "CCA590", "CCA599", "CCA601", "CCA602", "CCA606", "CCA630", "CCA660", "CCA661", "CCA662", "CCA664", "CCA671", "CCA672", "CCA710", "CCA711", "CCA760", "CCA765", "CCA770", "CCA800", "CCAACTREM")

function Print-Tree($tree, $indent) {
    foreach ($k in $tree.Keys) {
        Write-Output ("  " * $indent + "- " + $k)
        Print-Tree $tree[$k] ($indent + 1)
    }
}

foreach ($pgm in $topLevel) {
    Write-Output "=== $pgm ==="
    $tree = Get-Calls $pgm
    Print-Tree $tree 1
}
