#!/bin/bash 
ABSOLUTE_FILENAME=`readlink -e "$0"`
DIRECTORY=`dirname "$ABSOLUTE_FILENAME"`
path_to_archive="$DIRECTORY/err"
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
cd "$path_to_archive/$year"
#echo "$path_to_archive/$year"
#sleep 3
ls | while read month ; do #range months
	if [[ $do_cycle_month != 'yes' && $month_start_trigger != 'on' ]]; then
		month=$month_start
		#echo "месяц - $month - в цикле range months"
		month_start_trigger='on'
		else
		echo "месяц - $month"
	fi
	cd "$path_to_archive/$year/$month"
	#echo "$path_to_archive/$year/$month"
	#sleep 3
	ls | while read day; do #range day
		if [[ $do_cycle_day != 'yes' && $day_start_trigger != 'on' ]]; then
			day=$day_start
			echo "день - $day в цикле range day" 
			day_start_trigger='on'
			else
			echo "месяц/день - $month/$day"
		fi
		work_folder="$path_to_archive/$year/$month/$day"
		cd $work_folder
		#echo $work_folder
		#sleep 1
		#echo $work_folder
		grep 'goncharov' "$work_folder/TO_NEW.err" | grep -v 'cp' | awk '{print $4}' | awk -F '/' '{print $8}' | tr -d "\':" | sort -u >> "$work_folder/TO_goncharov.err"
		grep 'goncharov' "$work_folder/FROM_NEW.err" | grep -v 'cp' | awk '{print $4}' | awk -F '/' '{print $8}' | tr -d "\':" | sort -u >> "$work_folder/FROM_goncharov.err"
		grep 'goncharov' "$work_folder/CC_NEW.err" | grep -v 'cp' | awk '{print $4}' | awk -F '/' '{print $8}' | tr -d "\':" | sort -u >> "$work_folder/TO_goncharov.err"
		grep 'goncharov' "$work_folder/BCC_NEW.err" | grep -v 'cp' | awk '{print $4}' | awk -F '/' '{print $8}' | tr -d "\':" | sort -u >> "$work_folder/TO_goncharov.err"
		sort -u "$work_folder/TO_goncharov.err" > "$work_folder/TO_goncharov_sort.err"
		sort -u "$work_folder/FROM_goncharov.err" > "$work_folder/FROM_goncharov_sort.err"
		cat "$work_folder/TO_goncharov_sort.err"
		cat "$work_folder/FROM_goncharov_sort.err"
		#rm "$work_folder/BCC_NEW.err" "$work_folder/TO_NEW.err" "$work_folder/CC_NEW.err" "$work_folder/FROM_NEW.err"
		if [ ! -z "$work_folder/TO_goncharov.err" ]; then
			rm "$work_folder/TO_goncharov.err"
		fi
		if [ ! -z "$work_folder/FROM_goncharov.err" ]; then
			rm "$work_folder/FROM_goncharov.err"
		fi

		if [[ $do_cycle_day != 'yes' ]]; then
			if [[ $day_end == '!..!' || $day == $day_end  ]]; then
					break
			fi
		fi
	done # конец цикла дней
	if [[ $do_cycle_month != 'yes' ]]; then
		if [[ $month_end == '!..!' || $month == $month_end ]]; then
				break
		fi
	fi
done # конец цикла месяцев
exit 0