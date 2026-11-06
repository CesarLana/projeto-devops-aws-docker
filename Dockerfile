# Imagem base oficial do Nginx com Alpine Linux (leve e segura: ~25MB)
FROM nginx:alpine

# Copia os arquivos do website para o diretório raiz do Nginx
COPY website/ /usr/share/nginx/html/

# Expõe a porta 80 do container
EXPOSE 80

# Inicia o servidor Nginx em primeiro plano
CMD ["nginx", "-g", "daemon off;"]
