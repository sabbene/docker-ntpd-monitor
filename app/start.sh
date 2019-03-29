if [ ! -e /html/ntpd/ ]
then
  mkdir /html/ntpd
fi

while true;
do
  /app/ntp-check.pl $id> /html/ntpd/index.html
  sleep 900;
done
