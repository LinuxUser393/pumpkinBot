# Built for the https://github.com/casey/just command runner

default: run-remote

# Setup required packages on the raspberry pi.
local-setup:
	#!/bin/bash
	# Run updates and install packages
	sudo apt update
	sudo apt upgrade
	sudo apt install git python3-pip python3-setuptools python3-smbus
	# Install the robot-hat python bindings
	git clone -b v2.0 https://github.com/sunfounder/robot-hat.git ~/robot-hat
	cd ~/robot-hat
	sudo python3 setup.py install
	# Install the vilib python library
	git clone -b picamera2 https://github.com/sunfounder/vilib.git ~/vilib
	cd ~/vilib
	sudo python3 install.py
	# Install the pycrawler python library
	git clone --depth 1 -b v3.0 https://github.com/sunfounder/picrawler.git ~/picrawler
	cd ~/picrawler
	sudo python3 setup.py install
	sudo raspi-config nonint do_i2c 1
	sudo bash i2samp.sh -y

# Setup the python virtual environment. Re-run this anytime the requirements.txt have changed.
venv-setup:
	#!/bin/bash
	if [[ ! -d .venv ]]; then
		python3 -m venv .venv
	fi
	source .venv/bin/activate
	pip install -r requirements.txt

# Run both the local-setup and the venv-setup
full-setup: local-setup venv-setup

# Run the main script on the local machine. Can be used as a template for other actions.
run-local:
	#!/bin/bash
	if [[ ! -d .venv ]]; then
		just venv-setup
	fi
	source .venv/bin/activate
	python3 main.py

# Run on a remote machine, copying the local files to that machine.
run-remote:
	#!/bin/bash
	if [ ! $PUMPKIN_SSH ]; then
		echo "Please run the command \"export PUMPKIN_SSH=<user@ip>\" replacing \"<user@ip>\" with the username and ip address of the robot."
		exit
	fi
	#scp -r "$PWD" "scp://$PUMPKIN_SSH/~/pumpkinBot"
	rsync -ave ssh --exclude-from=.gitignore --delete "$PWD/" "$PUMPKIN_SSH:~/pumpkinBot"
	ssh "$PUMPKIN_SSH" "if ! command -v just; then \
			sudo apt install just; \
			just full-setup; \
		fi; \
		cd ~/pumpkinBot; \
		just run-local "

# Run on the remote machine, cloning the code from the repo.
run-remote-git:
	#!/bin/bash
	if [ ! $PUMPKIN_SSH ]; then
		echo "Please run the command \"export PUMPKIN_SSH=<user@ip>\" replacing \"<user@ip>\" with the username and ip address of the robot."
		exit
	fi
	ssh "$PUMPKIN_SSH" "if [ ! -d ~/pumpkinBot ]; then \
			git clone https://github.com/LinuxUser393/pumpkinBot.git ~/pumpkinBot; \
			cd ~/pumpkinBot; \
		fi; \
		if ! command -v just; then \
			sudo apt install just; \
			just full-setup; \
		fi; \
		cd ~/pumpkinBot; \
		git reset --hard HEAD; \
		git clean -f; \
		git pull; \
		just run-local "

