#!/bin/bash 
ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`
DATE=$(date +%d\ %b\ %y\ %H:%M:%S)
Time=$(date +%H:%M:%S)
#Файлик с ассоциациями мыльных адресов пользователей и их каталогов в /home/vmail
assign_file="/etc/qmail/users/assign"
#Переменная, содержащая 
work_folder='/home/vmail'
if [[ $1 == '-u' ]]; then
	user_mod=on
	exact_user=$2
	if [ -z "$2" ]; then
		user_mod=off
	fi
fi
echo "user_mod = $user_mod"
#echo $2

echo 'Введи имя группы и год через пробел:'
read group_name year

if [ ! -e "$DIRECTORY/Mail_Fail_log.csv" ]; then
	echo -e "Имя группы;Имя пользователя;Почтовый адрес;Папка maildir" > "$DIRECTORY/Mail_Fail_log.csv"
fi

#Эта функция используется ТОЛЬКО ДЛЯ ТЕСТОВ
function CREATE_STRUCTURE {
	echo 'Я функция создания папки пользователя'
	if [ ! -e "$work_folder/$user_folder" ]; then
		mkdir -p "$work_folder/$user_folder/.maildir/.INBOX.BACKUP.$group_name"
		chown qmail:vmail -R "$work_folder/$user_folder/.maildir"
		chmod u=rw,g=---,o=--- -R "$work_folder/$user_folder/.maildir"
	fi
}
function UNIQE_MAIL () {
	cd "$user_mailbox/.maildir/.INBOX.BACKUP.$group_name/cur"
	ls ./ > "$DIRECTORY/list_of_mail"
	amount_of_mails="$( cat $DIRECTORY/list_of_mail | wc -l )"
	echo "Количество писем: $amount_of_mails"
	for (( number_of_mail = 1; i <= $amount_of_mails; number_of_mail++ )); do
		number_of__next_mail=$(( $number_of_mail + 1 ))
		MAIL_CURRENT_NAME="$( cat -n $DIRECTORY/list_of_mail | sed -n "$number_of_mail p" | cut -f2 )"
		MAIL_NEXT_NAME="$( cat -n $DIRECTORY/list_of_mail | sed -n "$number_of__next_mail p" | cut -f2 )"
		DATE_MAIL_CURRENT="$( grep -m 1 '^Date: ' ./"$MAIL_CURRENT_NAME" )"
		DATE_MAIL_NEXT="$( grep -m 1 '^Date: ' ./"MAIL_NEXT_NAME" )"
		if [[ "$DATE_MAIL_CURRENT" == "$DATE_MAIL_NEXT" ]]; then
			echo "удаляю $MAIL_CURRENT_NAME"
			rm ./"$MAIL_CURRENT_NAME"
		fi
		if [[ "$number_of__next_mail" > "$amount_of_mails" ]]; then
			echo 'Удаление одинаковых писем закончено'
			break
		fi
	done
	rm "$DIRECTORY/list_of_mail"
	echo "Писем в директории $user_mailbox/.maildir/.INBOX.BACKUP.$group_name/cur осталось:"
	ls "$user_mailbox/.maildir/.INBOX.BACKUP.$group_name/cur" | wc -l
}

function COPY_AND_RENAME () {
	cp -rp "$work_folder/$group_name/.maildir/.INBOX.BACKUP.IN.$year/" "$user_mailbox/.maildir/.INBOX.BACKUP.$group_name"
	#cp -rp "$work_folder/$group_name/.maildir/.INBOX.BACKUP.IN.$year/"* "$work_folder/$user_folder/.maildir/.INBOX.BACKUP.$group_name"
	#chown qmail:vmail -R "$user_mailbox/.maildir/.INBOX.BACKUP.$group_name"
	#chmod u=rw,g=---,o=--- -R "$user_mailbox/.maildir/.INBOX.BACKUP.$group_name"
 	CHECK_inbox_group_name_year="$( grep -ac "INBOX.BACKUP.$group_name" "$user_mailbox/.maildir/subscriptions" )"
 	if [[ $CHECK_inbox_group_name_year == 0 ]]; then
 	 	echo "INBOX.BACKUP.$group_name" >> "$user_mailbox/.maildir/subscriptions"
		echo -e " " >> "$user_mailbox/.maildir/subscriptions"
 	fi
 	UNIQE_MAIL
 }
function FIND_USER () {
	cd "$work_folder/$group_name"
	string_counter=0
	while read user_mail_addr; do
		string_counter="$(( $string_counter + 1 ))"
		if [[ $string_counter == '1' ]]; then
			echo $line > /dev/null
			continue 
		fi
			user_name="$( echo $user_mail_addr | sed 's/@.*//g' )"
			#echo $user_name
			if [[ $user_mod == 'on' ]]; then
				if [[ "$user_name" != "$exact_user" ]]; then
					continue
				fi
			fi
			user_mailbox="$( grep -a "=$user_name:" $assign_file | tr -d '=' | awk -F ':' '{print $5}' )"
			user_folder="$( echo $user_mailbox | sed  's/\/home\/vmail\///g' )" #используется только в тестах!
			if [ -z $user_mailbox ]; then
				echo -e "$group_name;$user_name;$user_mail_addr;FAILURE: не найдена запись в assign файле" >> "$DIRECTORY/Mail_Fail_log.csv"
				continue
			fi
			if [[ $user_name == 'goncharov-a' ]]; then
				echo -e 'goncharov-a\n'
				user_mailbox='/home/vmail/goncharov-a'
			fi
			COPPY_AND_RENAME
			#echo -e "$user_mailbox\\n$user_folder"

	done < "$work_folder/$group_name/.qmail"
 }
FIND_USER
exit 0