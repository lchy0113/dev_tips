RES=`cat /sys/kernel/debug/mmc2/mmc2:0001/ext_csd`
typea="${RES:536:2}";
typeb="${RES:538:2}";
typead=`echo "ibase=16; $typea"|bc`
typebd=`echo "ibase=16; $typeb"|bc`
echo "Type A percent: $((typead*10)) %"
echo "Type B percent: $((typebd*10)) %"


