param (
    [Parameter(HelpMessage = "Path to customize file.")]
    [string]$CustomizeFile = ".\defaults\customize-vm.ps1",
    [Parameter(HelpMessage = "Path to the VMX file.")]
    [string]$VM_VMX = ".\Windows_11_dfirws_64-bit.vmwarevm\Windows_11_dfirws_64-bit.vmx"
)

Start-Sleep 5

function Wait-VMReady {
    Write-Output "Waiting for the VM to start"
    vmrun.exe -T ws -gu dfirws -gp password  getGuestIPAddress "${VM_VMX}" -wait | Out-Null

    Write-Output "Waiting for the VM to be ready (interactive logon done)"
    while ( vmrun.exe -T ws -gu dfirws -gp password runProgramInGuest "${VM_VMX}" -activeWindow -interactive "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Command "Write-Output Hi" 2>&1 | Select-String "Error" ) {
        Start-Sleep 5
    }
}

Write-Output "Starting the VM"
vmrun.exe -T ws start "${VM_VMX}" gui

Wait-VMReady

Write-Output "Enabling shared folders"
vmrun.exe -T ws enableSharedFolders "${VM_VMX}"

Write-Output "Customize VM"
vmrun.exe -T ws -gu dfirws -gp password runProgramInGuest "${VM_VMX}" -activeWindow -interactive "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "\\vmware-host\Shared Folders\dfirws\local\${CustomizeFile}"

Write-Output "Shutting down the VM"
vmrun.exe -T ws stop "${VM_VMX}" soft

Write-Output "Creating snapshot 'DFIRWS customized'"
vmrun.exe -T ws snapshot "${VM_VMX}" "DFIRWS customized"