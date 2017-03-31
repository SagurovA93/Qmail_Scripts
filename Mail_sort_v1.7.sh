#!/bin/bash
#######################################################
# ЗАПУСК С КЛЮЧОМ -u [имя пользователя]				  #
#######################################################

ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`
DATE=$(date +%d\ %b\ %y\ %H:%M:%S)
Time=$(date +%H:%M:%S)
assign_file="/etc/qmail/users/assign"
UNKNOWN_USER_FOLDER="$DIRECTORY/err/Unknown_user" #Папка для обработки логов по неопредляющимся пользователям
if [ ! -e "$DIRECTORY/err/Unknown_user" ]; then 
	mkdir -p "$DIRECTORY/err/Unknown_user"
fi
if [ -z "$UNKNOWN_USER_FOLDER/errors.csv" ]; then
	echo 'Пользователь;Входящее/Исходящее;Год;Месяц;День;Полный путь;' > "$UNKNOWN_USER_FOLDER/errors.csv"
fi
if [[ $1 == '-u' ]]; then
	user_mod=on
	USER_NAME=$2
	mkdir -p "$DIRECTORY/err/$USER_NAME"
	echo -e 'Пользователь;Входящее/Исходящее;Год;Месяц;День;Имя письма;Полный путь;' > "$DIRECTORY/err/$USER_NAME/copied_leeters.csv"  
fi

echo 'Введи год'
read year 
echo 'Введи месяц'
read month_exactly
	if [ -z $month_exactly ]; then
		do_cycle_month='yes'
	else
		month_start="$( echo $month_exactly | awk -F '-' '{print $1}' | tr -d ' ' )"
		month_end="$( echo $month_exactly | awk -F '-' '{print $2}' | tr -d ' ' )"
		if [ -z $month_end ]; then
			month_end='!..!'
		fi
	fi
echo 'Введи день'
read day_exactly
	if [ -z $day_exactly ]; then
		do_cycle_day='yes'
	else
		day_start="$( echo $day_exactly | awk -F '-' '{print $1}' | tr -d ' ' )"
		day_end="$( echo $day_exactly | awk -F '-' '{print $2}' | tr -d ' ' )"
		if [ -z $day_exactly ]; then
			day_exactly='!..!'
		fi
	fi
#echo $DATE > "$log_folder/Mail_sort_log.txt"
#exec 2>>"$DIRECTORY/Mail_sort.err"

COUNTER_user_letter=0
COUNTER_incoming_letter=0
COUNTER_coming_letter=0
#COUNTER_amount_of_users_global=0

#Функция создания структуры
function CREATE_STRUCTURE () {
	#Получаю имя пользователя
	user_name="$( echo ${ADDRESS[$addr_list_counter]} | sed "s/@.*//g" )"
	if [[ $user_name == 'goncharov-a' ]]; then
		user_name='goncharov-a'
		echo "user_name='goncharov-a'"
		else
		user_name_alias="$( cat "$assign_file" | grep -a "=$user_name:" | tr -d '=' | awk -F ':' '{print $5}' | sed 's/\/home\/vmail\///g' )"
		if [ -z $user_name_alias ]; then #имя пользователя - пустое
 			echo 'Адресата нет в файле assign'
 			DO_COPY_LETTER='NO'
 			if [[ $file_TO != "$work_folder/FROM_NEW" ]]; then
				type_of_letter='Входящее'
				else
				type_of_letter='Исходящее'
			fi
			echo -e "$user_name;$type_of_letter;$year;$month;$day;$work_folder/$letter_name;" >> "$UNKNOWN_USER_FOLDER/errors.csv"
		fi
		user_name="$user_name_alias"
		echo "Адресат $user_name = $user_name_alias Пользователь"
	fi
if [[ "$DO_COPY_LETTER" != 'NO' ]]; then
	if [ -e "$structure_folder/$user_name/.maildir" ]; then
	# Папка есть 
	#structure_folder="/home/vmail/имя_пользователя/.maildir"
	#echo "$structure_folder/$user_name/.maildir"
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP" ]; then
			cp -r '/root/scripts/for_backup/.INBOX.BACKUP' "$structure_folder/$user_name/.maildir/"	
			chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN" ]; then
			cp -r '/root/scripts/for_backup/.INBOX.BACKUP.IN' "$structure_folder/$user_name/.maildir/"
			chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT" ]; then
			cp -r '/root/scripts/for_backup/.INBOX.BACKUP.OUT' "$structure_folder/$user_name/.maildir/"
			chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT"
		fi 
		#################################Добавил папки по годам####################################
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2014" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.IN.2014' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2014"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2015" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.IN.2015' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2015"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2016" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.IN.2016' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2016"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2017" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.IN.2017' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.2017"
		fi
		######################
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2014" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.OUT.2014' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2014"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2015" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.OUT.2015' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2015"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2016" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.OUT.2016' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2016"
		fi
		if [ ! -e "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2017" ]; then
		cp -r '/root/scripts/for_backup/.INBOX.BACKUP.OUT.2017' "$structure_folder/$user_name/.maildir/"
		chown qmail:vmail -R "$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.2017"
		fi
		######################################################
		if [ -e "$structure_folder/$user_name/.maildir/subscriptions" ]; then
		CHEK_inbox_backup="$( grep -ac 'INBOX.BACKUP' "$structure_folder/$user_name/.maildir/subscriptions" )"
		fi
		if [[ "$CHEK_inbox_backup" == 0 ]]; then
			echo 'INBOX.BACKUP' >> "$structure_folder/$user_name/.maildir/subscriptions"		
		fi
		CHEK_inbox_backup_in="$( grep -ac 'INBOX.BACKUP.IN' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
			echo 'INBOX.BACKUP.IN' >> "$structure_folder/$user_name/.maildir/subscriptions"		
		fi
		CHEK_inbox_backup_out="$( grep -ac 'INBOX.BACKUP.OUT' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_out" == 0 ]]; then
			echo -e "INBOX.BACKUP.OUT" >> "$structure_folder/$user_name/.maildir/subscriptions"		
		fi
		####################################################Добавил записи по годам#####################################################
		CHEK_inbox_backup_in="$( grep -ac 'INBOX.BACKUP.IN.2014' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.IN.2014' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		CHEK_inbox_backup_in="$( grep -ac 'INBOX.BACKUP.IN.2015' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.IN.2015' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		CHEK_inbox_backup_in="$( grep -ac 'INBOX.BACKUP.IN.2016' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.IN.2016' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		CHEK_inbox_backup_in="$( grep -ac 'INBOX.BACKUP.IN.2017' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.IN.2017' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		################################################################################
		CHEK_inbox_backup_out="$( grep -ac 'INBOX.BACKUP.OUT.2014' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.OUT.2014' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		CHEK_inbox_backup_out="$( grep -ac 'INBOX.BACKUP.OUT.2015' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.OUT.2015' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		CHEK_inbox_backup_out="$( grep -ac 'INBOX.BACKUP.OUT.2016' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.OUT.2016' >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi
		CHEK_inbox_backup_out="$( grep -ac 'INBOX.BACKUP.OUT.2017' "$structure_folder/$user_name/.maildir/subscriptions" )"
		if [[ "$CHEK_inbox_backup_in" == 0 ]]; then
		echo 'INBOX.BACKUP.OUT.2017' >> "$structure_folder/$user_name/.maildir/subscriptions"
		echo -e " " >> "$structure_folder/$user_name/.maildir/subscriptions"
		fi	
	fi
fi
	if [[ $file_TO != $work_folder/FROM_NEW ]]; then
			#Входящие
			INBOX_folder="$structure_folder/$user_name/.maildir/.INBOX.BACKUP.IN.$year/cur"
			INBOX_folder_macakov-d="$structure_folder/macakov-d/.maildir/.INBOX.BACKUP.IN.$year/cur"
		else
			#Исходящие
			INBOX_folder="$structure_folder/$user_name/.maildir/.INBOX.BACKUP.OUT.$year/cur"
			INBOX_folder_macakov-d="$structure_folder/macakov-d/.maildir/.INBOX.BACKUP.OUT.$year/cur"
	fi
	#echo $INBOX_folder
	}
#Функция копирования письма
function COPY_LETTER () {
if [[ "$DO_COPY_LETTER" != 'NO' ]]; then #Триггер на киопирование,некопирование письма
#В этой строке получаем имя письма
	letter_name="$( echo $filNAME_TO | tr -d ' ' )" #| tr -d ' ' 
	#echo $letter_name
	#sleep 3
	#exit 0
	#echo -e "${ADDRESS[$addr_list_counter]}\\n"
	is_there_file='no'
	COUNTER_while=0
	while [[ $is_there_file == 'no' ]]; do
		COUNTER_while="$(( $COUNTER_while + 1 ))"
		if [[ $COUNTER_while == 20 ]]; then
			echo "Пытаюсь найти файл (20-ая попытка $Time ):"
			echo "$work_folder/$letter_name"
		fi
		if [ -e $work_folder/$letter_name ]; then
			is_there_file=yes
			cp "$work_folder/$letter_name" "$INBOX_folder/$letter_name"
			wait
			if [[ $user_name == 'goncharov-a' ]]; then
				cp "$work_folder/$letter_name" "$INBOX_folder_macakov-d/$letter_name"
				chown qmail:vmail "$INBOX_folder_macakov-d/$letter_name"
				chmod u=rw,g=---,o=--- "$INBOX_folder/$letter_name"
				wait
			fi
			chown qmail:vmail "$INBOX_folder/$letter_name"
			wait
			chmod u=rw,g=---,o=--- "$INBOX_folder/$letter_name"
			#chmod g-rwx "$INBOX_folder/$letter_name"
			#chmod o-rwx "$INBOX_folder/$letter_name"
			#chmod u+rw "$INBOX_folder/$letter_name"
			else
			is_there_file=no
		fi
	done
			#file_TO="$work_folder/TO_NEW"
			if [[ $file_TO != "$work_folder/FROM_NEW" ]]; then
				type_of_letter='Входящее'
				else
				type_of_letter='Исходящее'
			fi
			#echo $file_TO
			#echo -e "$user_name;$type_of_letter;$year;$month;$day;$letter_name;$work_folder/$letter_name;" >> "$DIRECTORY/err/$user_name/copied_leeters.csv"
fi
} 

function DO () {
	#Разбираю файл НА Входящие
	# посимвольно смотрю файл file_TO
	amount_of_strings=$(sed -n '$=' $file_TO )
	#echo $amount_of_strings
	#sleep 5
	for (( counter_str = 1; counter_str <= $amount_of_strings; counter_str ++ )); do
		#sleep 0.3
		filNAME_TO="$( sed -n "$counter_str p" $file_TO | awk -F '|' '{print $1}' )" #awk -F '|' '{print $1}' #имя файла
		#echo $filNAME_TO
		#exit 0
		string_ADDRESS="$( sed -n "$counter_str p" $file_TO | awk -F '|' '{$1="";print $0}' )"
		#echo "$string_ADDRESS"
		#echo "string_ADDRESS = $string_ADDRESS"
		count_address=0
		#echo "СЧЕТЧИК адресов $count_address"
		length="$(echo $string_ADDRESS | awk '{print length}')"
		length=$(( $length + 3 ))
		#echo "Длина строки $length"
		for (( j = 0; j <= $length; j++ )); do
			#echo "j = $j"
			#echo "length = $length"
			#echo "$string_ADDRESS"
			letter[$j]=${string_ADDRESS:$j:1}
			#echo ${letter[$j]}
			let k=$j-1
				#echo ${letter[$j]}
			if [[ ${string_ADDRESS:$j:1} == '<' ]]; then
				trigger=on
				let count_address=$count_address+1
				#echo "СЧЕТЧИК адресов $count_address"
			fi
			if [[ ${string_ADDRESS:$j:1} == '>' ]]; then
				trigger=off
				ADDRESS[$count_address]="${address[$k]}"
				#echo "Строка на обработку - $string_ADDRESS "
				#echo $trigger
				#echo "СЧЕТЧИК адресов $count_address"
				#echo -e "АДРЕС ${ADDRESS[$count_address]}\\t"
			fi
				#echo $trigger
			if [[ $trigger == on ]]; then
			if [[ $j != 0 ]]; then
				#echo ${string_ADDRESS:$j:1}
				address[$j]="${address[$k]}${letter[$j]}"
				#echo ${address[$j]}
				#echo ${string_ADDRESSddress[$j]}
			fi
			fi
			#sleep 1
		done
		#Обязательно обнуляем массив, иначе все будет писаться поверх друг-друга.
		
		unset address
		unset trigger
		#echo 'ВЫХОЖУ ИЗ ЦИКЛА J!'
		#sleep 1
		#echo -e "\\n $string_ADDRESS"
		for (( addr_list_counter = 1; addr_list_counter <= $count_address ; addr_list_counter++ )); do
		#echo "ВХОЖУ В ЦИКЛ АДРЕСОВ!"
			#echo "${ADDRESS[$addr_list_counter]}"
			ADDRESS[$addr_list_counter]="$( echo ${ADDRESS[$addr_list_counter]} | tr -d '<' | tr '[:upper:]' '[:lower:]' )"
			#echo "${ADDRESS[$addr_list_counter]}"
			#exit 0
			CHECK_aliter="$(echo ${ADDRESS[$addr_list_counter]} | grep -aci 'aliter')" # Переменная определяет содержит ли адрес префикс содержащий слово aliter
			if [[ $CHECK_aliter != 0 ]]; then #Если адрес содержит префикс aliter, переменная CHECK_aliter НЕ равна 0
				if [[ $user_mod == 'on' ]]; then #Если включен режим для конкретного пользователя 
						CHECK_user="$(echo ${ADDRESS[$addr_list_counter]} | grep -aci "$USER_NAME" )" # Определяем для кого предназначено письмо
						if [[ $CHECK_user != 0 ]]; then # Если письмо для нужного пользователя, то: создаем папку, копируем письмо, если нет - ничего не делаем.
								CREATE_STRUCTURE
								COPY_LETTER
								#echo -e "${ADDRESS[$addr_list_counter]}\\n"
								COUNTER_user_letter="$(( $COUNTER_user_letter + 1 ))"
							if [[ $file_TO != "$work_folder/FROM_NEW" ]]; then
								COUNTER_coming_letter="$(( $COUNTER_coming_letter + 1 ))"
								else
								COUNTER_incoming_letter="$(( $COUNTER_incoming_letter + 1 ))"
							fi
						fi
					else #Режим для конкретного пользователя выключен
						CREATE_STRUCTURE # Создаем папку, копируем письмо
						COPY_LETTER #Создаем папку, копируем письмо
						if [[ $file_TO != "$work_folder/FROM_NEW" ]]; then
								COUNTER_coming_letter="$(( $COUNTER_coming_letter + 1 ))"
							else
								COUNTER_incoming_letter="$(( $COUNTER_incoming_letter + 1 ))"
						fi
						echo -e "$user_name\\tписьмо - $letter_name"
						#echo -e "АДРЕС - ${ADDRESS[$addr_list_counter]}\\n"
						#exit 0
				fi
				
			else
				echo -e "Адрес не принадлежит нам ${ADDRESS[$addr_list_counter]}" # >> "$DIRECTORY/Mail_sort_log.txt"
				#sleep 5
				#echo "ИМЯ ПОЛЬЗОВАТЕЛЯ - $user_name"

				#echo 'a' > /dev/null
			fi
			#echo "обнуляю ADDRESS[$addr_list_counter]"
			unset ADDRESS[$addr_list_counter]
			#echo "обнуляю $user_name"
			unset user_name
			#sleep 5
		done
		#sleep 1
		echo "Обработано писем: $counter_str из $amount_of_strings из файла $file_TO"
	done

}
#structure_folder="/home/vmail/имя_пользователя/.maildir"
#folder='/root/scripts/.INBOX.backup' #Указана папка, которая будет создана для входящих писем в директории пользователя
#log_folder=/home/sad/mail_log #Папка для лог файлов
#mkdir -p $log_folder/$year/
structure_folder='/home/vmail' #Указан корневой каталог,куда будут распределяться письма
path_to_archive='/mnt/sde1/archive-2015-/from-qmail'
#path_to_archive='/home/sad/err' - ЭТО ДЛЯ ТЕСТОВ!
cd $path_to_archive/$year/ #/mnt/sde1/archive-2015-/from-qmail/$year/
ls | while read month; do
	if [[ "$month" < "$month_start" ]]; then
		continue
	fi
	if [[ $do_cycle_month != 'yes' ]]; then
		if [[ $month_start_trigger != 'on'  ]]; then
				month=$month_start
				#echo "месяц - $month - в цикле range months"
				month_start_trigger='on'
			else
				echo "месяц - $month" 
		fi
	fi
	cd $path_to_archive/$year/$month #/mnt/sde1/archive-2015-/from-qmail/$year/$month
	ls | while read day; do
			if [[ "$day" < "$day_start" ]]; then
			continue
			fi
		if [[ $do_cycle_day != 'yes' ]]; then
			if [[ $day_start_trigger != 'on' ]]; then
					day=$day_start
					#echo "день - $day в цикле range day" 
					day_start_trigger='on'
				else
					echo "день - $day" 
			fi
			
		fi
		#echo "месяц - $month"
		#echo "день - $day"
		mkdir -p "$DIRECTORY/err/$year/02/$day/"
		#sleep 5
		work_folder="$path_to_archive/$year/$month/$day"
		cd $work_folder
		echo "$work_folder"
		#sleep 3
		file_TO="$work_folder/TO_NEW"
		if [[ $user_mod == 'on' ]]; then
			mkdir -p "$DIRECTORY/err/$USER_NAME/"
			error_path="$DIRECTORY/err/$USER_NAME/TO_NEW.err"
			else
			error_path="$DIRECTORY/err/$year/02/$day/TO_NEW.err"
		fi 
		exec 2>>"$error_path"
		DO
		#sleep 5
		#exit 0
		file_TO="$work_folder/CC_NEW"
		if [[ $user_mod == 'on' ]]; then
			mkdir -p "$DIRECTORY/err/$USER_NAME/"
			error_path="$DIRECTORY/err/$USER_NAME/CC_NEW_.err"
			else
			error_path="$DIRECTORY/err/$year/02/$day/CC_NEW.err"
		fi 
		exec 2>>"$error_path"
		DO
		#sleep 5
		file_TO="$work_folder/BCC_NEW"
		echo "Начинаю обработку $file_TO" >> "$log_folder/$year/log_$month_$day.txt"
		if [[ $user_mod == 'on' ]]; then
			mkdir -p "$DIRECTORY/err/$USER_NAME/"
			error_path="$DIRECTORY/err/$USER_NAME/BCC_NEW.err"
			else
			error_path="$DIRECTORY/err/$year/02/$day/BCC_NEW.err"
		fi 
		exec 2>>"$error_path"
		DO
		#sleep 5
		file_TO="$work_folder/FROM_NEW"
		echo "Начинаю обработку $file_TO" >> "$log_folder/$year/log_$month_$day.txt"
		if [[ $user_mod == 'on' ]]; then
			mkdir -p "$DIRECTORY/err/$USER_NAME/"
			error_path="$DIRECTORY/err/$USER_NAME/FROM_NEW.err"
			else
			error_path="$DIRECTORY/err/$year/02/$day/FROM_NEW.err"
		fi 
		exec 2>>"$error_path"
		DO
		#sleep 5
		if [[ $user_mod == 'on' ]]; then
		echo -e "Количество обработаных писем для пользователя $USER_NAME:\\n$COUNTER_user_letter"
		echo -e "Из них входящих: $COUNTER_coming_letter\\nИсходящих: $COUNTER_incoming_letter"
			else
		echo -e "Количество входящих писем: $COUNTER_coming_letter\\nКоличество исходящих писем: $COUNTER_incoming_letter\\n" 
		fi
		#exit 0
		if [[ $do_cycle_day != 'yes' ]]; then
			if [[ $day_end == '!..!' || $day == $day_end  ]]; then
					break
			fi
		fi
	done
	#exit 0 - Вот из-за этого exit'a он не получал следующий месяц
	if [[ $do_cycle_month != 'yes' ]]; then
		if [[ $month_end == '!..!' || $month == $month_end ]]; then
				break
		fi
	fi
done
exit 0