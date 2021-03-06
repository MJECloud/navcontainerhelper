﻿Describe 'Bacpac' {

    It 'Backup-NavContainerDatabases' {

        $bakFolder = "C:\programdata\NavContainerHelper\mybak"
        $bakFile = "$bakFolder\database.bak"
        Backup-NavContainerDatabases -containerName $navContainerName `
                                     -sqlCredential $credential `
                                     -bakFolder $bakFolder

        $bakFile | Should -Exist
                
        $testContainerName = "$($navContainerName)2"
        New-NavContainer -accept_eula `
                         -accept_outdated `
                         -imageName $navImageName `
                         -containerName $testContainerName `
                         -auth "NavUserPassword" `
                         -Credential $Credential `
                         -updateHosts `
                         -bakFile $bakFile

        Remove-NavContainer $testContainerName
        Remove-Item -Path $bakFolder -Recurse -Force
    }
    It 'Export-NavContainerDatabasesAsBacpac' {

        $bacpacFolder = "C:\programdata\NavContainerHelper\bacpac"
        $bacpacFile = "$bacpacFolder\database.bacpac"
        Export-NavContainerDatabasesAsBacpac -containerName $bcContainerName -sqlCredential $credential -bacpacFolder $bacpacFolder

        $bacpacFile | Should -Exist

        Remove-Item -Path $bacpacFolder -Recurse -Force
    }
    It 'Export-NavContainerDatabasesAsBacpac (multitenant)' {

        $testContainerName = "$($bcContainerName)2"
        New-NavContainer -accept_eula `
                         -accept_outdated `
                         -imageName $bcImageName `
                         -containerName $testContainerName `
                         -auth "NavUserPassword" `
                         -Credential $Credential `
                         -updateHosts `
                         -multitenant

        $bacpacFolder = "C:\programdata\NavContainerHelper\bacpac"
        $appBacpacFile = "$bacpacFolder\app.bacpac"
        $tenant = "default"
        $tenantBacpacFile = "$bacpacFolder\$tenant.bacpac"
        Export-NavContainerDatabasesAsBacpac -containerName $testContainerName -sqlCredential $credential -bacpacFolder $bacpacFolder -tenant $tenant

        $appBacpacFile | Should -Exist
        $tenantBacpacFile | Should -Exist

        New-NavContainer -accept_eula `
                         -accept_outdated `
                         -imageName $bcImageName `
                         -containerName $testContainerName `
                         -auth "NavUserPassword" `
                         -Credential $Credential `
                         -updateHosts `
                         -additionalParameters @("--env appBacpac=$appBacpacFile","--env tenantBacpac=$tenantBacpacFile")

        New-NavContainerTenant -containerName $testContainerName -tenantId "test"

        (Get-NavContainerTenants -containerName $testContainerName).Count | Should -be 2

        Remove-NavContainer $testContainerName
        Remove-Item -Path $bacpacFolder -Recurse -Force
    }
}
