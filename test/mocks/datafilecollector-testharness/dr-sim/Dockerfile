#Common image for both dmmapDR and dmaapDR_redir

FROM node:14

WORKDIR /app

COPY dmaapDR.js ./
COPY dmaapDR_redir.js ./
COPY package*.json ./
ARG HTTP_PROXY=http://10.144.1.10:8080
ARG HTTPS_PROXY=http://10.144.1.10:8080
RUN npm install express
RUN npm install argparse

#Ports for DR
#EXPOSE 3906
#EXPOSE 3907

#Ports for DR redir
#EXPOSE 3908
#EXPOSE 3909
