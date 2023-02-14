function demoDebug1 () {
  [CmdletBinding()]
  param()
  Write-Debug 'What did one developer say to the other when they found the error?'
  Write-Debug "It's debug."
}

function demoDebug2 () {
  [CmdletBinding()]
  param()
  Write-Debug 'What did one developer say to the other when they found the error?'
  Write-Debug "It's debug."
}

Wait-Debugger
demoDebug1 -Debug
Wait-Debugger
demoDebug2 -Debug 5> Debug.txt
Get-Content Debug.txt
Wait-Debugger
