#!/bin/bash

function check_errors { if [ "$?" != "0" ]; then echo "Error" && exit -1; fi }

read -p "Music/Author Name: " keyword
if [ -z "$keyword" ]; then echo "Invalid keyword" && exit -1; fi

curl -s 'https://ytpp3.com/ytsearch' \
  -H 'authority: ytpp3.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'content-type: application/json' \
  -H 'origin: https://www.mp3juices.cc' \
  -H 'referer: https://www.mp3juices.cc/' \
  -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36" \
  -H 'uuid: 083c2452740957913c0acde7a74d1448' \
  --data-raw "{\"key_word\":\"$keyword\"}" \
  --compressed 2>/dev/null >/tmp/ytpp3
check_errors

track=0
rm -f /tmp/ytpp3_urls 2>/dev/null
cat /tmp/ytpp3 | jq -r ".result[] | [.title,.duration,.url] | @tsv" | while read music; do
track=$((track+1)); echo "$music" | tr -d "," 2>/dev/null | sed 's/\t/,/g' 2>/dev/null | while read i; do
echo -e "\x1b[41m# Track $track\x1b[0m" 2>/dev/null
echo -e " Name: \x1b[1m\x1b[33m$(echo $i | cut -d, -f1 2>/dev/null)\x1b[0m" && check_errors
echo " Duration: $(echo $i | cut -d, -f2 2>/dev/null)" && check_errors
echo " URL: $(echo $i | cut -d, -f3 2>/dev/null)" && check_errors
echo "$track $(echo $i | cut -d, -f3 2>/dev/null)" 2>/dev/null >>/tmp/ytpp3_urls && check_errors
done
done
check_errors

while :; do
	read -p "Track Number (1-10 / 0=all): " ntrack
	if [[ "$ntrack" =~ ^[1-9]$ ]] || [[ "$ntrack" == "10" ]]; then
		link_to_play=$(cat /tmp/ytpp3_urls 2>/dev/null | grep "^$ntrack " 2>/dev/null| cut -d " " -f2 2>/dev/null); check_errors
		echo "Playing Track $ntrack..."
		vlc -I "dummy" "$link_to_play" --no-video --no-loop --no-repeat --play-and-exit 2>/dev/null 3>/dev/null >/dev/null; check_errors
	elif [[ "$ntrack" == "0" ]]; then
		cat /tmp/ytpp3_urls | while read i; do
			link_to_play=$(echo "$i" | cut -d " " -f2 2>/dev/null)
			echo "Playing Track $(echo $i | cut -d ' ' -f1)..."
			vlc -I "dummy" "$link_to_play" --no-video --no-loop --no-repeat --play-and-exit 2>/dev/null 3>/dev/null >/dev/null; check_errors
		done
	else
		echo "Unvailable Track Number"
	fi
done







