param([string]$OutDir, [int]$S = 64)
# Bag arrows: green up (upgrade), red down (downgrade), gold up (upgrade for another spec), 64x64 TGA with dark outline for contrast on any icon.
Add-Type -AssemblyName System.Drawing

function SaveTga($bmp, $file) {
  $data = New-Object byte[] (18 + $S * $S * 4)
  $data[2] = 2; $data[12] = $S; $data[14] = $S; $data[16] = 32; $data[17] = 0x28
  $o = 18
  for ($y = 0; $y -lt $S; $y++) { for ($x = 0; $x -lt $S; $x++) {
    $px = $bmp.GetPixel($x, $y)
    $data[$o] = $px.B; $data[$o + 1] = $px.G; $data[$o + 2] = $px.R; $data[$o + 3] = $px.A; $o += 4
  } }
  [System.IO.File]::WriteAllBytes((Join-Path $OutDir $file), $data)
}

function Arrow($up, $light, $dark, $file) {
  $bmp = New-Object System.Drawing.Bitmap($S, $S, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.Clear([System.Drawing.Color]::Transparent)
  $c = $S / 2; $w = $S * 0.42; $sh = $S * 0.17
  $tip = $S * 0.08; $mid = $S * 0.50; $end = $S * 0.92
  $pts = @(@($c, $tip), @(($c + $w), $mid), @(($c + $sh), $mid), @(($c + $sh), $end), @(($c - $sh), $end), @(($c - $sh), $mid), @(($c - $w), $mid))
  if (-not $up) { $pts = $pts | ForEach-Object { ,@($_[0], ($S - $_[1])) } }
  $poly = $pts | ForEach-Object { New-Object System.Drawing.PointF($_[0], $_[1]) }
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.PointF(0, 0)), (New-Object System.Drawing.PointF(0, $S)), $light, $dark)
  $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 0, 0, 0), ($S * 0.07))
  $pen.LineJoin = 'Round'
  $g.DrawPolygon($pen, $poly)
  $g.FillPolygon($brush, $poly)
  $g.Dispose()
  SaveTga $bmp $file
  $bmp.Save((Join-Path $OutDir ($file -replace '\.tga$', '.png')), [System.Drawing.Imaging.ImageFormat]::Png)
}

Arrow $true  ([System.Drawing.Color]::FromArgb(255, 150, 255, 120)) ([System.Drawing.Color]::FromArgb(255, 20, 170, 20)) "ArrowUp.tga"
Arrow $false ([System.Drawing.Color]::FromArgb(255, 255, 120, 100)) ([System.Drawing.Color]::FromArgb(255, 190, 20, 20)) "ArrowDown.tga"
Arrow $true  ([System.Drawing.Color]::FromArgb(255, 255, 240, 140)) ([System.Drawing.Color]::FromArgb(255, 220, 150, 0)) "ArrowOther.tga"
"ok"
