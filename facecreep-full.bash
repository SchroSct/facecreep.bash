#!/bin/bash
if [[ -a /tmp/facecreep.pid ]]
then
   echo "Facecreep is already running, please wait until completion."
   exit 1
fi
touch /tmp/facecreep.pid
ua="Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
site="https://m.facebook.com"
directory=""
if cd "$directory"
then
   echo "Inside $directory"
else
   echo "Could not enter $directory"
   exit 1
fi
mapfile -t creds < <(cat facecreep.rc.txt)
email="${creds[0]}"
password="${creds[1]}"
target="${creds[2]}"
uname="${creds[3]}"

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
mapfile -t albums < <(callpage "${site}/${target}?v=photos" | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g')
mapfile -O 3 -t albums < <(callpage "${site}/${target}/photos?psm=default&startindex=3" | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g')
for album in "${albums[@]}"
do
   echo "${album}"
   mapfile -t photos < <(callpage "${site}${album}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep "photo.php" | sed -e 's/.*\/photo.php/\/photo.php/g')
   fphoto="${photos[3]}"
   mapfile -t urls < <(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
   fname=$(echo "${urls[3]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
   curld "${urls[3]}"
   nphoto=$(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   nname=""
   lname="${fname}"
   until [[ "${nname}" = "${fname}" ]] || [[ "${lname}" = "${nname}" ]]
   do
      mapfile -t urls < <(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
      lname="${nname}"
      nname=$(echo "${urls[3]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
      curld "${urls[3]}"
      nphoto=$(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   done
done
rm /tmp/facecreep.pid
