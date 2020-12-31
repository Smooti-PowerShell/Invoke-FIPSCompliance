# Will enforce FIPS to all .exe.config files

function Invoke-FIPSCompliance {
    [CmdletBinding()]
    param (
        [ValidateCount(0, 1)]
        [String[]] $Path = 'C:\',

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
                        # (Get-Content -path $i -Raw) -replace '<enforceFIPSPolicy enabled="false"/>','<enforceFIPSPolicy enabled="true"/>' | Set-Content -Path $i
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
                # (Get-Content -path $i -Raw) -replace '<enforceFIPSPolicy enabled="false"/>','<enforceFIPSPolicy enabled="true"/>' | Set-Content -Path $i
            }
        }
        Catch {
            Write-Warning "Unable to enforce FIPS on '$($f)'"
        }
    }
    Write-Host "All files have been FIPS enforced!" -ForegroundColor Green
}

Invoke-FIPSCompliance -Path "F:\Scripts\Powershell"