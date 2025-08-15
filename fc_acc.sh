#! /bin/bash

LOG=rx_poc.log

#		here is how the log looks like

#1 year    month   day     obs_temp        fc_temp
#2 2025    08      12      +25             +25 C
#3 2025    08      13      +23             +24 C
#4 2025    08      14      +23             +29 C
#5 2025    08      15      +29             +29 C


nLines=$(wc -l < $LOG)

# we start from the third line, second day, since we can not provide
# accurace for the first day.
for((i=3; i<=$nLines; i++));do

	#today's line
	line=$(awk "NR==$i" $LOG) 
	#yesterday's line
	yLine=$( awk "NR==(($i-1))" $LOG )

	#From todays line we extraxt date and obs temp.
	year=$(echo $line | cut -d " " -f1)
	month=$(echo $line | cut -d " " -f2)
	day=$(echo $line | cut -d " " -f3)
	obs_t=$(echo $line | cut -d " " -f4)

	#From yesterdays line, we extract the fc temp.
	fc_t=$(echo $yLine | cut -d " " -f5)

	#Calculate the FC accuracy.
	accuracy=$(($fc_t - $obs_t))
	echo "$day, accuracy: $accuracy"

	#Assign accuracy lable.
	if [ $accuracy -ge -1 ] && [ $accuracy -le 1 ]
	then
		acc_range=excellent
	elif [ $accuracy -ge -2 ] && [ $accuracy -le 2 ]
	then
		acc_range=good
	elif [ $accuracy -ge -3 ] && [ $accuracy -le 3 ]
        then
                acc_range=fair
	else
		acc_range=poor
	fi
	echo "$acc_range"

	#Append result to the accuracy table.
	echo -e "$year\t$month\t$day\t$obs_t\t\t$fc_t\t$accuracy\t\t$acc_range" >> fc_acc.tsv
done

