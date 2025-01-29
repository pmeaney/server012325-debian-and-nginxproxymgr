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

- Access NPM admin panel at `http://<server-ip>:81`
  - Default credentials:
    - Username: admin@example.com
    - Password: changeme

These are the settings I tend to use:

Default settings you can leave:

- Scheme: `http` (it's set as default)

When we create these Nginx Proxy Mgr configurations ("Proxy Hosts"), we'll have it automatically request Let's Encrypt SSL certs for each domain or subdomain we create. So, these will all be accessed at https:// instead of http://

Now for our domain definitions...

| Purpose        | Domain Name          | Forward Hostname / IP | Forward Port | Description                                             |
| -------------- | -------------------- | --------------------- | ------------ | ------------------------------------------------------- |
| Base Domain    | myDomainName.com     | 172.17.0.1            | 3000         | Main NextJS application running on Docker network       |
| WWW Subdomain  | www.myDomainName.com | 172.17.0.1            | 3000         | Standard www prefix pointing to main NextJS application |
| CMS Subdomain  | cms.myDomainName.com | 172.17.0.1            | 1337         | Access point for Strapi CMS administration              |
| DNS Management | dns.myDomainName.com | 172.17.0.1            | 81           | Nginx Proxy Manager administration interface            |
