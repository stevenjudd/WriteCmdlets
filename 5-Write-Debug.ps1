$question = 'What did one developer say to the other when they increased ' +
  'logging and found the error?'
$answer = "It's debug."

function demoDebug1 () {
  [CmdletBinding()]
  param()
  Write-Debug $question
  Write-Debug $answer
}

function demoDebug2 () {
  [CmdletBinding()]
  param()
  Write-Debug $question
  Write-Debug $answer
}

function demoDebug3 () {
  [CmdletBinding()]
  param()
  $FileInfo = Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1'
  foreach ($item in $FileInfo) {
    Write-Verbose "Processing file: $($item.FullName)"
    Write-Debug $($FileInfo | Select-Object *)
  }
  
}

Wait-Debugger
demoDebug1 -Debug
# Wait-Debugger
demoDebug2 -Debug 5> Debug.txt
Get-Content Debug.txt
Wait-Debugger
demoDebug3
demoDebug3 -Verbose
Wait-Debugger
demoDebug3 -Verbose -Debug
Wait-Debugger
demoDebug3 -Verbose -Debug 5> FileDebug.txt
