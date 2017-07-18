#!/bin/bash
echo "Do you want to start or stop the server?"
read -p "[Start/stop] " choice
case "$choice" in
	Start|start ) 
		nohup nodejs /home/pi/fileserver/server.js &
		echo "pid: $(pgrep nodejs)"
		;;

	Stop|stop ) 
		pkill nodejs 
		echo "server stopped!"
		;;

	* ) exit 0 ;;
esac
