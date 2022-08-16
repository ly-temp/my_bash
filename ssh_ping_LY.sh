#!/bin/bash
#input $ssh_target $time
while true;do
	ssh -o StrictHostKeyChecking=no "$1" ls
	sleep "$2"
done