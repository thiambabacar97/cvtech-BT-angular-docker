# STEP-1 BUILD

FROM node:14-alpine3.15 as node-helper

#Accepting build-arg to create enviroment specifice build
#it is useful when we have multiple enviroment (e.g: dev, tst, staging, prod)
ARG build_env=development

#Création d'un répertoire virtuel dans une image docker
WORKDIR /app

RUN npm cache clean --force

#Copie d'un fichier de la machine locale vers le répertoire de l'image docker virtuelle
COPY . .

#installation des deps pour le projet
RUN npm install

#création d'un build angular
RUN ./node_modules/@angular/cli/bin/ng build --configuration=$build_env

#Defining nginx img
FROM nginx:1.20 as ngx

#copier le code compilé de dist vers le dossier nginx pour le servir
COPY --from=node-helper /app/dist/angular-docker-blog /usr/share/nginx/html

#copie de la configuration nginx du local vers l'image
COPY /nginx.conf /etc/nginx/conf.d/default.conf

#exposer le port interne
EXPOSE 80
