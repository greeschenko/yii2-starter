#Makefile

NAME=myproject
IPNUM=`wc -l /etc/hosts | awk '{print($$1)}'`

install:

	composer global require "fxp/composer-asset-plugin:^1.2.0"
	composer create-project --prefer-dist yiisoft/yii2-app-basic basic
	cp -rvf basic/. ${PWD}
	rm -drvf basic

devconfigure:

	cat config/db.php | sed "s/yii2basic/${NAME}/g" > config/db.php_tmp
	cat config/db.php_tmp | sed "/password/s/''/'rootpass'/g" > config/db.php_new
	rm config/db.php_tmp
	rm config/db.php
	mv config/db.php_new config/db.php

	cat config/test_db.php | sed "s/yii2_basic_tests/${NAME}/g" > config/test_db.php_new
	rm config/test_db.php
	mv config/test_db.php_new config/test_db.php

	cat config/web.php | sed "s/basic/${NAME}/g" > config/web.php_new
	rm config/web.php
	mv config/web.php_new config/web.php

	cat Vagrantfile | sed "s/vagrantmashine/vagrantmashine.${NAME}/g" > Vagrantfile_new
	rm Vagrantfile
	mv Vagrantfile_new Vagrantfile

	IPNUM=`wc -l /etc/hosts | awk '{print($$1)}'`

	cat Vagrantfile | sed "s/192.168.88.88/192.168.88.$$(( ${IPNUM} + 1 ))/g" > Vagrantfile_new
	rm Vagrantfile
	mv Vagrantfile_new Vagrantfile

	cat provision.sh | sed "s/myproject/${NAME}/g" > provision.sh_new
	rm provision.sh
	mv provision.sh_new provision.sh

	sudo -- sh -c "echo 192.168.88.$$(( ${IPNUM} + 1 )) ${NAME}.ga >> /etc/hosts"

	vagrant up

	chromium ${NAME}.ga

serverconfigure:

	CPSPATH='/usr/local/bin/composer'
	if [[ ! -f $CPSPATH ]]; then
		curl -sS https://getcomposer.org/installer | php
		mv composer.phar /usr/local/bin/composer
		echo 'composer installed!!!'
	fi

	composer global require "fxp/composer-asset-plugin:^1.2.0"

	if [[ ! $PATH =~ 'codecept' ]]; then
		CODEPATH1=$HOME'/.config/composer/vendor/bin'
		CODEPATH2=$HOME'/.composer/vendor/codeception/codeception'
		if [[ -f $CODEPATH1'/codecept' ]]; then
			echo 'PATH=$PATH:'$CODEPATH1 >> $HOME'/.bashrc'
			echo 'export PATH' >> $HOME'/.bashrc'
			source $HOME'/.bashrc'
			echo 'in 1'
		elif [[ -f $CODEPATH2'/codecept' ]]; then
			echo 'PATH=$PATH:'$CODEPATH2 >> $HOME'/.bashrc'
			echo 'export PATH' >> $HOME'/.bashrc'
			source $HOME'/.bashrc'
			echo 'in 2'
		else
			composer global require "codeception/codeception=2.1.*"
			if [[ -f $CODEPATH1'/codecept' ]]; then
				echo 'PATH=$PATH:'$CODEPATH1 >> $HOME'/.bashrc'
				echo 'export PATH' >> $HOME'/.bashrc'
				source $HOME'/.bashrc'
				echo 'in 1'
			elif [[ -f $CODEPATH2'/codecept' ]]; then
				echo 'PATH=$PATH:'$CODEPATH2 >> $HOME'/.bashrc'
				echo 'export PATH' >> $HOME'/.bashrc'
				source $HOME'/.bashrc'
				echo 'in 2'
			fi
			echo 'installed codecept!!!'
		fi
	fi

	composer global require "codeception/specify=*"
	composer global require "codeception/verify=*"
	composer install

	chmod -R 777 runtime
	chmod -R 777 web/assets


	echo -n "Add post-merge hook(Y/n)? "

	type=
	while [[ ! $type ]]; do
		read -r -n 1 -s answer
		if [[ $answer = [Yy] ]]; then
			echo "#!/usr/bin/env bash" > .git/hooks/post-merge
			echo "php yii migrate --interactive=0" >> .git/hooks/post-merge
			echo "composer update" >> .git/hooks/post-merge
			chmod +x .git/hooks/post-merge
			break
		elif [[ $answer = [Nn] ]]; then
			break
		fi
	done


work:

	vagrant up
	xterm -e 'cd tests; /bin/bash' &
	xterm -e 'vagrant status & vagrant ssh -- -t "cd /var/www/project; /bin/bash" ' &
	xterm -e 'vagrant status & vagrant ssh -- -t "mysql -uroot -prootpass; /bin/bash" ' &
	vim
