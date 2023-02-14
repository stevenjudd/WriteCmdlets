function demoInfo1 {
  Get-ChildItem $pwd
  Write-Information 'Done!' -InformationAction Continue
}

Wait-Debugger
$results = demoInfo1 6>&1
$results | Get-Member | Select-Object -Unique TypeName
$results
