function demoInfo1 {
    Get-ChildItem $pwd
    Write-Information "Done!" -InformationAction Continue
}

function demoInfo2 {
    Get-ChildItem $pwd
    Write-Information "Done!"
}

Wait-Debugger
demoInfo1
Wait-Debugger
$results = demoInfo1
$results | Get-Member | Select-Object -Unique TypeName
$results
Wait-Debugger
demoInfo2
Wait-Debugger
demoInfo2 6> Information.txt
Get-Content Information.txt
Wait-Debugger
$results = demoInfo1 6>&1
$results | Get-Member | Select-Object -Unique TypeName
$results
