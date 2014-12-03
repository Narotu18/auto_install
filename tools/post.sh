#!/bin/bash
ip=`facter ipaddress`
mem=`facter memorysize`
cpu=`facter processor0`
inc=`facter manufacturer`
sn=`facter serialnumber`
echo $inc |grep "HP" >/dev/null
code=$?
if [ $code -ne 0 ];then 
	sotl=`/opt/MegaRAID/MegaCli/MegaCli64  -pdlist -aall |grep "Enclosure Device ID"|awk '{print $NF}'|uniq`
	disk=`/opt/MegaRAID/MegaCli/MegaCli64  -pdlist -aall |grep  "Slot Number\|Raw Size"|awk '{print $3$4}'|awk 'NR%2==1{T=$0;next}{print "\""T"\""":""\""$0"\""","}'|sed '$s/,//'`
else
	sotl=`hpacucli  ctrl all show  |awk '{print $6}'`
	disk=`hpacucli  ctrl  slot=0  pd all show|awk '{print "\""$2"\"","@","\""$8$9"\"" ","}'|grep ':'|sed -e 's/,//' -e 's/@/:/'|sed '$s/,//'`
fi
ilo_ip=`ipmitool  lan print |grep  'IP Address [^Source]' |awk '{print $4}'`
echo '{' > info.json
echo "\"ip\":\"$ip\",">>info.json
echo "\"ilo_ip\":\"$ilo_ip\",">>info.json
echo "\"mem\":\"$mem\",">>info.json
echo "\"cpu\":\"$cpu\",">>info.json
echo "\"sn\":\"$sn\",">>info.json
echo "\"inc\":\"$inc\",">>info.json
echo "\"sotl\":\"$sotl\",">>info.json
echo '"disk":' >>info.json
echo '{' >> info.json
echo $disk >>info.json
echo '}' >>info.json
echo '}' >>info.json

curl -X POST  -H 'content-type:application/json' -d @info.json   10.58.241.31:8080/post/
