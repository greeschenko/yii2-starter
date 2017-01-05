#!/usr/bin/env bash

CPSPATH='/usr/local/bin/composer'
if [[ ! -f $CPSPATH ]]; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    echo 'composer installed!!!'
fi

composer global require "fxp/composer-asset-plugin:~1.1.1"

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
        echo 'installed codecept!!!'
    fi
fi

composer global require "codeception/specify=*"
composer global require "codeception/verify=*"
composer install

chmod -R 777 runtime
chmod -R 777 web/assets

echo "#!/usr/bin/env bash" > .git/hooks/post-merge
echo "php yii migrate --interactive=0" >> .git/hooks/post-merge
echo "composer update" >> .git/hooks/post-merge

chmod +x .git/hooks/post-merge

