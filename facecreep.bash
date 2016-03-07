#!/bin/bash
mapfile -t creds < <(cat facecreep.rc.txt)
email="${creds[0]}"
password="${creds[1]}"
target="${creds[2]}"
ua="Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
site="https://m.facebook.com"
directory=""
uname="${creds[3]}"
if cd "$directory"
then
   echo "Inside $directory"
else
   echo "Could not enter $directory"
   break
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
while true
do
   if callpage "$site" | grep -q -i "$uname"
   then
      echo "Already Logged In"
   else
      login > /dev/null
   fi
   mapfile -t albums < <(callpage "${site}/${target}?v=photos" | sed -e 's/"/\n/g' -e 's/\\//g' | tee /tmp/albums.html | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g' | tee /tmp/albums.html)
   mapfile -O 3 -t albums < <(callpage "${site}/${target}/photos?psm=default&startindex=3" | sed -e 's/"/\n/g' -e 's/\\//g' | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g' | tee /tmp/albums2.html)
   for album in "${albums[@]}"
   do
      echo "${album}"
      mapfile -t photos < <(callpage "${site}${album}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep "photo.php" | sed -e 's/.*\/photo.php/\/photo.php/g' | tee /tmp/photos.html )
      for photo in "${photos[@]}"
      do
          mapfile -t urls < <(callpage "${site}${photo}" | sed -e 's/"/\n/g' -e 's/\\//g' |grep -A 3 init| grep -i n.jpg | sed -e 's/.*url(\&quot\;https/https/g' -e 's/\&quot\;).*//g' | tee /tmp/photo.html )
#          mapfile -t urls < <(callpage "${site}${photo}" | sed -e 's/"/\n/g' -e 's/\\//g' | tee /tmp/photo.html )
#          read nothing
          for i in "${urls[@]}"
          do
             curld "${i}"
          done
      done
   done
   let random=$RANDOM%360
   let sleepy=45+$random
   echo "sleeping $sleepy on $(date)"
   sleep $sleepy
done
