# Genera spritesheet de animación del murciélago usando .NET System.Drawing

$ErrorActionPreference = "Stop"

# Rutas
$baseDir = Split-Path -Parent $PSScriptRoot
$spritesDir = Join-Path $baseDir "assets\sprites\player"
$outputPath = Join-Path $spritesDir "bat_sheet.png"

# Configuración
$frameSize = 256
$frameNames = @("bat_anim_1.png", "bat_anim_2.png", "bat_anim_3.png", "bat_anim_4.png")

Write-Host "Generando spritesheet en $outputPath..."

# Cargar System.Drawing
Add-Type -AssemblyName System.Drawing

# Función para cargar y redimensionar frame
function Load-AndResize {
    param([string]$path)

    if (-not (Test-Path $path)) {
        throw "No existe $path"
    }

    $img = [System.Drawing.Image]::FromFile($path)

    # Calcular nueva dimensión manteniendo aspect ratio
    $width = $img.Width
    $height = $img.Height

    if ($width -gt $height) {
        $newWidth = $frameSize
        $newHeight = [int](($height / $width) * $frameSize)
    } else {
        $newHeight = $frameSize
        $newWidth = [int](($width / $height) * $frameSize)
    }

    # Crear canvas cuadrado
    $canvas = New-Object System.Drawing.Bitmap($frameSize, $frameSize)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.Clear([System.Drawing.Color]::Transparent)

    # Centrar imagen
    $offsetX = [int](($frameSize - $newWidth) / 2)
    $offsetY = [int](($frameSize - $newHeight) / 2)

    $destRect = New-Object System.Drawing.Rectangle($offsetX, $offsetY, $newWidth, $newHeight)
    $srcRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)

    $graphics.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

    $graphics.Dispose()
    $img.Dispose()

    return $canvas
}

# Cargar los 4 frames
$frames = @()
foreach ($name in $frameNames) {
    $path = Join-Path $spritesDir $name
    $frames += Load-AndResize $path
    Write-Host "  ✓ Cargado $name"
}

# Crear secuencia ping-pong: 1,2,3,4,4,3,2,1
$sequence = $frames + @($frames[3], $frames[2], $frames[1], $frames[0])

# Crear spritesheet horizontal: 8 frames × 256px = 2048px ancho
$spritesheet = New-Object System.Drawing.Bitmap(($frameSize * 8), $frameSize)
$graphics = [System.Drawing.Graphics]::FromImage($spritesheet)
$graphics.Clear([System.Drawing.Color]::Transparent)

for ($i = 0; $i -lt $sequence.Count; $i++) {
    $x = $i * $frameSize
    $graphics.DrawImage($sequence[$i], $x, 0, $frameSize, $frameSize)
}

$graphics.Dispose()

# Guardar
$spritesheet.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$spritesheet.Dispose()

# Limpiar frames
foreach ($frame in $frames) {
    $frame.Dispose()
}

Write-Host "✓ Spritesheet guardado: $outputPath"
Write-Host "  Dimensiones: 2048×256 px (8 frames de 256×256)"
