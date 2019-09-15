# SqlServerOnDocker
Prof of concept project with Microsoft SQL Server and Django Framework setup on docker containers.

## To start development:
1. install [docker](https://docs.docker.com/#/components) and [docker-compose](https://docs.docker.com/compose/install/)
2. clone this repository
2. run `docker-compose build db` to build db container
2. sudo docker-compose run db sqlcmd -S db1.internal.prod.example.com -U SA -P 'Alaska2017' -Q 'create database docker2;'
3. run `docker-compose up web` to test web and db containers
5. run `docker-compose run web python3 manage.py migrate` to apply migrations. **Important! all migrations will go to master database unless you create new database and update settings.py files**
6. run `docker-compose run web python3 manage.py createsuperuser` to create admin account

## To run project:
1. 
1. run `docker-compose up web`
2. point your browser to `localhost:8080`
3. press `CTRL+C` to stop

## Access to sql server
1. sudo docker-compose run db sqlcmd -S db1.internal.prod.example.com -U SA -P 'Alaska2017' -Q 'select 1'
2. sudo docker exec -it sqlserverondocker_db_1 bash