function demoVerbose1 () {
  [CmdletBinding()]
  param()
  Write-Verbose 'Why do action oriented operating system languages return so much data?'
  Write-Verbose 'Because they are Verb-OS'
}

function demoVerbose2 () {
  [CmdletBinding()]
  param()
  Write-Verbose 'Why do action oriented operating system languages return so much data?'
  Write-Verbose 'Because they are Verb-OS'
}

function demoVerbose3 () {
  param(
    [parameter()]
    [string]$message
  )
  Write-Verbose $message
}

Wait-Debugger
demoVerbose1 -Verbose
# Wait-Debugger
demoVerbose2 -Verbose 4> Verbose.txt
Get-Content Verbose.txt
# Wait-Debugger
demoVerbose3 'Advanced function mode enabled' -Verbose
