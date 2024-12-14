# vai busca la no docker hub essa imagem do node
# tem a versão slim
FROM node:18 AS build

# Define o diretório de trabalho dentro do container
WORKDIR /usr/src/app

# Copia os arquivos de configuração de dependências (package.json e package-lock.json) 
# para o diretório de trabalho do container
COPY package*.json ./

# Instala os pacotes listados no package.json (inclui dependências de desenvolvimento)
RUN npm install

# Copia todo o conteúdo do diretório atual (da máquina host) para o container,
# colocando tudo no diretório de trabalho (/usr/src/app)
COPY . . 

# Gera os arquivos otimizados para produção (pasta de build ou equivalente)
RUN npm run build

# Instala apenas as dependências necessárias para produção, removendo as de desenvolvimento
RUN npm install --production


#aqui estamos otimizando o pacote node ou melhor dizendo q essa sera o pacote final
#usa sh e não bash como no slim
FROM node:18-alpine3.19

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules

EXPOSE 3000

#define o comando padrão que o container vai executar quando for iniciado.
CMD ["npm", "run", "start:prod"]