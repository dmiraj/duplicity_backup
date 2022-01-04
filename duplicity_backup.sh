<<Multiline_comment
In the following I will make a script that I can use to back up my home directory.
- I want the script to archive my data
- I want the data transfer to be secure
- I want the output to be redirected to a file, which I can read to from a terminal widget.
Multiline_comment

# The following is the function that uses rsync.
function rsync_use() {
	# The backup will proceed with modification time
	rsync -vvv \
		-r \
		--info=PROGRESS2 \
		--backup-dir=KreAT0r \
		-u \
		--links \
		-p \
		-E \
		-H \
		-X \
		-A \
		-o \
		-g \
		-t \
		--delete \
		--force \
		-z \
		--exclude=$HOME/Downloads/* \
		-h \
		-i \
		-e 'ssh -p6897' \
		$HOME/* k0@berhl.hopto.org:
}

function configuration () {
	# This function will set up all the configuration files.
	if ! [ -a ~/.config/duplicity ]; then
		mkdir ~/.config/duplicity # The folder where configuration will be set.
	fi

	if ! [ -a ~/.local/bin ]; then
		cat <<-Question_user
		Would you like to set the script to run from ~/.local/bin?
		Answer no if '~/.local/bin' is not in your \$PATH
		Question_user
		read -p "(y/n)> " answer
		if [ $answer == 'y' ]; then
			mkdir ~/.local/bin
		else
			cat <<-Question_path
			Enter path in $PATH to symlink this script in.
			Please make sure the path you are entering is in $PATH
			Question_path
			read -p "your path > " script_path
			if [ $scrip_path =~ ^/ ]; then
				echo "You will most likely need to run this script with elevated privileges in order to write inside $script_path\nBut we'll give it a try!" 
				ln -s -T duplicity_backup.sh $script_path/duplicity_backup
				if [ $_ ]; then
					echo "Symlinked duplicity_backup.sh in: $script_path"
				else
					echo "Error happened."
				fi
			else # If the path entered by user does not start with /
				echo "Symlinking duplicity_backup.sh in: $script_path"
				ln -s -T duplicity_backup $script_path/duplicity_backup
			fi
		fi
	else
		echo "Writing a symlink to this script under ~/.local/bin/, please make sure this path is also in your \$PATH"
		ln --symbolic --force -T "$PWD/duplicity_backup.sh" ~/.local/bin/duplicity_backup
	fi

	# Set up symbolic names to configuration files.
	echo "Setting up symbolic name of 'excluded_files' under ~/.config/"
	ln --symbolic --force -T $PWD/excluded_files ~/.config/duplicity/excluded_files
}

function dup_backup () {
	# Interestingly here, I can verify the backup every now and then.
	# The backup is tarred. (which will occupate less space)
	duplicity  --ssh-askpass --progress --log-file ~/duplicity_backup-logs --exclude-filelist ~/.config/duplicity/excluded_files --dry-run $HOME scp://k0@berhl.hopto.org:6897/KreAT0r &> /dev/null
	echo "The function completed";
}

function check_files () {
	echo "Trying to connect to backup server in order to check the files"
	duplicity list-current-files --ssh-askpass scp://k0@berhl.hopto.org:6897/KreAT0r | grep VirtualBox
}

# Parse arguments passed to the script from the command line.
case "$@" in
	--help)
		cat <<-help_output
		Script to backup your important directories in your home folder. Usage:
		duplicity_backup config
		duplicity_backup
		duplicity_backup --help
		duplicity_backup check

		------------------------------------------------------------------------
		In the first form, it will set up configure files for the script to work.
		In the second form it will start backup. 
		In the third form; prints this help message. 
		In the fourth form; list all the files in the backup.
		help_output
		;;
	config)
		configuration
		;;
	'')
		dup_backup
		;;
	check)
		check_files
		;;
	*)
		echo "Wrong usage"
		duplicity_backup --help
		;;
esac
