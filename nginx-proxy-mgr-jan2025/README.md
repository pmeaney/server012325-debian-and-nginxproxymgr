### Nginx Proxy Manager

Copied from here-- the npm & postgres services
https://nginxproxymanager.com/setup/

I added container_names.

```bash
# This command is to Run in background, then check out logs.  It's a nice way to view the running container, while leaving it running after you exit the logs view.
cd nginx-proxy-mgr-jan2025 && \
docker compose -vvv -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-012825
```
