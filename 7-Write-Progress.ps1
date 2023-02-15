if ((Get-Host).Name -ne 'ConsoleHost') {
  try {
    Write-Warning 'This demo works best from the console' -WarningAction Inquire
  } catch {
    Write-Warning 'Halting as selected'
    return
  }
}

# taken from Example 4 in the help for Write-Progress
# updated the number of iterations and the delay time
foreach ( $i in 1..3 ) {
  Write-Progress -Id 0 "Step $i"
  foreach ( $j in 1..5 ) {
    Write-Progress -Id 1 -ParentId 0 "Step $i - Substep $j"
    foreach ( $k in 1..10 ) {
      Write-Progress -Id 2  -ParentId 1 "Step $i - Substep $j - iteration $k"; Start-Sleep -m 50
      # I added the following line
      Write-Host ('.' * $i) '|' ('.' * $j) '|' ('.' * $k)
    }
  }   
}

Wait-Debugger
$output = @()
$Level1 = 3
$Level2 = 5
$Level3 = 10
$sleepDuration = 50

foreach ( $i in 1..$Level1 ) {
  Write-Progress -Id 0 "Step $i"
  foreach ( $j in 1..$Level2 ) {
    Write-Progress -Id 1 -ParentId 0 "Step $i - Substep $j"
    foreach ( $k in 1..$Level3 ) {
      Write-Progress -Id 2  -ParentId 1 "Step $i - Substep $j - iteration $k"
      Start-Sleep -Milliseconds $sleepDuration
      $output += "$('.' * $i) | $('.' * $j) | $('.' * $k)"
    }
  }   
}
$output