function demoDebug1 () {
  [CmdletBinding()]
  param()
  Write-Debug 'Console Debugging is not cool'
}

function demoDebug2 () {
  [CmdletBinding()]
  param()
  Write-Debug 'Console Debugging is not cool'
}

Wait-Debugger
demoDebug1 -Debug
Wait-Debugger
demoDebug2 -Debug 5> Debug.txt
Get-Content Debug.txt
Wait-Debugger
