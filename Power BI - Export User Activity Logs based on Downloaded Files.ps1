# Retrieve credentials from Admin File

. "D:\OneDrive\BI\Power BI\APIs\AdminCreds.ps1"

# Authenticate to Power BI

$SecPasswd = ConvertTo-SecureString $password -AsPlainText -Force
$myCred = New-Object System.Management.Automation.PSCredential($username,$SecPasswd)
 
#Log into Power BI Quietly
Login-PowerBI -Credential $myCred

#Get Current Date Time
$CurrentDateTime = (Get-Date)

#Specify Folder Location for CSV Files to View & Export
$FolderAndCsvFilesLocation = "C:\Users\Gilbert\OneDrive - fourmoo.com\Power BI Audit Logs\Audit Logs"

#dir "X:\mgasia\BI Reporting - Documents\Audit Logs\*.csv" | 
$GetLastModifiedFileDateTime = Get-ChildItem "$FolderAndCsvFilesLocation\*.csv" | `

# Get the last 1 Days Files
Where{$_.LastWriteTime -gt (Get-Date).AddDays(-1)} | `

# Select the last File
 Select -First 1

#Convert the LastWriteTime to DateTime
$ConvertToDateTimeLastModified = [datetime]$GetLastModifiedFileDateTime.LastWriteTime
 
# Workout the Difference between the Dates
$DateDifference = New-timespan -Start $ConvertToDateTimeLastModified -End $CurrentDateTime

#Create a Variable with the Number of Days
$DaysDifference = $DateDifference.Days

#If Days Difference = 0 Make it 1
if ($DaysDifference -eq 0) {1} else {$DaysDifference}

# List of Dates to Iterate Through
$DaysDifference..1 |
    foreach {
        $Date = (((Get-Date).Date).AddDays(-$_))
        $StartDate = (Get-Date -Date ($Date) -Format yyyy-MM-ddTHH:mm:ss)
        $EndDate = (Get-Date -Date ((($Date).AddDays(1)).AddMilliseconds(-1)) -Format yyyy-MM-ddTHH:mm:ss)

#FileName
$FileName = (Get-Date -Date ($Date) -Format yyyyMMdd)
 
# Export location of CSV FIles
$ActivityLogsPath = "$FolderAndCsvFilesLocation\$FileName.csv"

#4. Export out current date activity log events to CSV file

$ActivityLogs = Get-PowerBIActivityEvent -StartDateTime $StartDate -EndDateTime $EndDate | ConvertFrom-Json

$ActivityLogSchema = $ActivityLogs | `
    Select-Object `
        Id,CreationTime,CreationTimeUTC,RecordType,Operation,OrganizationId,UserType,UserKey,Workload,UserId,ClientIP,UserAgent,Activity,ItemName,WorkSpaceName,DashboardName,DatasetName,ReportName,WorkspaceId,ObjectId,DashboardId,DatasetId,ReportId,OrgAppPermission,CapacityId,CapacityName,AppName,IsSuccess,ReportType,RequestId,ActivityId,AppReportId,DistributionMethod,ConsumptionMethod, `
        @{Name="RetrieveDate";Expression={$RetrieveDate}}

$ActivityLogSchema | Export-Csv $ActivityLogsPath 

#End of ForEach Loop
}
