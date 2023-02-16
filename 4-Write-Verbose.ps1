#region Setup
$question = 'Why do action oriented operating systems return so much data?'
$answer = 'QgBlAGMAYQB1AHMAZQAgAHQAaABlAHkAIABhAHIAZQAgAFYAZQByAGIALQBPAFMA'
$answer = [System.Text.Encoding]::Unicode.GetString(
  [System.Convert]::FromBase64String($answer))
#endregion Setup
# ==============================================================================

function demoVerbose1 () {
  [CmdletBinding()]
  param()
  Write-Verbose $question
  Write-Verbose $answer
}

function demoVerbose2 () {
  param(
    [parameter()]
    [string]$message
  )
  Write-Verbose $message
}

Wait-Debugger
demoVerbose1 -Verbose
# Wait-Debugger
demoVerbose1 -Verbose 4> Verbose.txt
Get-Content Verbose.txt
# Wait-Debugger
demoVerbose2 'Advanced function mode enabled' -Verbose
