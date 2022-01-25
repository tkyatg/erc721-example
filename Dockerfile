FROM node:16.3-alpine

RUN apk update && \
    apk add git

RUN yarn install && yarn add -D \
    hardhat @openzeppelin/contracts web3

WORKDIR /contract