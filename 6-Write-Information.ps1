#region Setup
$question = 'Why does military data look so orderly?'
$answer = 'QgBlAGMAYQB1AHMAZQAgAGkAdAAnAHMAIABpAG4AIABmAG8AcgBtAGEAdABpAG8Abg' +
'AhAA=='
$answer = [System.Text.Encoding]::Unicode.GetString(
  [System.Convert]::FromBase64String($answer))
#endregion Setup
# ==============================================================================

function demoInfo1 {
  Get-ChildItem $pwd *-Write-*
  Write-Information $question -InformationAction Continue
  Write-Information $answer -InformationAction Continue
}

function demoInfo2 {
  $MessageText = 'Here is the info for which you asked'
  $Message1 = Write-Host $MessageText -ForegroundColor Cyan
  $Message1
  $Message2 = Write-Information $MessageText
  $Message2
  $Message3 = Write-Information $MessageText -InformationAction Continue
  $Message3
  # What is happening?
  $Message4 = Write-Information $MessageText 6>&1
  $Message4
  # Is crossing streams what you really want to do?
  Write-Information $MessageText -InformationVariable 'Message5'
  $Message5
}

Wait-Debugger
demoInfo1
Wait-Debugger
$results = demoInfo1
$results | Get-Member | Select-Object -Unique TypeName
$results
Wait-Debugger
demoInfo1 6> Information.txt
Get-Content Information.txt
Wait-Debugger
$results = demoInfo1 6>&1
$results | Get-Member | Select-Object -Unique TypeName
$results
Wait-Debugger
demoInfo2
