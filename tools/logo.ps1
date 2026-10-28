param([string]$OutDir, [int]$Size = 256)
# Draws the Scales logo: dark round badge, cyan gear, gold upgrade arrow. Writes Logo.tga (WoW) and logo.png.
Add-Type -AssemblyName System.Drawing

$S = $Size
$bmp = New-Object System.Drawing.Bitmap($S, $S, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.Clear([System.Drawing.Color]::Transparent)
$c = $S / 2

function Col($a, $r, $gg, $b) { [System.Drawing.Color]::FromArgb($a, $r, $gg, $b) }

# Badge: dark radial fill + gold rim + thin cyan inner rim
$rect = New-Object System.Drawing.RectangleF(6, 6, ($S - 12), ($S - 12))
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse($rect)
$pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
$pgb.CenterColor = Col 255 22 34 52
$pgb.SurroundColors = @(Col 255 6 8 14)
$g.FillEllipse($pgb, $rect)
$g.DrawEllipse((New-Object System.Drawing.Pen((Col 255 255 209 0), ($S * 0.035))), $rect)
$inner = New-Object System.Drawing.RectangleF(($S * 0.075), ($S * 0.075), ($S * 0.85), ($S * 0.85))
$g.DrawEllipse((New-Object System.Drawing.Pen((Col 160 51 204 255), ($S * 0.008))), $inner)

# Gear: 10 teeth, built as one polygon
$teeth = 10; $rOut = $S * 0.36; $rIn = $S * 0.29; $pts = @()
for ($i = 0; $i -lt $teeth; $i++) {
  $a0 = 2 * [Math]::PI * $i / $teeth
  $step = 2 * [Math]::PI / $teeth
  foreach ($p in @(@(-0.30, $rIn), @(-0.20, $rOut), @(0.20, $rOut), @(0.30, $rIn), @(0.50, $rIn))) {
    $a = $a0 + $p[0] * $step
    $pts += New-Object System.Drawing.PointF(($c + $p[1] * [Math]::Cos($a)), ($c + $p[1] * [Math]::Sin($a)))
  }
}
$gearPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$gearPath.AddPolygon($pts)
$hole = $S * 0.20
$gearPath.AddEllipse(($c - $hole), ($c - $hole), (2 * $hole), (2 * $hole))  # alternate fill mode cuts the hole
$gearBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.PointF(0, ($c - $rOut))), (New-Object System.Drawing.PointF(0, ($c + $rOut))), (Col 255 120 230 255), (Col 255 20 140 210))
$g.FillPath($gearBrush, $gearPath)
$g.DrawPath((New-Object System.Drawing.Pen((Col 255 8 40 70), ($S * 0.012))), $gearPath)

# Gold upgrade arrow in the middle
$w = $S * 0.13; $top = $c - $S * 0.17; $mid = $c - $S * 0.02; $bot = $c + $S * 0.16; $sh = $S * 0.055
$arrow = @(
  (New-Object System.Drawing.PointF($c, $top)),
  (New-Object System.Drawing.PointF(($c + $w), $mid)),
  (New-Object System.Drawing.PointF(($c + $sh), $mid)),
  (New-Object System.Drawing.PointF(($c + $sh), $bot)),
  (New-Object System.Drawing.PointF(($c - $sh), $bot)),
  (New-Object System.Drawing.PointF(($c - $sh), $mid)),
  (New-Object System.Drawing.PointF(($c - $w), $mid))
)
$arrowBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.PointF(0, $top)), (New-Object System.Drawing.PointF(0, $bot)), (Col 255 255 236 120), (Col 255 230 150 0))
$g.FillPolygon($arrowBrush, $arrow)
$g.DrawPolygon((New-Object System.Drawing.Pen((Col 255 70 40 0), ($S * 0.012))), $arrow)
$g.Dispose()

$bmp.Save((Join-Path $OutDir "logo.png"), [System.Drawing.Imaging.ImageFormat]::Png)

# Uncompressed 32-bit TGA, top-left origin (descriptor 0x28), BGRA
$data = New-Object byte[] (18 + $S * $S * 4)
$data[2] = 2
$data[12] = $S -band 0xFF; $data[13] = $S -shr 8
$data[14] = $S -band 0xFF; $data[15] = $S -shr 8
$data[16] = 32; $data[17] = 0x28
$o = 18
for ($y = 0; $y -lt $S; $y++) { for ($x = 0; $x -lt $S; $x++) {
  $px = $bmp.GetPixel($x, $y)
  $data[$o] = $px.B; $data[$o + 1] = $px.G; $data[$o + 2] = $px.R; $data[$o + 3] = $px.A; $o += 4
} }
[System.IO.File]::WriteAllBytes((Join-Path $OutDir "Logo.tga"), $data)
"ok $S"
