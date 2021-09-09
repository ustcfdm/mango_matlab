"List of functions content:" | Out-File content.txt -Encoding "UTF8"
Tree functions /F /a | Select-Object -skip 3 | Out-File -Append content.txt -Encoding "UTF8"