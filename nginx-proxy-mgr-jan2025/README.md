### Nginx Proxy Manager

Copied from here-- the npm & postgres services
https://nginxproxymanager.com/setup/

I added container_names.

# Run in background, then check out logs:

cd nginx-proxy-mgr-jan2025 && \
docker compose -vvv -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-012825
