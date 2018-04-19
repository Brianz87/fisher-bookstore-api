#Stage 0 - Build the Angular application in a builder image
#------------------------------------------------------------

#set our base image to the offical Node Alpine image from the Docker hub and name it 'node'
FROM node:9.11.1-alpine as builder

#set the working directory of our Docker image
WORKDIR /app

#copy NPM package definitions into our working directory
COPY package.json /app/

#download all packages into image
RUN npm install

#copy the entire web project (minus .dockerignore) into image
COPY ./ /app/

#create an enviroment variable to use in the Angular CLI
ARG env=prod

#build the Angular app
RUN npm run build -- --prod --enviroment $env


#STAGE 1 - Create the Prod image from the test image
#------------------------------------------------------

#set our deploy image to the offical NGINX image from the Docker hub
FROM nginx:1.13-alpine

#copy the 'dist' folder from Stage 0 to NGINX web server directory
COPY --from=builder /app/dist/ /usr/share/nginx/html

#overwrite NGINX default config with custom config
COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf
