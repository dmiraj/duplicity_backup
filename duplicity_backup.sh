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

function configuration() {
	# This function will set up all the configuration files.
	if ! [ -a .config/duplicity ]; then
		mkdir .config/duplicity # The folder where configuration will be set.
	fi

	# Set up symbolic names to configuration files.
	ln -t -s .config/duplicity ./excluded_files

	# Setup the binary under ~/.local/bin/ which is likely to be part of $PATH.
	ln -T -s duplicity_backup.sh ~/.local/bin/duplicity_backup
}

function dup_backup() {
	# Interestingly here, I can verify the backup every now and then.
	# The backup is tarred. (which will occupate less space)
	duplicity  --ssh-askpass --progress --log-file ~/duplicity_backup-logs --exclude-filelist ~/.config/duplicity/excluded_files $HOME scp://k0@berhl.hopto.org:6897/KreAT0r &> /dev/null
	echo "The function completed";
}
dup_backup
