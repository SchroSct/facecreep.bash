#!/bin/bash
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
if [[ -d "timeline" ]]
then
   echo "timeline exists, crawling."
else
   mkdir timeline
fi
if cd timeline
then
   fphoto=$(callpage "${site}/${target}?v=photos" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 10 -i "Photos of " | grep photo.php)
   mapfile -t urls < <(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
   fname=$(echo "${urls[1]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
   curld "${urls[1]}"
   nphoto=$(callpage "${site}${fphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep -A 2 replace-state | tac | grep -m 1 photo.php)
   nname=""
   lname="${fname}"
   until [[ "${nname}" = "${fname}" ]] || [[ "${lname}" = "${nname}" ]]
   do
      mapfile -t urls < <(callpage "${site}${nphoto}" | sed -e 's/"/\n/g' -e 's/\\//g' | grep ".jpg" | grep -v "quot" )
      lname="${nname}"
      nname=$(echo "${urls[1]}" | sed -e 's/.*\///g' -e 's/\?.*//g')
      curld "${urls[1]}"
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
      creep "$target"
   else
      echo "FACECREEP FAILED"
   fi
done
