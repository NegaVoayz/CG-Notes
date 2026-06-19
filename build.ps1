md -Force build
rm build/*
Get-ChildItem *.md | ForEach-Object { pandoc $_.FullName -o "build\$($_.BaseName).pdf" --pdf-engine=xelatex -V CJKmainfont="Microsoft YaHei" -V mathfont="STIX Two Math" -F "$env:AppData\npm\mermaid-filter.cmd" }
rm mermaid-filter.err