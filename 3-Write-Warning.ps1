function demoWarning {
  Write-Warning 'Dad jokes are something you get used to over time. They groan on you.'
}

function demoWarningInquire {
  Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  Write-Warning -Message 'As you wish'
}

function demoWarningInquireHaltCatch {
  try {
    Write-Warning -Message 'Do you want more Dad jokes?' -WarningAction Inquire
  } catch {
    return
  }
  Write-Warning -Message 'As you wish'
}

Wait-Debugger
demoWarning
demoWarningInquire #Continue example
demoWarningInquire #Halt example
demoWarningInquireHaltCatch
