<#
.SYNOPSIS
This script helps to configure its environment variables based on the component selected.

.EXAMPLE
.\tools\Run.ps1 testing -s functions -c install_maven -y

.EXAMPLE
.\tools\Run.ps1 all_in_one

.EXAMPLE
.\tools\Run.ps1 aai

.PARAMETER s
Test suite to use in testing mode.

.PARAMETER c
Test case to use in testing mode.

.PARAMETER y
Skips warning prompt.

.PARAMETER g
Skips creation or retrieve image process.

.PARAMETER i
Skips installation service process.

.LINK
https://wiki.onap.org/display/DW/ONAP+on+Vagrant
#>

Param(
    [ValidateSet("all_in_one","dns", "mr", "sdc", "aai", "mso", "robot", "vid", "sdnc", "portal", "dcae", "policy", "appc", "vfc", "multicloud", "ccsdk", "vnfsdk", "vvp", "openstack", "msb", "oom", "testing")]

    [Parameter(Mandatory=$True,Position=0)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Command
,
    [Parameter(Mandatory=$False,HelpMessage="Test suite to use in testing mode.")]
    [Alias("suite")]
    [String]
    $s = "*"
,
    [Parameter(Mandatory=$False,HelpMessage="Test case to sue in testing mode.")]
    [Alias("case")]
    [String]
    $c = "*"
,
    [Parameter(Mandatory=$False,HelpMessage="Skips warning prompt.")]
    [AllowNull()]
    [Switch]
    $y = $True
,
    [Parameter(Mandatory=$False,HelpMessage="Skips creation or retrieve image process.")]
    [AllowNull()]
    [Switch]
    $skip_get_images = $True
,
    [Parameter(Mandatory=$False,HelpMessage="Skips warning prompt.")]
    [AllowNull()]
    [Switch]
    $skip_install = $True
)

if ( -Not "testing".Equals($Command) )
    {
        if($PsBoundParameters.ContainsKey('s'))
            {
                Write-Host "Test suite should only be specified in testing mode."
                Write-Host ".\tools\Run.ps1 -?"
                exit 1
            }
        if($PsBoundParameters.ContainsKey('c'))
            {
                Write-Host "Test case should only be specified in testing mode."
                Write-Host ".\tools\Run.ps1 -?"
                exit 1
            }
    }

$env:SKIP_GET_IMAGES=$skip_get_images
$env:SKIP_INSTALL=$skip_install

switch ($Command)
    {
        "all_in_one" { $env:DEPLOY_MODE="all-in-one" }
        { @("dns", "mr", "sdc", "aai", "mso", "robot", "vid", "sdnc", "portal", "dcae", "policy", "appc", "vfc", "multicloud", "ccsdk", "vnfsdk", "vvp", "openstack", "msb", "oom") -contains $_ } { $env:DEPLOY_MODE="individual" }
        "testing"
            {
                $env:DEPLOY_MODE="testing"
                If(-Not $y)
                    {
                        Write-Host "Warning: This test script will delete the contents of ../opt/ and ~/.m2."
                        $yn = Read-Host "Would you like to continue? [y]es/[n]o: "
                        switch ($yn)
                            {
                                { @("n", "N") -contains $_ }
                                    {
                                        Write-Host "Exiting."
                                        exit 0
                                    }
                            }
                    }
                $env:TEST_SUITE=$s
                $env:TEST_CASE=$c

                &cmd.exe /c rd /s /q .\opt\
                &cmd.exe /c rd /s /q $HOME\.m2\
             }
         default
             {
                Write-Output $"Usage: $0 {all_in_one|dns|mr|sdc|aai|mso|robot|vid|sdnc|portal|dcae|policy|appc|vfc|multicloud|ccsdk|vnfsdk|vvp|testing}"
                exit 1
             }
    }

vagrant destroy -f $Command
vagrant up $Command
