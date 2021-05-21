<#
    .SYNOPSIS
        Enforces FIPS compliance on all application config files.
    .NOTES
        Version:        1.0
        Author:         Robert Owens
        Creation Date:  01/03/2021
        
        V-30926 - The .NET CLR must be configured to use FIPS approved encryption modules.

        Description - FIPS encryption is configured via .NET configuration files. There are numerous configuration files
        that affect different aspects of .Net behavior. The .NET config files are described below.
        Machine Configuration Files: The machine configuration file, Machine.config, contains settings that apply to an entire computer.
        This file is located in the %SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\Config directory for 32 bit .NET 4 installations
        and %SYSTEMROOT%\Microsoft.NET\Framework64\v4.0.30319\Config for 64 bit systems. Machine.config contains configuration settings
        for machine-wide assembly binding, built-in remoting channels, and ASP.NET. Application Configuration Files: Application configuration
        files contain settings specific to an application. If checking these files, a .NET review of a specific .NET application is most likely being conducted.
        These files contain configuration settings that the Common Language Runtime reads (such as assembly binding policy, remoting objects, and so on),
        and settings that the application can read. The name and location of the application configuration file depends on the application's host,
        which can be one of the following: Executable–hosted application configuration files. The configuration file for an application hosted by the executable
        host is in the same directory as the application. The name of the configuration file is the name of the application with a .config extension.
        For example, an application called myApp.exe can be associated with a configuration file called myApp.exe.config.
        Internet Explorer-hosted application configuration files. If an application hosted in Internet Explorer has a configuration file,
        the location of this file is specified in a <link> tag with the following syntax. <link rel="ConfigurationFileName" href="location"> In this tag,
        "location" represents a URL that point to the configuration file. This sets the application base. The configuration file must be located on the same
        web site as the application. .NET 4.0 allows the CLR runtime to be configured to ignore FIPS encryption requirements.
        If the CLR is not configured to use FIPS encryption modules, insecure encryption modules might be employed which could
        introduce an application confidentiality or integrity issue.
    .PARAMETER Path
        DEFAULT: C:\
        Path you would like to enumerate (This will be recursive).
    .PARAMETER AllDrives
        If specified will enforce FIPS on all drives from the root of each recursively.
    .EXAMPLE
        Invoke-FIPSCompliance         
    .EXAMPLE
        Invoke-FIPSCompliance -Path "C:\Users\"
    .EXAMPLE
        Invoke-FIPSCompliance -AllDrives
#>

param (
    [String] $Path = 'C:\',

    [switch] $AllDrives
)

if ($AllDrives) {
    $drives = [System.IO.DriveInfo]::getdrives() | Where-Object { $_.DriveType -eq 'Fixed' } | Select-Object -ExpandProperty 'Name'

    ForEach ($d in $drives) {
        Write-Host "Scanning drive '$($d)' for non-compliant files...`n" -ForegroundColor Cyan
        $files = @(Get-ChildItem -Path "$($d)*.exe.config" -Recurse -ErrorAction SilentlyContinue).FullName 
    
        ForEach ($f in $files) {
            Try {
                if (-NOT($f -like "*KeePass*")) {
                    (Get-Content -path $i -Raw) -replace '<enforceFIPSPolicy enabled="false"/>','<enforceFIPSPolicy enabled="true"/>' | Set-Content -Path $i
                }
            }
            Catch {
                Write-Warning "Unable to enforce FIPS on '$($f)'"
            }
        }
    }
    Write-Host "All drives have been FIPS Enforced!" -ForegroundColor Green
    Exit
}  

Write-Host "Scanning '$($Path)' for non-compliant files...`n" -ForegroundColor Cyan
$files = @(Get-ChildItem -Path "$($Path)*.exe.config" -Recurse -ErrorAction SilentlyContinue).FullName 

ForEach ($f in $files) {
    Try {
        if (-NOT($f -like "*KeePass*")) {
            (Get-Content -path $i -Raw) -replace '<enforceFIPSPolicy enabled="false"/>','<enforceFIPSPolicy enabled="true"/>' | Set-Content -Path $i
        }
    }
    Catch {
        Write-Warning "Unable to enforce FIPS on '$($f)'"
    }
}
Write-Host "All files have been FIPS enforced!" -ForegroundColor Green
