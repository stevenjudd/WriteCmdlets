$question = 'Why is no one afraid of the Ning tribe attacking?'
$answer = "Everyone knows it's just a war Ning and nothing to be worried about."

function whichKeyToPress {
  param(
    [string]$KeyToPress
  )
  Write-Host 'Press ' -ForegroundColor Green -NoNewline
  Write-Host $KeyToPress -ForegroundColor Magenta -NoNewline
  Write-Host ' for this example' -ForegroundColor Green
}

function demoWarning {
  Write-Warning $question
  Write-Warning $answer
}

function demoWarningInquireContinue {
  Write-Host 'Press ' -ForegroundColor Green -NoNewline
  Write-Host 'C' -ForegroundColor Magenta -NoNewline
  Write-Host ' for this example' -ForegroundColor Green
  
  Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  Write-Warning -Message 'As you wish'
}

function demoWarningInquireHalt {
  whichKeyToPress -KeyToPress 'H'
  Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  Write-Warning -Message 'As you wish'
}

function demoWarningInquireHaltCatch {
  try {
    whichKeyToPress -KeyToPress 'H'
    Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  } catch {
    return
  }
  Write-Warning -Message 'As you wish'
}

Wait-Debugger
demoWarning
demoWarningInquireContinue  #Continue example
demoWarningInquireHalt      #Halt example
demoWarningInquireHaltCatch #Halt and catch example
