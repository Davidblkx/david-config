# ---------------------------------------------------
# Helper functions for powershell 7
# ---------------------------------------------------
# $__ROOT=(Get-Item $PSScriptRoot).ToString()

# Prints the redirected URL
Function Get-RedirectedUrl {

    add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [uri] $url,
        [Parameter(Position = 1)]
        [Microsoft.PowerShell.Commands.WebRequestSession] $session = $null
    )

    $request_url = $url
    $retry = $false

    do {
        try {
            $response = Invoke-WebRequest -Method Head -WebSession $session -Uri $request_url

            if ($null -ne $response.BaseResponse.RequestMessage.RequestUri) {
                $result = $response.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
            }

            $retry = $false
        }
        catch {
            if (($_.Exception.GetType() -match "HttpResponseException") -and
                ($_.Exception -match "302")) {
                $request_url = $_.Exception.Response.Headers.Location.AbsoluteUri
                $retry = $true
            }
            else {
                throw $_
            }
        }  
    } while ($retry)

    return $result
}

# returns OS name
Function Get-OSName {
    if ($IsWindows) { "win" }
    else { "linux" }
}

Function Update-Env {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}