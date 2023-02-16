#region Setup
$question = 'Why is no one afraid of the Ning tribe attacking?'
$answer = 'RQB2AGUAcgB5AG8AbgBlACAAawBuAG8AdwBzACAAaQB0ACcAcwAgAGoAdQBzAHQAIA' +
'BhACAAdwBhAHIAIABOAGkAbgBnACAAYQBuAGQAIABuAG8AdABoAGkAbgBnACAAdABvACAAYgBl' +
'ACAAdwBvAHIAcgBpAGUAZAAgAGEAYgBvAHUAdAAuAA=='
$answer = [System.Text.Encoding]::Unicode.GetString(
  [System.Convert]::FromBase64String($answer))

function whichKeyToPress {
  param(
    [string]$KeyToPress
  )
  Write-Host 'Press ' -ForegroundColor Green -NoNewline
  Write-Host $KeyToPress -ForegroundColor Magenta -NoNewline
  Write-Host ' for this example' -ForegroundColor Green
}
#endregion Setup
# ==============================================================================

function demoWarning {
  Write-Warning $question
  Write-Warning $answer
}

function demoWarningInquireContinue {
  Write-Host 'Press ' -ForegroundColor Green -NoNewline
  Write-Host 'Y' -ForegroundColor Magenta -NoNewline
  Write-Host ' for this example' -ForegroundColor Green

  Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  Write-Warning -Message 'As you wish'
}

function demoWarningInquireHaltCatch {
  try {
    whichKeyToPress -KeyToPress 'H' #code reduction example
    Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  } catch {
    Write-Warning -Message 'As you wish'
    return
  } finally {
    Write-Warning -Message 'Exiting'
  }
}

function demoWarningInquireHalt {
  whichKeyToPress -KeyToPress 'H'
  Wait-Debugger
  Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  Write-Warning -Message 'As you wish'
}

Wait-Debugger
demoWarning
Wait-Debugger
demoWarningInquireContinue  #Continue example

demoWarningInquireHaltCatch #Halt and catch example

demoWarningInquireHalt      #Halt example
