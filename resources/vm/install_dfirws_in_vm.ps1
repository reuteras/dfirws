param (
    [string]$VM_VMX = ".\Windows_11_dfirws_64-bit.vmwarevm\Windows_11_dfirws_64-bit.vmx"
)

if (!(vmrun.exe -T ws listSnapshots "${VM_VMX}" | Select-String Installed)) {
    Write-Output "No snapshot 'Installed'."
    Exit 1
}

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

Write-Output "Add shared folder and mark as read-only"
$DFIRWS_PATH = Resolve-Path "."
Write-Output "DFIRWS_PATH: ${DFIRWS_PATH}"

Write-Output "Enabling shared folders"
vmrun.exe -T ws enableSharedFolders "${VM_VMX}"

Write-Output "Adding shared folder dfirws for installation of dfirws"
vmrun.exe -T ws addSharedFolder "${VM_VMX}" "dfirws" "${DFIRWS_PATH}"
Write-Output "Marking shared folder dfirws as read-only"
vmrun.exe -T ws setSharedFolderState "${VM_VMX}" "dfirws" "${DFIRWS_PATH}" readonly

Write-Output "Adding shared folder readonly for later analyses."
vmrun.exe -T ws addSharedFolder "${VM_VMX}" "readonly" "${DFIRWS_PATH}\readonly"
Write-Output "Marking shared folder readonly as read-only"
vmrun.exe -T ws setSharedFolderState "${VM_VMX}" "readonly" "${DFIRWS_PATH}\readonly" readonly

Write-Output "Adding shared folder readwrite for later analyses."
vmrun.exe -T ws addSharedFolder "${VM_VMX}" "readwrite" "${DFIRWS_PATH}\readwrite"
Write-Output "Marking shared folder readwrite as read-write"
vmrun.exe -T ws setSharedFolderState "${VM_VMX}" "readwrite" "${DFIRWS_PATH}\readwrite" readwrite

Write-Output "Copy files to VM. This will take a while."
vmrun.exe -T ws -gu dfirws -gp password runProgramInGuest "${VM_VMX}" -activeWindow -interactive "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "\\vmware-host\Shared Folders\dfirws\resources\vm\copy_files_to_vm.ps1"

Write-Output "Shutting down the VM"
vmrun.exe -T ws stop "${VM_VMX}" soft

Write-Output "Creating snapshot 'DFIRWS copied to VM'"
vmrun.exe -T ws snapshot "${VM_VMX}" "DFIRWS copied"

Write-Output "Starting the VM"
vmrun.exe -T ws start "${VM_VMX}" gui

Wait-VMReady

Write-Output "Install DFIRWS in VM"
vmrun.exe -T ws -gu dfirws -gp password runProgramInGuest "${VM_VMX}" -activeWindow -interactive "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "\\vmware-host\Shared Folders\dfirws\resources\vm\run_start_sandbox.ps1"

Write-Output "Remove shared folder dfirws"
vmrun.exe -T ws removeSharedFolder "${VM_VMX}" "dfirws"

Write-Output "Shutting down the VM"
vmrun.exe -T ws stop "${VM_VMX}" soft

Write-Output "Creating snapshot 'DFIRWS installed'"
vmrun.exe -T ws snapshot "${VM_VMX}" "DFIRWS installed"
