param($DistinguishedName)

Restore-ADObject -Server $ComputerName -Credential $Domain -Identity $DistinguishedName