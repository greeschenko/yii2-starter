#Makefile

NAME='test'

test:

	@echo $(NAME)

install:

	composer global require "fxp/composer-asset-plugin:^1.2.0"
	composer create-project --prefer-dist yiisoft/yii2-app-basic basic
	mv -vf basic/* $PWD
	rm -drvf basic

addvagrant:

	echo -n "Add Vagrant(Y/n)? "

	type=
	while [[ ! $type ]]; do
		read -r -n 1 -s answer
		if [[ $answer = [Yy] ]]; then
			git clone https://github.com/greeschenko/vagrant-devenv.git
			rm -drvf vagrant-devenv/.git
			rm -drvf vagrant-devenv/LICENSE
			rm -drvf vagrant-devenv/README.md
			cp -rv vagrant-devenv/* $PWD
			rm -drvf vagrant-devenv
			break
		elif [[ $answer = [Nn] ]]; then
			break
		fi
	done

configure:

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

	chmod -R 776 runtime
	chmod -R 776 web/assets


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
	xterm -e 'vagrant status & vagrant ssh -- -t "cd /var/www/site; /bin/bash" ' &
	xterm -e 'vagrant status & vagrant ssh -- -t "mysql -uroot -prootpass; /bin/bash" ' &
	vim
