[CmdletBinding()]
param(
[string]$ZBXParam
)
[string[]]$AllUpdates = $ZBXParam.replace("-"," ").Split(":")
$AllObjects = @()
#$AllUpdates = ("Updates","Security Updates","Update Rollups","Feature Packs")

ForEach ($upd in $AllUpdates){
$obj = new-object PSCustomObject
Add-Member -InputObject $obj -MemberType NoteProperty -Name "UPNAME" -Value "$upd"
Add-Member -InputObject $obj -MemberType NoteProperty -Name "UPNUMBER" -Value 0
$AllObjects += $obj
}

$update = new-object -com Microsoft.update.Session
$searcher = $update.CreateUpdateSearcher()
$pending = $searcher.Search("IsInstalled=0")

foreach($entry in $pending.Updates)
{
    foreach($category in $entry.Categories)
    {
    if ($category.name -in $AllUpdates){
    ($AllObjects | ? {$_.upname -eq $category.name}).upnumber++
    }
  }
}
$AllObjectsJSON = $AllObjects| select @{N='{#UPNAME}'; E={$_.UPNAME}},@{N='{#UPNUMBER}'; E={$_.UPNUMBER}}
write-host "{"
write-host " `"data`":`n"
convertto-json $AllObjectsJSON
write-host "}"

#.\ZBX_GetPendingUpdates.ps1 -$ZBXParam Windows-10:Updates:Security-Updates:Update-Rollups:Feature-Packs