$dataRoot = Join-Path $PSScriptRoot 'data'
$models = @()

Get-ChildItem -LiteralPath $dataRoot -Directory | Sort-Object Name -Descending | ForEach-Object {
  $dir = $_
  $pcdPath = Join-Path $dir.FullName 'merged.pcd'
  $partsDir = Join-Path $dir.FullName 'parts'
  if ((Test-Path -LiteralPath $pcdPath) -and (Test-Path -LiteralPath $partsDir)) {
    $faces = Get-ChildItem -LiteralPath $partsDir -File -Filter 'face_*.obj' | Sort-Object Name | ForEach-Object {
      "data/$($dir.Name)/parts/$($_.Name)"
    }
    $images = 0..3 | ForEach-Object {
      $idx = $_
      $img = Join-Path $dir.FullName "$($idx)_colors.png"
      if (Test-Path -LiteralPath $img) { "data/$($dir.Name)/$($idx)_colors.png" }
    }
    $linePath = Join-Path $partsDir 'lines.obj'
    $pointPath = Join-Path $partsDir 'points.obj'
    $models += [PSCustomObject]@{
      id = $dir.Name
      images = @($images)
      pcd = "data/$($dir.Name)/merged.pcd"
      faces = @($faces)
      lines = if (Test-Path -LiteralPath $linePath) { "data/$($dir.Name)/parts/lines.obj" } else { $null }
      points = if (Test-Path -LiteralPath $pointPath) { "data/$($dir.Name)/parts/points.obj" } else { $null }
    }
  }
}

[PSCustomObject]@{ models = @($models) } |
  ConvertTo-Json -Depth 6 |
  Set-Content -LiteralPath (Join-Path $dataRoot 'manifest.json') -Encoding UTF8

Write-Host "Updated data/manifest.json with $($models.Count) model(s)."

