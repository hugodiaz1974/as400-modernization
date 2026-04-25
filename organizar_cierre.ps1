# Definición del nombre de la carpeta destino
$destino = "Modulo_Cierre_Ahorros"

# Crear la carpeta si no existe
if (!(Test-Path $destino)) {
    New-Item -ItemType Directory -Path $destino
    Write-Host "Carpeta '$destino' creada."
}

# Lista de nombres base identificados en CCACIERRE.CLP
$nombresBase = @(
    "ccacierre", "ccabatch", "ccac085p", "ccatransf", "ccactrem",
    "cca500", "cca502", "cca505", "cca510", "cca511", "cca512", "cca520", "cca530",
    "cca540", "cca545", "cca550", "cca560", "cca565", "cca570", "cca580", "cca590", "cca599",
    "cca600", "cca601", "cca602", "cca605", "cca606", "cca610", "cca620", "cca630", "cca635",
    "cca640", "cca650", "cca660", "cca661", "cca662", "cca664", "cca671", "cca672", "cca680",
    "cca690", "cca700", "cca710", "cca711", "cca720", "cca730", "cca735", "cca740", "cca745",
    "cca750", "cca755", "cca760", "cca765", "cca770", "cca775", "cca780", "cca790", "cca800",
    "ccamaeaho", "pltccaina", "plttrnmon", "climae", "pltccacan", "pltccamut", "pltremma15",
    "pltcuadre", "pltfechas", "pltagcori", "ccahistor", "ccacodtrn", "ccahisdif",
    "ccadepmae", "ccacausac", "ccacodpro", "ccapargen", "ccamovimr", "pltmovimr", "ccanovcie",
    "ccanovcit", "ccacausas", "pltcausac", "plttrncca", "plttrnccah", "pltdiafst",
    "ccabatchs", "cca635s"
)

# Extensiones a buscar
$extensiones = @(".cbl", ".clp", ".pf", ".sda", ".dspf", ".lf")

Write-Host "Buscando y copiando archivos..."

foreach ($nombre in $nombresBase) {
    foreach ($ext in $extensiones) {
        $archivoBusqueda = "$nombre$ext"
        # Buscar el archivo en la carpeta actual y subcarpetas (excluyendo la de destino)
        $archivosEncontrados = Get-ChildItem -Path "." -Recurse -File -Filter $archivoBusqueda | Where-Object { $_.FullName -notmatch $destino }

        foreach ($file in $archivosEncontrados) {
            Copy-Item -Path $file.FullName -Destination $destino -Force
            Write-Host "Copiado: $($file.FullName) -> $destino"
        }
    }
}

Write-Host "Proceso completado."