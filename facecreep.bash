#!/bin/bash
email=""
password=""
target=""
ua="Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
site="https://m.facebook.com"
directory=""
uname=""
if cd "$directory"
then
   echo "Inside $directory"
else
   echo "Could not enter $directory"
   exit 1
fi
callpage()
{
curl -s -L -b facecreep.txt -A "$ua" "$1"
}
login(){
curl -s -L -c facecreep.txt -A "$ua" -d "email=${email}&pass=${password}" "https://m.facebook.com/login.php"
}
curld()
{
name=$(echo "$1" | sed -e 's/.*\///g' -e 's/\?.*//g')
if [ -e "$name" ]
then
echo "File $name already exists"
else
curl -L -b facecreep.txt -A "$ua" -o "${name}" "$1"
fi
}
if callpage "$site" | grep -q -i "$uname"
then
   echo "Already Logged In"
else
   login > /dev/null
fi
while true
do
   mapfile -t albums < <(callpage "${site}/${target}?v=photos" | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g')
   mapfile -O 3 -t albums < <(callpage "${site}/${target}/photos?psm=default&startindex=3" | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g')
   for album in "${albums[@]}"
   do
      echo "${album}"
      mapfile -t photos < <(callpage "${site}${album}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep "photo.php" | sed -e 's/.*\/photo.php/\/photo.php/g')
      for photo in "${photos[@]}"
      do
          mapfile -t urls < <(callpage "${site}${photo}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
          curld "${urls[1]}"
      done
   done
   let random=$RANDOM%360
   let sleepy=45+$random
   echo "sleeping $sleepy on $(date)"
   sleep $sleepy
done
