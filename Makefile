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
