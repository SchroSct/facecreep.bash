# facecreep.bash
Download Facebook Photo Albums via Curl

email = Your email to login

password = Your password to login

target = Username of the albums you want

directory = Where to save the pictures.

uname = The name Facebook Recognizes you as, used to see if you're really logged in.

When facecreep(-full) is ran it cd's to the download directory, where the pictures + facebook cookie are stored, and loops through the user's albums until the end is reached.  facecreep-full tries to go through everything (simulating a 'next' click), and then closes.  facecreep goes through what may be the 'most recent' photos of each album and updates accordingly, looping every x seconds.
