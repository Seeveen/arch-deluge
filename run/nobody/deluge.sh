#!/bin/bash

# if config file doesnt exist (wont exist until user changes a setting) then copy default config file
if [[ ! -f /config/core.conf ]]; then

	echo "[info] Deluge config file doesn't exist, copying default..."
	cp /home/nobody/deluge/core.conf /config/

else

	echo "[info] Deluge config file already exists, skipping copy"

fi

# if pid file exists then remove (generated from previous run)
rm -f /config/deluged.pid

# run deluge daemon (daemonized, non-blocking)
echo "[info] Attempting to start Deluge..."
/usr/bin/deluged -c /config -L info -l /config/deluged.log

echo "[info] Waiting for Deluge process to start listening on port 58846..."

while [[ $(netstat -lnt | awk "\$6 == \"LISTEN\" && \$4 ~ \".58846\"") == "" ]]; do
	sleep 0.1
done

# run script to check we don't have any torrents in an error state
/home/nobody/torrentcheck.sh

if ! pgrep -x "deluge-web" > /dev/null; then
	echo "[info] Starting Deluge Web UI..."

	# run deluge-web
	/usr/bin/deluge-web -c /config

	echo "[info] Deluge Web UI started"
fi

# run cat to prevent script exit
cat
