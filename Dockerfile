# Etap 1: Budowanie aplikacji
FROM alpine AS builder

# Instalacja narzędzi
RUN apk add --no-cache bash curl

# Ustawienie katalogu roboczego
WORKDIR /app

# Deklaracja zmiennej środowiskowej
ARG VERSION
ENV VERSION=$VERSION

# Tworzenie skryptu generującego index.html w momencie uruchomienia kontenera
RUN echo '#!/bin/sh' > entrypoint.sh && \
    echo 'echo "<h1>Informacje o serwerze</h1>" > /usr/share/nginx/html/index.html' >> entrypoint.sh && \
    echo 'echo "<p>Adres IP serwera: $(hostname -i || echo \"Nieznany\")</p>" >> /usr/share/nginx/html/index.html' >> entrypoint.sh && \
    echo 'echo "<p>Nazwa hosta: $(hostname)</p>" >> /usr/share/nginx/html/index.html' >> entrypoint.sh && \
    echo 'echo "<p>Wersja aplikacji: $VERSION</p>" >> /usr/share/nginx/html/index.html' >> entrypoint.sh && \
    chmod +x entrypoint.sh

# Etap 2: Serwer HTTP (Nginx)
FROM nginx:latest

# Ustawienie zmiennej ENV, żeby była dostępna w kontenerze
ARG VERSION
ENV VERSION=$VERSION

# Kopiowanie skryptu startowego
COPY --from=builder /app/entrypoint.sh /entrypoint.sh

# Uruchomienie skryptu i start serwera
CMD ["sh", "-c", "/entrypoint.sh && exec nginx -g 'daemon off;'"]

# Sprawdzanie, czy serwer działa (HEALTHCHECK)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost || exit 1

# Eksponowanie portu 80
EXPOSE 80
