# fnDemoSetup "C:\Docker\SQLServer\Linux\SQLLinuxDemoAttach\"
function fnDemoSetup ($DockerLinuxDirectory) {
    
cls
sl C:\

$DemoDirectory = $DockerLinuxDirectory
#$DemoSourceFiles = split-path -parent $psISE.CurrentFile.Fullpath #Powershell ISE Only
$context = [Microsoft.Powershell.EditorServices.Extensions.EditorContext]$psEditor.GetEditorContext() #VS Code
$DemoSourceFiles = split-path -Parent $context.CurrentFile.Path
Write-Host "'$DemoSourceFiles'" "now set" -ForegroundColor Green
if (Test-Path -PathType Container $DemoDirectory) {
    remove-item -Path $DemoDirectory -Force -Recurse | Out-NULL
    #new-item -ItemType Directory -Path $DemoDirectory -Force | Out-NULL
}
else {
    #new-item -ItemType Directory -Path $DemoDirectory -Force | Out-NULL
    }
copy-item $DemoSourceFiles $DockerLinuxDirectory -Recurse
    
Write-Host "Copying files from" $DemoSourceFiles "to" $DockerLinuxDirectory -ForegroundColor Green

#Set the location to the Dockerfile
sl $DemoDirectory
}

