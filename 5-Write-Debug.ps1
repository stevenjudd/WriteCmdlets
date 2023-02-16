#region Setup
$question = 'What did one developer say to the other when they increased ' +
'logging and found the error?'
$answer = 'SQB0ACcAcwAgAGQAZQBiAHUAZwAuAA=='
$answer = [System.Text.Encoding]::Unicode.GetString(
  [System.Convert]::FromBase64String($answer))
#endregion Setup
# ==============================================================================

function demoDebug1 () {
  [CmdletBinding()]
  param()
  Write-Debug $question
  Write-Debug $answer
}

function demoDebug2 () {
  [CmdletBinding()]
  param()
  $fileInfo = Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1'
  foreach ($item in $fileInfo) {
    Write-Verbose "Processing file: $($item.FullName)"
    Write-Debug $($item | Select-Object * | Out-String)
  }
  
}

Wait-Debugger
demoDebug1 -Debug
# Wait-Debugger
demoDebug1 -Debug 5> Debug.txt
Get-Content Debug.txt
Wait-Debugger
demoDebug2
Wait-Debugger
demoDebug2 -Verbose
Wait-Debugger
demoDebug2 -Verbose -Debug
Wait-Debugger
demoDebug2 -Verbose -Debug 5> FileDebug.txt
