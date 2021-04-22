function demoError {
    Get-Item "1"

    try {
        Get-Item "2"
    }
    catch {
        Write-Error "Item 2 not found"
    }

    try {
        Get-Item "3" -ErrorAction Stop
    }
    catch {
        Write-Error "Item 3 not found"
    }

    try {
        Get-Item "3" -ErrorAction Stop
    }
    catch {
        Write-Error $_
        Return
    }
    finally {
        Write-Host "End of demoError function"
    }
}

Wait-Debugger
demoError
