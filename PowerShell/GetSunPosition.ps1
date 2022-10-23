<#
.SYNOPSIS
    Gets the position (altitude, azimuth) in degrees of sun relative to given geolocation.
.DESCRIPTION
    Calculates the altitude and azimuth of sun position based on provided latitude and longtitude at current time.
    Optionally a specific date and time can be provided.
.PARAMETER Latitude
    Latitude of desired position in decimal degrees.
    Parameter is mandatory.
.PARAMETER Longtitude
    Latitude of desired position in decimal degrees.
    Parameter is mandatory.
.PARAMETER Date
    At date and time at which to calculate sun position.
    Parameter is optional.
.PARAMETER OutputRadians
    Specifies to output values as radians, not degress.
.PARAMETER OutputAsObject
    Specifies to output altitude and azimuth values as System.Object.
.INPUTS
    System.Decimal. Get-SunPosition can accept two decimal values that specify latitude and longtitude.
    System.DateTime. Can be provided to specify calculation date and time.
    System.Object. PSCustomObject that has Latitude and Longtitude properties can be provided as a pipeline value.
.OUTPUTS
    Text description of calculated sun position values or array of values.
.EXAMPLE
    Get-SunPosition 52.516227 13.377663
    Calculating sun position at Latitude: 52.516227, Longtitude: 13.377663, at date: 2022-10-23 17:20:08
    Altitude (deg): 12.0606868529465
    Azimuth (deg): 232.37296179594
.EXAMPLE
    Get-SunPosition 52.516227 13.377663 -Date "2022-10-19 16:30:00"
    Calculating sun position at Latitude: 52.516227, Longtitude: 13.377663, at date: 2022-10-19 16:30:00
    Altitude (deg): 18.9875059751445
    Azimuth (deg): 221.486847081189
.EXAMPLE
    Get-SunPosition 52.516227 13.377663 -Date "2022-10-19 16:30:00" -OutputRadians
    Calculating sun position at Latitude: 52.516227, Longtitude: 13.377663, at date: 2022-10-19 16:30:00
    Altitude (rad): 0.331394496008369
    Azimuth (rad): 0.724082077838147
.LINK
    https://www.aa.quae.nl/en/reken/zonpositie.html
#>
function Get-SunPosition
{
    [CmdletBinding(PositionalBinding = $true, SupportsPaging = $false)]
    Param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)][ValidateRange(-90.0, 90.0)][decimal]$Latitude,
        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)][ValidateRange(-180.0, 180.0)][decimal]$Longtitude,
        [Parameter(Position=2)][datetime]$Date = (Get-Date),
        [switch]$OutputRadians,
        [switch]$OutputAsObject
    )

    Process
    {
        if(-not $OutputAsObject)
        {
            Write-Host "Calculating sun position at Latitude: $($Latitude), Longtitude: $($Longtitude), at date: $($Date.ToString("yyyy-MM-dd HH:mm:ss"))" -ForegroundColor Yellow
        }

        # Simplified variables:
        $Math = [System.Math]
        $PI = $Math::PI
        $RAD = $PI / 180.

        # Astronomical constants:
        $theta0 = 280.1470 * $RAD # sidereal time 0
        $theta1 = 360.9856235 * $RAD # sidereal time 1
        $J2000 = 2451544.5
        $J1970 = 2440587.5
        $M0 = 357.5291 * $RAD # earth mean anomaly 0
        $M1 = 0.98560028 * $RAD # earth mean anomaly 1
        $C1 = 1.9148 * $RAD
        $C2 = 0.0200 * $RAD
        $C3 = 0.0003 * $RAD
        $P = 102.9373 * $RAD # perihelion (Π)
        $e = 23.4393 * $RAD # obliquity of the equator (ε)


        $PHI = $Latitude * $RAD
        $LW = (-$Longtitude) * $RAD

        $dateUnix = (New-TimeSpan -Start (Get-Date "1970-01-01") -End (Get-Date $Date).ToUniversalTime()).TotalSeconds
        
        $sInDay = 24 * 60 * 60
        $J = $dateUnix / $sInDay - 0.5 + $J1970 # Julian day number

        $M = $M0 + $M1 * ($J - $J2000) # solarMeanAnomaly
        $C = $C1 * $Math::Sin($M) + $C2 * $Math::Sin(2*$M) + $C3 * $Math::Sin(3*$M) # equation of center
        $lambda = $M + $P + $C + $PI # ecliptic longitude of the Sun, as seen from the planet
        $alpha = $Math::Atan2($Math::Sin($lambda) *  $Math::Cos($e), $Math::Cos($lambda)) # sun right ascension
        $delta = $Math::Asin($Math::Sin($lambda) * $Math::Sin($e)) # sun declination

        $theta = $theta0 + $theta1 * ($J - $J2000) - $LW # sidereal time

        $H = $theta - $alpha # hour angle

        $Altitude = $Math::Asin( $Math::Sin($PHI) * $Math::Sin($delta) + $Math::Cos($PHI) * $Math::Cos($delta) * $Math::Cos($H))
        $Azimuth = $Math::Atan2($Math::Sin($H), $Math::Cos($H) * $Math::Sin($PHI) - $Math::Tan($delta) * $Math::Cos($PHI))
        
        $postfix = "rad"
        if(-not $OutputRadians) 
        {
            $Altitude = $Altitude / $RAD
            $Azimuth = ($Azimuth / $RAD) + 180
            $postfix = "deg"
        }

        if($OutputAsObject)
        {
            New-Object -TypeName PSObject -Property @{Altitude = $Altitude; Azimuth = $Azimuth}
        }
        else
        {
            Write-Host "Altitude ($($postfix)): $($Altitude)" -ForegroundColor Green
            Write-Host "Azimuth ($($postfix)): $($Azimuth)" -ForegroundColor Green
        }
        
    }
}