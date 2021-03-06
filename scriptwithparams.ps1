# Author: Pranesh Sathyanarayan___Pranesh.S@horizontal.com
# Project: Devops Managed Services
# Date: 12-10-2020
# Script Usage: Script to automate disk usage checking of web app and trigger mail if usage size is above quota
# this script needs to be in a local path inside the web app, store ir locally in D:\home\scripts
# using sendinblue as the email provider here, change the -SmtpServer and -Port according to your environment

#Listing all Parameters to feed when invoking script
$paramsubscription=$args[0]
$paramrg=$args[1]
$paramalertfreq=$args[2]
$parampath=$args[3]
$paramallowedsize=$args[4]
$paramwebappname=$args[5]
$paramuname=$args[6]
$parampwd=$args[7]

#some variables
$subscription = $paramsubscription
$resourcegroup = $paramrg
$alertfrequency = $paramalertfreq
$webappname = $paramwebappname


#enter the value of $max in GB, for e.g 10, set the max value to around 80-90% of the actual quota threshold
$max = "{0:N3}" -f $paramallowedsize
# path to check the size, by default for windows web app will be D:\home
$path = $parampath

#Core logic to measure usage
$used = "{0:N3}" -f ((gci -r $path | measure Length -s).Sum /1GB)

#logging path
$log = "D:\home\DUAutomatnexecution.txt"
$message = "--------------------------------------------------------------------------"
$message >> $log
Get-Date >> $log
$message = "Started Script for checking Disk Usage"
$message >> $log

#action is taken if below condition matches, supply the username, password of sendgrid, also the FROM and TO address
if ($used -ge $max)
{
$User = $paramuname
$PWord = ConvertTo-SecureString -String $parampwd -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$body = "This is a Alert for File system usage for"+ " webapp " + "<b>$env:WEBSITE_HOSTNAME</b>"
$body+="<br>"
$body+= " <br>The app has used "+ "<b>$used</b>" + " GB out of the allocated " + "<b>$max</b>" + " GB" 
$body+="<br>"
$body+= " <br>Subscription:<b> $subscription</b>"
$body+="<br>"
$body+= " <br>Resource Group:<b> $resourcegroup</b>"
$body+="<br>"
$body+= " <br>Alert actionable by Devops Managed Services Team"
$body+="<br>"
$body+= " <br>Note: The alert will stop once usage is below $max GB"
$body+= "<br>"
$body+= "<br><i>The alert frequency has been set to $alertfrequency</i>"
$body+= "<br>"
$body+= "<br>To check the automation log go to <i>https://$webappname.scm.azurewebsites.net/api/vfs/DUAutomatnexecution.txt</i>"
Send-MailMessage -To "pranesh.s@horizontal.com" -From "noreply@horizontal.com"  -Subject "Disk Usage critical for web app $env:WEBSITE_HOSTNAME" -Body $body -BodyAsHtml -Credential $Credential -SmtpServer "smtp-relay.sendinblue.com" -Port 587
$message = "Disk Usage was found to be more than allowed : $max GB, triggered email alert for this"
$message >> $log
}
else
{
$message = "Looks like Disk Usage was normal, not triggering any email alert"
$message >> $log
}
#logging data to log
("Subscription Name:"+ $subscription) >> $log
("Resource Group:"+$resourcegroup) >> $log
("Web App:"+$env:WEBSITE_HOSTNAME)>> $log
("Frequency:"+$alertfrequency) >> $log
("Path Checked:"+$path) >> $log
("Current Usage in GB:"+$used) >> $log
("Allowed Size in GB:"+$max) >> $log
$message = "--------------------------------------------------------------------------"
$message >> $log
