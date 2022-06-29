.PHONY:	help deploy test
help:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
all: # Build and deploy from scratch
	make build
	make deploy
build: Dockerfile # Build the docker container, for coding
	docker build -t prueba .
login:
#	docker run --rm -it -v $$PWD:/var/task -w /var/task prueba
run:
	docker run -p 9000:8080 prueba 
test: # Run the tests
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"payload":"hello world!"}'
deploy: # Deploy the lambda function
	make build
	export AWS_PROFILE=globalw
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 342364097105.dkr.ecr.us-east-1.amazonaws.com/prueba
	docker tag prueba:latest 342364097105.dkr.ecr.us-east-1.amazonaws.com/prueba:latest
	docker push 342364097105.dkr.ecr.us-east-1.amazonaws.com/prueba:latest
	echo "Actualice la imagen en el dashboard de lambda"
# serverless deploy function -f selenium-lambda