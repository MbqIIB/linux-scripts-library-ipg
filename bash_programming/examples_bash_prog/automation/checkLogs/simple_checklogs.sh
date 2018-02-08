#!/bin/bash

set -o errexit
set -o nounset

iopt=""
vopt=""
readonly installationPath="/usr/bin" # while filename will be fetch with $0
tecreset=$(tput sgr0) # resetting shell format output arguments
readonly logsFolder="/var/log"
token="true"
numberErrors=0

# list of main logs for both Red Hat and Debian systems
arrayLogsRedHat=(messages secure boot.log dmesg kern.log faillog cron yum.log mail.log httpd mysql.log)
arrayLogsDebian=(syslog auth.log boot.log dmesg kern.log faillog cron dpkg.log mail.log httpd mysql.log)

# printing each element in the array, listing all possible options for Red Hat logs (10 logs):
function listingRedHatLogs()
{
	echo -e '\E[32m'"List of Red Hat system logs available to check: $tecreset"
	echo ""
	for i in {0..9}
	do
		echo "Select option $i for: ${arrayLogsRedHat[$i]}"
		echo ""
	done
}

# printing each element in the array, listing all possible options for Red Hat logs (10 logs):
function listingDebianLogs()
{
        echo -e '\E[32m'"List of Debian system logs available to check: $tecreset"
        for i in {0..9}
        do
          	echo "Select option $i for: ${arrayLogsDebian[$i]}"
                echo ""
        done
}

# evaluating wheter the script is called with an argument for -i install or -v version-check
while getopts iv name
do
  	case $name in
          i)iopt=1;;
          v)vopt=1;;
          *)echo -e '\e[31;22m'"Invalid argument, please type -i for installing the script, or -v for checking version number. $tecreset";;
        esac
done

# in case the while loop case $name for argument contains i (iopt var created), then start installation
if [[ ! -z $iopt ]]
then
{
wd=$(pwd)
# test -L "$0" --> command:test tests whether symblink for script filename $0 (called by user) exists, if not the case, filename is moved to /tmp
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
# create as root su -c the binary for execution in case it does not exist / not installed yet:
if [[ -e $installationPath/checklogs ]]
then
	echo -e '\E[32m'"Script already installed, run it with command: checklogs $tecreset"
	exit 0
else
	su -c "cp $scriptname $installationPath/checklogs" root && echo -e '\E[32m'"Congratulations! Script installed, now run it with command: checklogs $tecreset" || echo 2&>1 | tee '/tmp/checklogs_$$.log'
fi
}
fi

if [[ ! -z $vopt ]]
then
{
echo -e '\E[32m'"checklogs version 1.0\nDesigned by IPG\nReleased Under GNU License $tecreset"
}
fi

# if no arguments had been passed when calling this script, then it means execution will follow:
if [[ $# -eq 0 ]]
then
{
# check whether the system is a Red Hat or a Debian distro: logs are different in some cases (see arrays for complete list)
# if exists a main config file redhat-release in etc: red hat, if exists file debian_version in etc as well then Debian system:
if [[ -f /etc/redhat-release ]]
then
	# user input via prompt for option selection / log to check:
	while [[ $token == "true" ]]
	do
		listingRedHatLogs
		tokenAgain="true"
		read -p "Please select log option number: " logOption
		case "$logOption" in
		[0-9])
			logSelected="${arrayLogsRedHat[$logOption]}"
			echo -e '\E[32m'"The log selected is: $logSelected $tecreset"
			printf -v int numberErrors=$(cat $logsFolder/$logSelected | grep -ci 'error')
			echo -e '\e[31;22m'"Number of errors in $logSelected: $numberErrors $tecreset"
			if [[ $numberErrors -gt 0 ]]
			then
				echo -e '\e[31;22m'"Listing up to last 3 lines of the log file $logSelected with error: $tecreset"
				echo ""
				cat $logsFolder/$logSelected | grep -i 'error' | tail -n 3
				echo ""
			else
				echo -e '\E[32m'"No errors in the log file $logSelected, listing last three lines: $tecreset"
				cat $logsFolder/$logSelected | tail -n 3
				echo ""
			fi

			while [[ $tokenAgain == "true" ]]
			do
				read -p "Type l for listing again the log options, of q for exiting script: " nextOption
				case "$nextOption" in
				l)
					echo "You have chosen to check more logs ..."
					tokenAgain="false"
					;;
				q)
					tokenAgain="false"
					token="false"
					exit 0
					;;
				*)
					echo -e '\e[31;22m'"Wrong option ... $tecreset"
					;;
				esac
			done
			;;
		q)
			echo "Exiting script ..."
			exit 0
			;;
		*)
			echo -e '\e[31;22m'"Wrong option, please select a value from 0-9 or q to quit: $tecreset"
			;;
		esac
	done
elif [[ -f /etc/debian_version ]]
then
	# commands for checking Debian logs
	echo "Debian"
fi
}
fi
