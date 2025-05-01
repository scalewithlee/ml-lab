fmt:
	@black .

build:
	docker build --tag ml-lab .

run: build
	docker run -it -v ${PWD}/src:/app/src --publish 4200:4200 --publish 8080:8080 ml-lab
