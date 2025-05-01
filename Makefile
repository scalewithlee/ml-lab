fmt:
	@black .

build:
	docker build --tag ml-lab .

run: build
	docker run -it -v ${PWD}:/code --publish 4200:4200 ml-lab
