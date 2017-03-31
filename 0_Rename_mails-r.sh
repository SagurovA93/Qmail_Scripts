#!/bin/bash
ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`
DATE=$(date +%d\ %b\ %y\ %H:%M:%S)
Time=$(date +%H:%M:%S)
folder_for_renamed_mails="$DIRECTORY/Renamed_mail"
#script_name="$( echo "$0" | sed s/"$0"//g )"
#echo $script_name
if [[ "$1" == '-r' ]]; then
		cd "$folder_for_renamed_mails"
		ls | while read name_of_mail; do
			name_of_mail_old="$( echo "$name_of_mail" | sed 's/.eml//g' )"
				mv "$folder_for_renamed_mails/$name_of_mail" "$DIRECTORY/$name_of_mail_old" 
			done		
	else
		if [ ! -e "$folder_for_renamed_mails" ]; then
			mkdir $folder_for_renamed_mails
		fi
			cd "$DIRECTORY"
			ls | while read name_of_mail; do
			if [[ "$name_of_mail" == '0_Rename_mails-r.sh' || "$name_of_mail" == 'Renamed_mail' || "$name_of_mail" == '0_Rename_mails.sh' ]]; then
				echo $name_of_mail > /dev/null
				else
				mv "$DIRECTORY/$name_of_mail" "$folder_for_renamed_mails/$name_of_mail.eml" 
			fi
			done		
fi
exit 0
