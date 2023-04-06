#!/bin/bash

echo -e "\n-- phase 1 --\n"

apt install -y sshpass;

# get password from file
passwd=$(cat passwd)
myhost=$(cat rename-me)
myhost=$myhost
myhost=$(echo $myhost| tr -d ' ');
myhost=$(echo $myhost| tr -d '\n');
myhost=$(echo $myhost| tr -d '\r');

# put host names to hosts
cat rename-host > /etc/hosts;
cat rename-me > /etc/hostname;
hostnamectl set-hostname $myhost

echo -e "\n-- phase 2 --\n"

# clear and regenerate keys, authorized itself
sudo -u ubuntu rm -r -f ~/.ssh;
sudo -u ubuntu ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P "";
sudo -u ubuntu cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys;

echo -e "\n-- phase 3 --\n"

x=1
# set hostname for each machine

for name in $(cat rename-host)
do
	if [[ $x == 1 ]]
	then
		x=0
		continue
	fi
	x=1
	
	if [[ "$name" == "$myhost" ]]
	then
		continue
	fi

	echo "-- I am ubuntu@$myhost, calling ubuntu@$name to send ~/.ssh/id_rsa.pub to me --"

	host=$(cat rename-host);

	sudo -u ubuntu \
		sshpass -p $passwd \
		ssh -o StrictHostKeyChecking=no ubuntu@$name \
		"
		sudo rm -r -f /home/ubuntu/.ssh;
		echo '$host' | sudo tee /etc/hosts >/dev/null;
		ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P \"\";
		sudo hostnamectl set-hostname $name;
		cat ~/.ssh/id_rsa.pub;
		" >> ~/.ssh/authorized_keys;

done;

echo -e "\n-- phase 4 --\n"

x=1
# set hostname for each machine
for name in $(cat rename-host)
do
	if [[ $x == 1 ]] 
	then
		x=0
		continue
	fi
	x=1
	
	if [[ "$name" == "$myhost" ]]
	then
		continue
	fi

	echo "-- I am ubuntu@$myhost, sending ~/.ssh/authorized_keys to ubuntu@$name --" 
	
	auth=$(cat /home/ubuntu/.ssh/authorized_keys);

	sshpass -p $passwd \
		ssh -o StrictHostKeyChecking=no ubuntu@$name \
		"
		sudo echo '$auth' > /home/ubuntu/.ssh/authorized_keys;
		echo 'hello from $name';
		";
	sshpass -p $passwd \
		ssh -o StrictHostKeyChecking=no ubuntu@$name ssh -o StrictHostKeyChecking=no ubuntu@$myhost "echo hello";

done;
