cd ./postfix
docker build . -t postfix
docker container kill $(docker ps -q)
docker run -d postfix
docker ps