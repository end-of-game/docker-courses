#!/bin/bash

# SIGUSR1-handler
my_handler() {
  touch /SIGUSR1-received.txt
}

# SIGTERM-handler
stop_handler() {
  echo "stop_handler"
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'my_handler' SIGUSR1
trap 'stop_handler' SIGTERM

while true
do
  tail -f /dev/null & wait ${!}
done

