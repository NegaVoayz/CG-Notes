md -Force build
rm build/*
Get-ChildItem *.md | ForEach-Object { md-preview-pdf $_.FullName "build\$($_.BaseName).pdf" }