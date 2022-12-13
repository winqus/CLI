#!/bin/bash

function HELP() {
    echo '
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
    .EXAMPLE
        bash GetSunPosition.sh
        Provide arguments: latitude longtitude [date]
        Choose: 
        1) Enter values
        2) Calculate position in degress
        3) Calculate position in radians
        4) Help
        5) Exit
        Choice: 
    .EXAMPLE
        bash GetSunPosition.sh 52.516227 13.377663
        13.3459 166.138
    .EXAMPLE
        bash GetSunPosition.sh 52.516227 13.377663 "2022-10-19 16:30:00 +0300"
        18.9875 221.487
    .LINK
        https://www.aa.quae.nl/en/reken/zonpositie.html
    '
}

PS3="Choice: "

function getSunPosition()
{
	echo '' | awk \
	-v Latitude="$1" \
	-v Longtitude="$2" \
	-v UnixDate="$3" \
	-v OutputDegrees="$4" \
	-f "getsunposition.awk"
}

function menu()
{
	local lat=""
 	local long=""
	local unixdate=""
	while true
	do
		echo "Choose: "
		options=("Enter values" "Sun position in degress" "Sun position in radians" "Help" "Exit")
		select option in "${options[@]}"; do
			echo -e
			case $REPLY in 
				1)	read -p "Latitude: " inputLat
						read -p "Longtitude: " inputLong
						read -p "Date: " inputDate
						if [ "$inputDate" == "" ]
						then
							inputDate=`echo $(date)`
						fi
						unixdate=`echo $(date --date="$inputDate" +"%s")`
						break;;
				2) 	echo -e "Calculated sun position at Latitude: $inputLat, Longtitude: $inputLong, at date: $(date --date="$inputDate")"
						getSunPosition $inputLat $inputLong $unixdate "true" | awk '{print "Altitude:", $1,"(deg)"; print "Azimuth:",$2,"(deg)"}'
						echo -e			
						break;;
				3) 	echo -e "Calculated sun position at Latitude: $inputLat, Longtitude: $inputLong, at date: $(date --date="$inputDate")"
						getSunPosition $inputLat $inputLong $unixdate "false" | awk '{print "Altitude:", $1,"(rad)"; print "Azimuth:",$2,"(rad)"}'
						echo -e
						break;;
				4) HELP; break;;
				5) exit;;
				*) echo "Wrong choice."; break;;
			esac
		done
	done
}
if [ $# -ge 2 ]
then
	unixdate="$(date +%s)"
	if [ "$3" ]
 	then
		unixdate=`echo $(date --date="$3" +"%s")`
	fi
	getSunPosition $1 $2 $unixdate "true"
else
	echo "Provide arguments: latitude longtitude [date]"
 	menu
	
fi
