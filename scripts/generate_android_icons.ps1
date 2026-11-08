Add-Type -AssemblyName System.Drawing

$projectRoot = "C:\Users\93799\.gemini\antigravity\scratch\solar_system_3d"
$resDir = Join-Path $projectRoot "android\app\src\main\res"

# 1. Update background color in values
$bgXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#000004</color>
</resources>
"@
Set-Content -Path (Join-Path $resDir "values\ic_launcher_background.xml") -Value $bgXml -Encoding UTF8

# Function to draw Saturn planet & rings on Graphics object
function Draw-SaturnLogo {
    param(
        [System.Drawing.Graphics]$g,
        [int]$width,
        [int]$height,
        [bool]$hasDeepBackground = $true,
        [string]$titleText = ""
    )
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    if ($hasDeepBackground) {
        $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0, 0, 4))
        $g.FillRectangle($bgBrush, 0, 0, $width, $height)
        $bgBrush.Dispose()

        # Draw subtle stars
        $rng = New-Object System.Random(42)
        $starBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 240, 250, 255))
        $dimStarBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 160, 180, 210))
        for ($i = 0; $i -lt 40; $i++) {
            $sx = $rng.Next(0, $width)
            $sy = $rng.Next(0, $height)
            $ss = if ($rng.Next(0, 5) -eq 0) { 2 } else { 1 }
            $b = if ($ss -eq 2) { $starBrush } else { $dimStarBrush }
            $g.FillEllipse($b, $sx, $sy, $ss, $ss)
        }
        $starBrush.Dispose()
        $dimStarBrush.Dispose()
    } else {
        $g.Clear([System.Drawing.Color]::Transparent)
    }

    $cx = $width / 2.0
    $cy = if ([string]::IsNullOrEmpty($titleText)) { $height / 2.0 } else { $height / 2.0 - 24 }

    # Planet radius
    $pr = [Math]::Min($width, $height) * 0.22

    # Draw back half of Saturn rings
    $ringW = $pr * 3.4
    $ringH = $pr * 0.95
    $ringPenBack = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(170, 244, 162, 97), [Math]::Max(1.5, $pr * 0.16))
    $ringInnerPenBack = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 226, 232, 240), [Math]::Max(1.0, $pr * 0.08))

    # Save state, rotate for tilted rings
    $state = $g.Save()
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform(-24)

    # Draw back arc of rings (180 to 360)
    $g.DrawArc($ringPenBack, -$ringW/2, -$ringH/2, $ringW, $ringH, 180, 180)
    $g.DrawArc($ringInnerPenBack, -($ringW*0.75)/2, -($ringH*0.75)/2, ($ringW*0.75), ($ringH*0.75), 180, 180)
    $g.Restore($state)
    $ringPenBack.Dispose()
    $ringInnerPenBack.Dispose()

    # Draw Planet Body with radial/linear gradient
    $pRect = New-Object System.Drawing.RectangleF(($cx - $pr), ($cy - $pr), ($pr * 2), ($pr * 2))
    $planetBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        [System.Drawing.PointF]::new($cx - $pr, $cy - $pr),
        [System.Drawing.PointF]::new($cx + $pr, $cy + $pr),
        [System.Drawing.Color]::FromArgb(255, 244, 162, 97),
        [System.Drawing.Color]::FromArgb(255, 180, 100, 50)
    )
    $g.FillEllipse($planetBrush, $pRect)
    $planetBrush.Dispose()

    # Atmosphere glow arc
    $atmoPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 226, 232, 240), [Math]::Max(1.0, $pr * 0.06))
    $g.DrawEllipse($atmoPen, $pRect)
    $atmoPen.Dispose()

    # Draw front half of Saturn rings
    $stateFront = $g.Save()
    $g.TranslateTransform($cx, $cy)
    $g.RotateTransform(-24)

    $ringPenFront = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 244, 162, 97), [Math]::Max(1.5, $pr * 0.16))
    $ringInnerPenFront = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 240, 244, 250), [Math]::Max(1.0, $pr * 0.08))
    $g.DrawArc($ringPenFront, -$ringW/2, -$ringH/2, $ringW, $ringH, 0, 180)
    $g.DrawArc($ringInnerPenFront, -($ringW*0.75)/2, -($ringH*0.75)/2, ($ringW*0.75), ($ringH*0.75), 0, 180)
    $g.Restore($stateFront)
    $ringPenFront.Dispose()
    $ringInnerPenFront.Dispose()

    # Optional Title Text for Splash
    if (-not [string]::IsNullOrEmpty($titleText)) {
        $fontSize = [Math]::Max(14.0, [Math]::Min($width, $height) * 0.045)
        $font = New-Object System.Drawing.Font("Segoe UI", $fontSize, [System.Drawing.FontStyle]::Bold)
        $subFont = New-Object System.Drawing.Font("Segoe UI", ($fontSize * 0.65), [System.Drawing.FontStyle]::Regular)
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 255, 255, 255))
        $subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(160, 203, 213, 225))
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

        $textY = $cy + $pr + 36
        $g.DrawString($titleText, $font, $textBrush, $cx, $textY, $sf)
        $g.DrawString("NASA 3D PLANETARIUM", $subFont, $subBrush, $cx, ($textY + $fontSize * 1.6), $sf)

        $font.Dispose()
        $subFont.Dispose()
        $textBrush.Dispose()
        $subBrush.Dispose()
        $sf.Dispose()
    }
}

# 2. Generate Mipmap Icons
$iconSizes = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

$fgSizes = @{
    "mipmap-mdpi"    = 108
    "mipmap-hdpi"    = 162
    "mipmap-xhdpi"   = 216
    "mipmap-xxhdpi"  = 324
    "mipmap-xxxhdpi" = 432
}

foreach ($folder in $iconSizes.Keys) {
    $size = $iconSizes[$folder]
    $dir = Join-Path $resDir $folder

    # Standard Icon with dark background
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    Draw-SaturnLogo -g $g -width $size -height $size -hasDeepBackground $true
    $bmp.Save((Join-Path $dir "ic_launcher.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Save((Join-Path $dir "ic_launcher_round.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()

    # Adaptive Foreground (transparent bg)
    $fgSize = $fgSizes[$folder]
    $bmpFg = New-Object System.Drawing.Bitmap($fgSize, $fgSize)
    $gFg = [System.Drawing.Graphics]::FromImage($bmpFg)
    Draw-SaturnLogo -g $gFg -width $fgSize -height $fgSize -hasDeepBackground $false
    $bmpFg.Save((Join-Path $dir "ic_launcher_foreground.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $gFg.Dispose()
    $bmpFg.Dispose()

    Write-Host "Generated icons for $folder ($size x $size, fg: $fgSize x $fgSize)"
}

# 3. Generate Splash Screens
$splashDirs = Get-ChildItem -Path $resDir -Directory -Filter "drawable*"

foreach ($sDir in $splashDirs) {
    $splashPath = Join-Path $sDir.FullName "splash.png"
    if (Test-Path $splashPath) {
        $oldImg = [System.Drawing.Image]::FromFile($splashPath)
        $sw = $oldImg.Width
        $sh = $oldImg.Height
        $oldImg.Dispose()

        $bmpSplash = New-Object System.Drawing.Bitmap($sw, $sh)
        $gSplash = [System.Drawing.Graphics]::FromImage($bmpSplash)
        Draw-SaturnLogo -g $gSplash -width $sw -height $sh -hasDeepBackground $true -titleText "СОЛНЕЧНАЯ СИСТЕМА"
        $bmpSplash.Save($splashPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $gSplash.Dispose()
        $bmpSplash.Dispose()

        Write-Host "Updated splash for $($sDir.Name) ($sw x $sh)"
    }
}

Write-Host "All Android icons and splash screens generated successfully!"
