
# Script permettant d'ajouter les droits Citrix pour l'utilisation de PVS, MCS 
# avec un compte de service Microsoft.
#
#
#
# https://support.citrix.com/article/CTX214389
# https://ryanjan.uk/2019/06/19/vsphere-global-permissions-with-powershell
# https://jm2k69.github.io/2018/05/PowerCli-roles-and-permissions.html
# https://www.vthistle.com/2015/10/23/vsphere-permissions-powercli/

Install-Module -Name "VMware.Powercli" -Scope Currentuser
Install-Module -Name "VIPerms" -Scope Currentuser
Import-Module -Name "VMware.Powercli"
import-Module -Name "VIPerms"
write-host "Veuillez entrer le fqdn de votre VCenter sans le http(s)" -foregroundColor green
$vcenter = read-host
write-host "Veuillez entrer le compte administrateur du VCenter" -foregroundColor green
$cred = get-credential
$open = Connect-VIServer -Server $vcenter -credential $cred 
if ($open) {
    $Perms = Get-VIPrivilege -id Datastore.AllocateSpace, Datastore.Browse, Datastore.FileManagement, Network.Assign, Resource.AssignVMToPool, VirtualMachine.Config.AddExistingDisk, VirtualMachine.Config.AddNewDisk, VirtualMachine.Config.AdvancedConfig, VirtualMachine.Config.RemoveDisk, VirtualMachine.Interact.PowerOff, VirtualMachine.Interact.PowerOn, VirtualMachine.Inventory.CreateFromExisting, VirtualMachine.Inventory.Create, VirtualMachine.Inventory.Delete, VirtualMachine.Provisioning.Clone, VirtualMachine.State.CreateSnapshot, Global.ManageCustomFields, Global.SetCustomField, VirtualMachine.Config.EditDevice, VirtualMachine.Interact.Reset, VirtualMachine.Interact.Suspend, VirtualMachine.Config.AddRemoveDevice, VirtualMachine.Config.CPUCount, VirtualMachine.Config.Memory, VirtualMachine.Config.Settings, VirtualMachine.Provisioning.CloneTemplate, VirtualMachine.Provisioning.DeployTemplate
    write-host "Veuillez entrer le nom du role pour Citrix :" -foregroundColor green
    $rolename = read-host
    write-host "Veuillez entrer le compte de service Citrix / VMware (domain\user) :" -foregroundColor green
    write-host "Attention Verifier que le compte de service ne soit pas deja utilise" -backgroundColor red
    $domainuserservice = read-host
    
    $role = New-VIRole -Name $rolename -Privilege $Perms
    $mypermission = New-VIPermission -Entity (Get-Datacenter) -Principal $domainuserservice -Role $role -Propagate:$true
    
    if (Connect-VIMobServer -Server $vcenter -credential $cred) {
        #Get-VIGlobalPermission
        
        Get-VIMobRole | Format-List
        write-host "Entrer l'ID du role", $rolename, " que vous souhaitez associer" -foregroundColor red
        $roleid = read-host -prompt "roleId"
        New-VIGlobalPermission -Name $domainuserservice -roleid $roleid 
    }
    else {
        write-host ("impossible de se connecter au vcenter Global Permission") -backgroundColor red
    }
    
}
else {
    write-host "Verifier les credentials administrator VMware ou le fqdn sans http(s)" -backgroundColor red
}

