#Common image for both dmmapDR and dmaapDR_redir

FROM node:8

WORKDIR /app

COPY dmaapDR.js ./
COPY dmaapDR_redir.js ./
COPY package*.json ./
COPY cert/ cert/

RUN npm install express
RUN npm install argparse

#Ports for DR
#EXPOSE 3906
#EXPOSE 3907

#Ports for DR redir
#EXPOSE 3908
#EXPOSE 3909