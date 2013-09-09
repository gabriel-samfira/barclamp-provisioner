Param(
  [string]$CrowbarAdminIP,
  [string]$CrowbarKey 
)


$cards = Get-WmiObject win32_networkadapter
foreach ($card in $cards)
{
  $ipaddr = Get-WmiObject win32_networkadapterconfiguration -Filter "index = $($card.Index)"
  if ($ipaddr.DHCPServer -eq $CrowbarAdminIP)
  {
    $hostname = $card.MACAddress -replace ":", "-"
    $hostname = "d$($hostname.ToLower())"
    break
  }
}

$uri =  "http://"+$CrowbarAdminIP+":3000"
$state = "installed"

$args = '-o "c:\Crowbar\Logs\'+$hostname+'-'+$state+'.json" --connect-timeout 60 -S -L -X POST --data-binary "{ \"name\": \"'+$hostname+'\", \"state\": \"'+$state+'\" }" -H "Accept: application/json" -H "Content-Type: application/json" --max-time 240 -u "'+$CrowbarKey+'" --digest --anyauth "'+$uri+'/crowbar/crowbar/1.0/transition/default"'

$process = New-Object System.Diagnostics.Process;
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.RedirectStandardOutput = $true
$process.StartInfo.RedirectStandardError = $true
$process.StartInfo.CreateNoWindow = $true
$process.StartInfo.FileName = 'C:\Crowbar\curl.exe'
$process.StartInfo.Arguments = $args
$started = $process.Start()

$out = $process.StandardOutput.ReadToEnd()
$err = $process.StandardError.ReadToEnd()
$process.WaitForExit()

