foreach ( $i in 1..3 ) {
    Write-Progress -Id 0 "Step $i"
    foreach ( $j in 1..5 ) {
        Write-Progress -Id 1 -ParentId 0 "Step $i - Substep $j"
        foreach ( $k in 1..10 ) {
            Write-Progress -Id 2  -ParentId 1 "Step $i - Substep $j - iteration $k"; start-sleep -m 100
            Write-Host ("." * $i) "|" ("." * $j) "|" ("." * $k)
        }
    }   
}

$output = @()
foreach ( $i in 1..3 ) {
    Write-Progress -Id 0 "Step $i"
    foreach ( $j in 1..5 ) {
        Write-Progress -Id 1 -ParentId 0 "Step $i - Substep $j"
        foreach ( $k in 1..10 ) {
            Write-Progress -Id 2  -ParentId 1 "Step $i - Substep $j - iteration $k"; start-sleep -m 10
            $output += "$("." * $i) | $("." * $j) | $("." * $k)"
        }
    }   
}
$output