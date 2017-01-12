all: morbo

.PHONY: morbo
morbo:
	carton exec -- morbo script/hackerz_lab

.PHONY: hypnotoad
hypnotoad:
	carton exec -- hypnotoad -f script/hackerz_lab

.PHONY: install
install:
	carton install

.PHONY: create
create:
	heroku create hackerz-lab

.PHONY: buildpack
buildpack:
	heroku create hackerz-lab --buildpack https://github.com/pnu/heroku-buildpack-perl.git

.PHONY: delete
delete:
	heroku apps:delete hackerz-lab --confirm hackerz-lab

.PHONY: push
push:
	git push heroku master

.PHONY: logs
logs:
	heroku logs

.PHONY: login
login:
	heroku login

.PHONY: remote
remote:
	heroku git:remote -a hackerz-lab

.PHONY: ps
ps:
	heroku ps

.PHONY: db
db:
	carton exec -- script/hackerz_lab generate_db

.PHONY: help
help:
	@echo 'Usage:'
	@echo 'make <command>'
	@echo ''
	@echo 'command:'
	@echo '  morbo        run morbo'
	@echo '  hypnotoad    run hypnotoad'
	@echo '  install      run carton install'
	@echo '  create       run heroku create'
	@echo '  buildpack    run heroku create with buildpack'
	@echo '  delete       run heroku apps:delete'
	@echo '  push         run heroku push'
	@echo '  logs         run heroku logs'
	@echo '  login        run heroku login'
	@echo '  remote       run heroku apps:remote'
	@echo '  ps           run heroku ps'
	@echo '  db           run script/hackerz_lab generate_db'
