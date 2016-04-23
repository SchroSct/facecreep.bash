#!/bin/bash
if mkdir "/tmp/facecreep-full.lock/"
then
   echo "Lock created, running $0"
else
   echo "facecreep-full is already running, please wait until completion."
   exit 1
fi
ua="Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
site="https://m.facebook.com"
if ! read directory < ~/.config/facecreep-full.rc
then
   echo ".config/facecreep-full.rc not set"
   exit 1
fi
   if cd "$directory"
   then
      echo "Inside $directory"
   else
      echo "Could not enter $directory"
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
 
creep()
{
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
   alnum=$(echo "${album}" | sed -e 's/.*albums\///g' -e 's/\///g')
   if [[ -d "${alnum}" ]]
   then
      echo "${alnum} exists, crawling."
   else
      mkdir "${alnum}"
   fi
   if cd "${alnum}"
   then
   mapfile -t photos < <(callpage "${site}${album}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep "photo.php" | sed -e 's/.*\/photo.php/\/photo.php/g')
   fphoto="${photos[1]}"
   mapfile -t urls < <(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
   fname=$(echo "${urls[${ord}]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
   curld "${urls[${ord}]}"
   nphoto=$(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   nname=""
   lname="${fname}"
   until [[ "${nname}" = "${fname}" ]] || [[ "${lname}" = "${nname}" ]]
   do
      mapfile -t urls < <(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
      lname="${nname}"
      nname=$(echo "${urls[${ord}]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
      curld "${urls[${ord}]}"
      nphoto=$(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   done
   if cd "${directory}${target}"
   then
      echo "Back in ${target} main directory"
   else
      echo "Could not enter ${directory}${target}"
      exit 1
   fi
fi
done

}
for target in "${targets[@]}"
do
   if cd "$directory"
   then
      echo "Inside $directory"
   else
      echo "Could not enter $directory"
      exit 1
   fi

   if [[ -d "${target}" ]]
   then
      echo "${target} exists, crawling."
   else
      mkdir "${target}"
   fi
   if cd "${target}"
   then
      ord=1
      creep "$target"
      ord=2
      creep "$target"
      ord=3
      creep "$target"
   else
      echo "$0 FAILED"
   fi
done

rmdir "/tmp/facecreep-full.lock/"
