set :deploy_to, '/home/deployer/uber-monitoring/' #directory to deploy to, do no use ~ in path !
set :user, 'deployer' #username to deploy to
role :app, %w{deployer@ip} #username@ip
server 'ip', user: 'deployer', roles: %w{web}
