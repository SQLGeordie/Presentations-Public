<#
docker-compose build db to build db container
docker-compose up web #Run this to create containers, it will fail not finding the docker2 db
docker exec -it sqlserverondocker_db_1 /opt/mssql-tools/bin/sqlcmd -S db1.internal.prod.example.com -U sa -P Alaska2017
	create database docker2
	go
docker-compose run web python3 manage.py migrate
docker-compose run web python3 manage.py createsuperuser
docker-compose up web

connect to http://localhost:8080/admin
#>

#changed everything to run on master
docker-compose run web python3 manage.py migrate
docker-compose run web python3 manage.py createsuperuser
docker-compose up web

connect to http://localhost:8080/admin