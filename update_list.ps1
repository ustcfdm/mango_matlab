"List of content:" | Out-File content.txt -Encoding "UTF8"
Tree /F | Select-Object -skip 3 | Out-File -Append content.txt -Encoding "UTF8"