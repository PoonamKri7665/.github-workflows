# syntax=docker/dockerfile:1

FROM ubuntu:latest AS build1
RUN  apt update  && apt install npm -y


FROM build1 AS build2
COPY firsttask.js firstask.js

#RUN node firstask.js

EXPOSE 3030
CMD [ "node", "firstask.js"]
