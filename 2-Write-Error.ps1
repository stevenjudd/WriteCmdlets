function demoError {
  Get-Item '1'

  try {
    Get-Item '2'
  } catch {
    Write-Error 'Item 2 not found'
  }

  try {
    Get-Item '3' -ErrorAction Stop
  } catch {
    Write-Error 'Item 3 not found'
    # Note the Line number where the error occurred
  }

  try {
    Get-Item '4' -ErrorAction Stop
  } catch {
    Write-Error $_
    Return
  } finally {
    Write-Host 'End of demoError function' -ForegroundColor Magenta
  }
}

function demoThrow {
  try {
    Get-Item '5' -ErrorAction Stop
  } catch {
    throw $_
  } finally {
    Write-Host 'End of demoThrow function' -ForegroundColor Magenta
  }
}

Wait-Debugger
demoError
demoThrow

#run by highlighting and F8
try {
  Get-Item '6' -ErrorAction Stop
} catch {
  throw $_
} finally {
  Write-Host 'End of demoThrow function' -ForegroundColor Magenta
}
