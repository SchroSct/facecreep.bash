#!/bin/bash
lockdir="/tmp/facecreep.lock/"
if mkdir "$lockdir"
then
   echo "Lock created, running $0"
else
   echo "facecreep is already running, please wait until completion."
   exit 1
fi
ua="Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
site="https://m.facebook.com"
if ! read directory < ~/.config/facecreep.rc
then
   echo ".config/facecreep.rc not set"
   rmdir "$lockdir"
   exit 1
fi
   if cd "$directory"
   then
      echo "Inside $directory"
   else
      echo "Could not enter $directory"
      rmdir "$lockdir"
      exit 1
   fi
mapfile -t creds < <(cat facecreep.rc.txt)
mapfile -t targets < <(cat facecreep.list.txt)
email="${creds[0]}"
password="${creds[1]}"
uname="${creds[2]}"
callpage()
{
curl -s -L -b "${directory}facecreep.txt" -A "$ua" "$1"
}
login(){
curl -s -L -c "${directory}facecreep.txt" -A "$ua" -d "email=${email}&pass=${password}" "https://m.facebook.com/login.php"
}
curld()
{
name=$(echo "$1" | sed -e 's/.*\///g' -e 's/\?.*//g')
if [ -e "$name" ]
then
echo "File $name already exists"
else
curl -L -b "${directory}facecreep.txt" -A "$ua" -o "${name}" "$1"
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
   for target in "${targets[@]}"
   do
   if [[ -d "${target}" ]]
   then
      echo "${target} exists, crawling."
   else
      mkdir "${target}"
   fi
   if cd "${target}"
   then
      mapfile -t albums < <(callpage "${site}/${target}?v=photos" | sed -e 's/"/\n/g' -e 's/\\//g' | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g' )
      mapfile -O 3 -t albums < <(callpage "${site}/${target}/photos?psm=default&startindex=3" | sed -e 's/"/\n/g' -e 's/\\//g' | sed -e 's/href="/\n/g'| grep -i "${target}/albums" | sed -e 's/".*//g' )
      for album in "${albums[@]}"
      do
         echo "${album}"
         alnum=$(echo "${album}" | sed -e 's/.*albums\///g' -e 's/\///g')
         if [[ -d "${alnum}" ]]
         then
            echo "${alnum} exists, crawling."
         else
            mkdir "${alnum}"
         fi
         if cd "${alnum}"
         then
            mapfile -t photos < <(callpage "${site}${album}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep "photo.php" | sed -e 's/.*\/photo.php/\/photo.php/g' )
            for photo in "${photos[@]}"
            do
               mapfile -t urls < <(callpage "${site}${photo}" | sed -e 's/"/\n/g' -e 's/\\//g' |grep -A 3 init| grep -i n.jpg | sed -e 's/.*url(\&quot\;https/https/g' -e 's/\&quot\;).*//g' )
               for i in "${urls[@]}"
               do
                  curld "${i}"
               done
            done
         fi
         cd "${directory}${target}"
      done
   fi
   cd "$directory"
   done
   let random=$RANDOM%360
   let sleepy=45+$random
   echo "sleeping $sleepy on $(date)"
   sleep $sleepy
done
