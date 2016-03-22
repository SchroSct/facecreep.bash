# facecreep.bash
Download Facebook Photo Albums via Curl

# setup

In a directory for facecreep add a facecreep.rc.txt and a facecreep.list.txt, edit facecreep scripts to have this path set in the variable directory=""

facecreep.rc.txt requires the following in a newline delimited file:

1. facebook email address
2. facebook password
3. facebook name (the proper name it calls you, used to test if logged in)

facecreep.list.txt requires a newline delimited list of facebook usernames.

When facecreep(-full) is ran it cd's to the download directory, where the pictures + facebook cookie are stored, and loops through the user's albums until the end is reached.  facecreep-full tries to go through everything (simulating a 'next' click), and then closes.  facecreep.bash was an attempt to loop through only the most recent photos, although this appears to do the opposite.
