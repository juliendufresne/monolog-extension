# do more actions on some target when the DEBUG var is set to true
DEBUG := false
# for checks and tests commands, we'll do our best to run those on modified files only
FAST := true
ifeq ($(DEBUG), true)
FAST := false
endif

ifeq ($(FAST), true)
        PHP_FILES_CHANGED := $(shell bin/ls_changed_files --ext=.php src tests)
endif

help:
	@echo "\033[33m Usage:\033[39m"
	@echo "  make COMMAND"
	@echo ""
	@echo "\033[33m Options:\033[39m"
	@echo "   Options can be passed to the make command like this:"
	@echo "       make DEBUG=true <command>"
	@echo ""
	@echo "\033[32m   DEBUG=true       \033[39m   In case the command you are running did not fix your"
	@echo "                       issue, this option will do more actions"
	@echo "\033[32m   FAST=false       \033[39m   For checks and tests commands, we'll do our best to run"
	@echo "                       those on modified files only. Putting FAST to false will"
	@echo "                       disable this behavior and run those commands on all files"
	@echo ""
	@echo "\033[33m Meta commands:\033[39m"
	@echo "\033[32m   push             \033[39m   Run all checks and tests"
	@echo ""
	@echo "\033[33m Checks commands:\033[39m"
	@echo "\033[32m   lint             \033[39m   Checks PHP files syntax"
	@echo "\033[32m   php-cs-fixer     \033[39m   Fix code style in php files"
	@echo "\033[32m   phpmetrics       \033[39m   Produces a report and metrics"
	@echo "\033[32m   phpstan          \033[39m   Find bugs in the code"
	@echo "\033[32m   security         \033[39m   Checks if your composer packages versions contains vulnerabilities"
	@echo ""
	@echo "\033[33m Tests commands:\033[39m"
	@echo "\033[32m   phpunit          \033[39m   Run phpunit tests"
	@echo "\033[32m   phpunit-coverage \033[39m   Run phpunit tests with code coverage"

###> meta ###
.PHONY: push

# priority matters: faster script should be run first for faster feedback
push: composer-validate lint php-cs-fixer-check phpstan phpmetrics phpunit
# $(make push) should print a warning message if the thing we are about to push is not the same thing the command has tested.
	@echo ""
	@echo "  \033[97;44m                                                                              \033[39;49m"
	@echo "  \033[97;44m    [OK] No errors found.                                                     \033[39;49m"
	@echo "  \033[97;44m                                                                              \033[39;49m"
	@echo ""
	@echo ""
ifeq ($(shell git status --porcelain),)
	@echo ""
	@echo "  \033[97;44m                                                                              \033[39;49m"
	@echo "  \033[97;44m    You may push your changes.                                                \033[39;49m"
	@echo "  \033[97;44m                                                                              \033[39;49m"
	@echo ""
else
	@echo "  \033[97;43m                                                                              \033[39;49m"
	@echo "  \033[97;43m    Your git working tree is not empty.                                       \033[39;49m"
	@echo "  \033[97;43m    This means the 'make push' command possibly runs on files that are not    \033[39;49m"
	@echo "  \033[97;43m    going to be part of your next 'git push' command.                         \033[39;49m"
	@echo "  \033[97;43m    Please consider commit/squash your changes and run this command again.    \033[39;49m"
	@echo "  \033[97;43m                                                                              \033[39;49m"
	@echo ""
endif

###< meta ###

###> composer commands ###
.PHONY: composer-*

composer-install:
	@echo "\n\033[33m    composer install --no-progress --prefer-dist --no-suggest\033[39m\n"
	@                    composer install --no-progress --prefer-dist --no-suggest

composer-outdated:
	@echo "\n\033[33m    composer outdated\033[39m\n"
	@                    composer outdated

composer-update:
	@echo "\n\033[33m    composer update\033[39m\n"
	@                    composer update

composer-validate:
	@echo "\n\033[33m    composer validate\033[39m\n"
	@                    composer validate
###< composer commands ###

###> check commands ###
.PHONY: lint php-cs-fixer php-cs-fixer-check phpstan

ifeq ($(FAST), false)
lint:
	@echo "\n\033[33m    php vendor/bin/parallel-lint --exclude vendor .\033[39m\n"
	@                    php vendor/bin/parallel-lint --exclude vendor .
else ifneq ($(PHP_FILES_CHANGED),)
lint:
	@echo "\n\033[33m    php vendor/bin/parallel-lint $(PHP_FILES_CHANGED)\033[39m\n"
	@                    php vendor/bin/parallel-lint $(PHP_FILES_CHANGED)
else
lint:
	@echo "You have made no change in PHP files compared to master"
endif

ifeq ($(FAST), false)
php-cs-fixer:
	@echo "\n\033[33m    php vendor/bin/php-cs-fixer fix -vvv\033[39m\n"
	@                    php vendor/bin/php-cs-fixer fix -vvv
else ifneq ($(PHP_FILES_CHANGED),)
php-cs-fixer:
	@echo "\n\033[33m    php vendor/bin/php-cs-fixer fix -vvv --config=.php_cs.dist --path-mode=intersection $(PHP_FILES_CHANGED)\033[39m\n"
	@                    php vendor/bin/php-cs-fixer fix -vvv --config=.php_cs.dist --path-mode=intersection $(PHP_FILES_CHANGED)
else
php-cs-fixer:
	@echo "You have made no change in PHP files compared to master"
endif

ifeq ($(FAST), false)
php-cs-fixer-check:
	@echo "\n\033[33m    php vendor/bin/php-cs-fixer fix -vvv --dry-run\033[39m\n"
	@                    php vendor/bin/php-cs-fixer fix -vvv --dry-run
else ifneq ($(PHP_FILES_CHANGED),)
php-cs-fixer-check:
	@echo "\n\033[33m    php vendor/bin/php-cs-fixer fix -vvv --dry-run --config=.php_cs.dist --path-mode=intersection $(PHP_FILES_CHANGED)\033[39m\n"
	@                    php vendor/bin/php-cs-fixer fix -vvv --dry-run --config=.php_cs.dist --path-mode=intersection $(PHP_FILES_CHANGED)
else
php-cs-fixer-check:
	@echo "You have made no change in PHP files compared to master"
endif

phpmetrics:
	@echo "\n\033[33m    php vendor/bin/phpmetrics --report-html=reports/phpmetrics .\033[39m\n"
	@                    php vendor/bin/phpmetrics --report-html=reports/phpmetrics .

ifeq ($(FAST), false)
phpstan:
	@echo "\n\033[33m    php vendor/bin/phpstan analyse --no-progress --configuration=phpstan.neon --autoload-file=vendor/autoload.php --level=7 src tests\033[39m\n"
	@                    php vendor/bin/phpstan analyse --no-progress --configuration=phpstan.neon --autoload-file=vendor/autoload.php --level=7 src tests
else ifneq ($(PHP_FILES_CHANGED),)
phpstan:
	@echo "\n\033[33m    php vendor/bin/phpstan analyse --no-progress --configuration=phpstan.neon --autoload-file=vendor/autoload.php --level=7 $(PHP_FILES_CHANGED)\033[39m\n"
	@                    php vendor/bin/phpstan analyse --no-progress --configuration=phpstan.neon --autoload-file=vendor/autoload.php --level=7 $(PHP_FILES_CHANGED)
else
phpstan:
	@echo "You have made no change in PHP files compared to master"
endif

security:
	@echo "\n\033[33m    php bin/console security:check\033[39m\n"
	@                    php bin/console security:check
###< check commands ###

###> tests commands ###
.PHONY: phpunit phpunit-coverage

phpunit:
	@echo "\n\033[33m    php vendor/bin/phpunit\033[39m\n"
	@                    php vendor/bin/phpunit

phpunit-coverage:
	@echo "\n\033[33m    php -dzend_extension=xdebug.so vendor/bin/phpunit --coverage-html reports/coverage --coverage-clover reports/clover.xml\033[39m\n"
	@                    php -dzend_extension=xdebug.so vendor/bin/phpunit --coverage-html reports/coverage --coverage-clover reports/clover.xml
###< tests commands ###
