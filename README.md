# mcare


## app build

./gradlew bootjar

docker build -t sakamotodesu/mcare .

docker run -p 8080:8080 sakamotodesu/mcare

### alpine container

docker container exec -it container_id /bin/ash

## db build

cd docker
docker-compose up -d
init-mysql.sh

### mysql login
mysql -u username -p -h 127.0.0.1

## infra

### terraform

terraform apply -target=aws_vpc.mcare-vpc

### ansible

ansible-playbook -i inventory/hosts bastion.yml