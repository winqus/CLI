function asin(x) { return atan2(x, sqrt(1-x*x)) }
function acos(x) { return atan2(sqrt(1-x*x), x) }
function atan(x) { return atan2(x,1) }
function tan(x) { return (sin(x) / cos(x)) }

BEGIN {
 	# Constants
	PI = atan2(0, -1)
	RAD = PI / 180
	theta0 = 280.1470 * RAD # sidereal time 0
	theta1 = 360.9856235 * RAD # sidereal time 1
	J2000 = 2451544.5
	J1970 = 2440587.5
	M0 = 357.5291 * RAD # earth mean anomaly 0
	M1 = 0.98560028 * RAD # earth mean anomaly 1
	C1 = 1.9148 * RAD
	C2 = 0.0200 * RAD
	C3 = 0.0003 * RAD
	P = 102.9373 * RAD # perihelion (Π)
	e = 23.4393 * RAD # obliquity of the equator (ε)

	altitude = 0
	azimuth = 0
}

function getSunPosition(lat, long, unixdate) 
{
	PHI = lat * RAD
	LW = (-long) * RAD

	sInDay = 24 * 60 * 60
	J = unixdate / sInDay - 0.5 + J1970 # Julian day number

	M = M0 + M1 * (J - J2000) # solarMeanAnomaly
	C = C1 * sin(M) + C2 * sin(2*M) + C3 * sin(3*M) # equation of center
	lambda = M + P + C + PI # ecliptic longitude of the Sun, as seen from the planet
	alpha = atan2(sin(lambda) * cos(e), cos(lambda)) # sun right ascension
	delta = asin(sin(lambda) * sin(e)) # sun declination

	theta = theta0 + theta1 * (J - J2000) - LW # sidereal time

	H = theta - alpha # hour angle

	altitude = asin( sin(PHI) * sin(delta) + cos(PHI) * cos(delta) * cos(H))
	azimuth = atan2(sin(H), cos(H) * sin(PHI) - tan(delta) * cos(PHI))
}

{
	getSunPosition(Latitude, Longtitude, UnixDate)

	if(OutputDegrees == "true")
	{
		altitude = altitude / RAD
		azimuth = (azimuth / RAD) + 180
	}

	print altitude, azimuth
}