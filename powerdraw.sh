#/bin/bash
#file=$1
bin2hex() {
       echo "obase=10;ibase=2;$1"|bc
}
#this example is tranasfer the 2s complement to dec. which means you can only transfer the bitwise data to dec.
#if you want to use the hex directly, you should adjust the obase:16(hex)10(dec)2(binary) to your own bits in echo.
src=$1

exec < $src
while read file
do
		if  echo "$file" | grep -q "PSU"
		then
			echo $file >> $1_power.log
		else

			ip1=`echo $file | cut -d " " -f1`
			ip2=`echo $file | cut -d " " -f2`

			newip="$ip2$ip1"
			#echo "Hex: $newip "

			unsigned=` echo $newip | perl -ne 'printf "%016b\n", hex($_)'  `
			signed=` echo ${unsigned:0:5}`
			data=` echo  ${unsigned:5:11}`
			#echo "Total bit: $unsigned "
			#echo "signed: $signed"
			#echo "data: $data"

			tmpA=$(tr 01 10 <<< $signed)
			tmpB=$((2#$tmpA+1))
			#echo "obase=10; $tmpB" | bc
			signedValue=`echo "obase=10; $tmpB" | bc`
			signedBit=` echo ${tmpB:0:1}`
			signedResult=""

			if [ "$signedBit" -eq "1" ]
			then
				signedResult=`echo "2 $signedValue"| awk '{ print ($1^$2); }' `
			else
				signedValue=$(($signedValue*(-1)))
				signedResult=`echo "2 $signedValue"| awk '{ print ($1^$2); }' `
			fi

			#echo $signedResult


			data2Hex=` bin2hex $data`
			power=$(expr $data2Hex*$signedResult |bc)

			echo "Power:$power ">> $1_power.log

		fi
done
