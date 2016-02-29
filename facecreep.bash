#!/bin/bash
email=""
password=""
target=""
ua="Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
site="https://m.facebook.com"
directory=""
if cd "$directory"
then
   echo "Inside $directory"
else
   echo "Could not enter $directory"
   break
fi
callpage()
{
curl -s -L -b /tmp/facecreep.txt -A "$ua" "$1"
}
login(){
curl -s -L -c /tmp/facecreep.txt -A "$ua" -d "email=${email}&pass=${password}" "https://m.facebook.com/login.php"
}
curld()
{
name=$(echo "$1" | sed -e 's/.*\///g' -e 's/\?.*//g')
if [ -s "$name" ]
then
echo "File $name already exists"
else
curl -L -b /tmp/facecreep.txt -A "$ua" -o "${name}" "$1"
fi
}
login > /dev/null
mapfile -t albums < <(callpage "${site}/${target}?v=photos" | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g')
mapfile -O 3 -t albums < <(callpage "${site}/${target}/photos?psm=default&startindex=3" | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g')
for album in "${albums[@]}"
do
   echo "${album}"
   mapfile -t photos < <(callpage "${site}${album}" | sed -e 's/href="/\n/g' | grep "photo.php" | sed -e 's/".*//g')
   fphoto="${photos[0]}"
   mapfile -t urls < <(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
   fname=$(echo "${urls[0]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
   curld "${urls[0]}"
   nphoto=$(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   nname=""
   lname="${fname}"
   until [[ "${nname}" = "${fname}" ]] || [[ "${lname}" = "${nname}" ]]
   do
      mapfile -t urls < <(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
      lname="${nname}"
      nname=$(echo "${urls[0]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
      curld "${urls[0]}"
      nphoto=$(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   done
done
