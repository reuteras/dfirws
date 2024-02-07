# You cannot enable Windows PowerShell Remoting on network connections that are set to Public
# Spin through all the network locations and if they are set to Public, set them to Private
# using the INetwork interface:
# http://msdn.microsoft.com/en-us/library/windows/desktop/aa370750(v=vs.85).aspx
# For more info, see:
# http://blogs.msdn.com/b/powershell/archive/2009/04/03/setting-network-location-to-private.aspx

Write-Output "Setting network location to Private..."

# Network location feature was only introduced in Windows Vista - no need to bother with this
# if the operating system is older than Vista
if([environment]::OSVersion.version.Major -lt 6) {
	return
}

# Get network connections
$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$connections = $networkListManager.GetNetworkConnections()

$connections |ForEach-Object {
	$status = $_.GetNetwork().GetName() + "category was previously set to" + $_.GetNetwork().GetCategory()
	Write-Output "$status"
	$_.GetNetwork().SetCategory(1)
	$status = $_.GetNetwork().GetName() + "changed to category" + $_.GetNetwork().GetCategory()
	Write-Output "$status"
}
