# Built for the https://github.com/casey/just command runner

set dotenv-load

default: default-run

list:
	@just --list

# Setup required packages on the raspberry pi.
local-setup:
	# Run updates and install packages
	sudo apt update
	sudo apt upgrade -y
	sudo apt install git python3-pip python3-setuptools python3-smbus -y
	# Install the robot-hat python bindings
	-git clone -b v2.0 https://github.com/sunfounder/robot-hat.git ~/robot-hat
	cd ~/robot-hat; sudo python3 setup.py install
	# Install the vilib python library
	-git clone -b picamera2 https://github.com/sunfounder/vilib.git ~/vilib
	cd ~/vilib; sudo python3 install.py
	# Install the pycrawler python library
	-git clone --depth 1 -b v3.0 https://github.com/sunfounder/picrawler.git ~/picrawler
	cd ~/picrawler; sudo python3 setup.py install
	sudo raspi-config nonint do_i2c 1
	@echo \#\#\#\#\#\#\#\#\#\#\# When it asks you to reboot, choose no. Reboot after all commands have finished. \#\#\#\#\#\#\#\#\#
	sleep 2
	cd ~/picrawler; sudo bash i2samp.sh -y
	-git clone --depth 1 https://github.com/adafruit/Raspberry-Pi-Installer-Scripts ~/adafruit_i2samp_installer
	sudo pip3 install adafruit-python-shell --break-system-packages
	@echo \#\#\#\#\#\#\#\#\#\#\# When it asks you to reboot, choose no. Reboot after all commands have finished. \#\#\#\#\#\#\#\#\#
	sleep 2
	cd ~/adafruit_i2samp_installer; sudo python3 i2samp.py -y

# Setup the python virtual environment. Re-run this anytime the requirements.txt have changed.
venv-setup:
	#!/bin/bash
	if [ ! -d .venv ]; then
		python3 -m venv .venv
	fi
	source .venv/bin/activate
	pip install -r requirements.txt

# Run both the local-setup and the venv-setup
full-setup: local-setup venv-setup



maker: (default-run "gtts_maker.py")




### The following commands are used to run files, making sure that the venv is activated.

# The default run method. Set to run-local, run-remote, or run-remote-git.
[group('runFile')]
default-run file="main.py": (run-remote file)

# Run the supplied file on the local machine.
[group('runFile')]
run-local file:
	#!/bin/bash
	if [ ! -d .venv ]; then
		just venv-setup
	fi
	source .venv/bin/activate
	python3 "{{file}}"

# Run on the remote machine, copying the local files to that machine.
[group('runFile')]
run-remote file:
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
		just run-local \"{{file}}\""

# Run on the remote machine, cloning the code from the repo.
[group('runFile')]
run-remote-git file:
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
		just run-local \"{{file}}\""

