$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "Proxmox-Lab"
$ISOPath = "$HOME\Downloads\proxmox-ve_9.1-1.iso"
$DiskPath = "$HOME\VirtualBox VMs\$VMName\$VMName.vdi"

# Check if VM exists
$exists = & $VBoxManage list vms | Select-String $VMName
if ($exists) {
    Write-Host "VM '$VMName' is already registered in VirtualBox."
    Write-Host "Please remove it manually or change the VMName."
    exit
}

# Cleanup Zombie Files (Files exist but VM not registered)
$VMFolder = "$HOME\VirtualBox VMs\$VMName"
if (Test-Path $VMFolder) {
    Write-Host "WARNING: Found existing files at $VMFolder but VM is not registered."
    Write-Host "Cleaning up old files..."
    Remove-Item -Path $VMFolder -Recurse -Force
}

# Create VM
Write-Host "Creating VM '$VMName'..."
& $VBoxManage createvm --name $VMName --ostype "Linux_64" --register

# Configure System
Write-Host "Configuring generic settings..."
& $VBoxManage modifyvm $VMName --memory 8192 --cpus 4 --vram 128
& $VBoxManage modifyvm $VMName --nested-hw-virt on   # Critical for Nested Virtualization
& $VBoxManage modifyvm $VMName --nic1 bridged --bridgeadapter1 "Realtek 8812BU Wireless LAN 802.11ac USB NIC"

# Create Storage
Write-Host "Creating Storage..."
& $VBoxManage createhd --filename $DiskPath --size 60000 --format VDI
& $VBoxManage storagectl $VMName --name "SATA Controller" --add sata --controller IntelAhci
& $VBoxManage storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $DiskPath

# Attach ISO (IDE Controller)
Write-Host "Configuring ISO drive..."
& $VBoxManage storagectl $VMName --name "IDE Controller" --add ide
if (Test-Path $ISOPath) {
    & $VBoxManage storageattach $VMName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISOPath
    Write-Host "ISO attached successfully."
}
else {
    Write-Host "WARNING: ISO not found at $ISOPath. Please attach manually."
    & $VBoxManage storageattach $VMName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
}

Write-Host "VM '$VMName' created successfully!"
Write-Host "1. Open VirtualBox"
Write-Host "2. Start '$VMName'"
Write-Host "3. Proceed with Proxmox Installation."
