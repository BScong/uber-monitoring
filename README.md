# Uber fares monitoring

With use of Uber api
Use it to monitore uber fares for home<->work travels thanks to Grafana and Uber api (you need an api key)

# Configuration
## Server config
You need Docker and Docker-Compose installed on the server, to install follow the instructions on their website. We also use Capistrano for deployment.

Clone the repo.
Go to ```config/deploy``` and copy ```example.rb```, for exemple in server.rb : ```cp example.rb server.rb```
Then edit ```server.rb``` : it is already set for a user named "deployer". You need to replace the ip. If you want to deploy to another user, also replace "deployer" to the username of your choice. 

Don't forget to give rights to your user to Docker : ```sudo adduser deployer docker```

If you have modified your user, also update the path in the ```docker-compose.yml```file.

## Params config
Then go to ```python``` folder. Open ```params.py``` and complete the file.

# Running
To deploy, just run ```cap server deploy```(or whatever your rb file was named). You can then access your grafana at ip:3000. Default logins are admin:admin. At first login, create a new admin account, then delete the admin account !!!

For the first deploy, log in ssh to the server, then log into your influxdb container : ```docker exec -it python bash``` 
Then log into your influxdb : ```influx```
Run the following commands : 

```
CREATE USER uber WITH PASSWORD 'password' WITH ALL PRIVILEGES;
CREATE DATABASE uber;
```
With password the password you specified in the params.py file.

You can then create a new dashboard and exploit your data. If the Python script doesn't execute after first deploy, re-run ```cap server deploy```
