#Makefile

work:
	vagrant up
	xterm -e 'cd tests; /bin/bash' &
	xterm -e 'vagrant status & vagrant ssh -- -t "cd /var/www/site; /bin/bash" ' &
	xterm -e 'vagrant status & vagrant ssh -- -t "mysql -uroot -prootpass; /bin/bash" ' &
	vim
