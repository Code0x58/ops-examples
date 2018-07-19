Each directory contains a scenario, built from Docker containers. You can start the containers for it using
`docker-compose up -d`, and when finished `docker-compose down --volumes` will stop and remove the containers. It may
be better to not use the `-d` flag to see get the output of the containers so you can see when they are ready.

Once the containers are running, you can go through the bash scripts in order to get a run through of the topic.
