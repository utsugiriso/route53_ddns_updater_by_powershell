$domain = "XXXX"
$hosted_zone_id = "XXXX"
$access_key = "XXXX"
$secret_access_key = "XXXX"

$ip_address = (Invoke-WebRequest "ifconfig.me").Content
Write-Output($ip_address)

$profile_name = "Route53DdnsUpdater"
Set-AWSCredential -AccessKey $access_key -SecretKey $secret_access_key -StoreAs $profile_name

if($ip_address -ne ((Get-R53ResourceRecordSet -HostedZoneId $hosted_zone_id -ProfileName $profile_name -StartRecordName $domain -StartRecordType "A").ResourceRecordSets | where Type -eq "A").ResourceRecords.Value){
    $resourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet
    $resourceRecordSet.Name = $domain
    $resourceRecordSet.Type = "A"
    $resourceRecordSet.ResourceRecords = New-Object Amazon.Route53.Model.ResourceRecord($ip_address)
    $resourceRecordSet.TTL = 300

    $change = New-Object Amazon.Route53.Model.Change([Amazon.Route53.ChangeAction]::UPSERT, $resourceRecordSet)

    Edit-R53ResourceRecordSet -HostedZoneId $hosted_zone_id -ChangeBatch_Change $change -ProfileName $profile_name
}
