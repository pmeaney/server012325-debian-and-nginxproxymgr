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

## Creating Proxy Hosts

Now we're ready to setup access into the containers, from the public internet.

- Click into the Proxy Host section of Nginx Proxy Manager (running at http://yourServerIP:81 (that's http, not https!))
- In the upper right corner, click 'Add Proxy Host'.\*\*\*\*
- We'll only be working with two screens:
  - New Proxy Host - "Details" Tab
    - Default settings you can leave:
    - "Scheme: `http`" (it's set as default)
    - Set up your `Domain Name`, `Forward Hostname/IP`, and `Forward Port` as specified in the table below, or based on your own settings

#### Re: Http vs Https -- When we create these Nginx Proxy Mgr configurations ("Proxy Hosts"), we'll have it automatically request Let's Encrypt SSL certs for each domain or subdomain we create. So, these will all be accessed at https:// instead of http://

### Now for our domain definitions...

Note:

- Set `Forward Hostname / IP` to the Docker Engine's IP. You can find it by running this: `ip addr show docker0` (usually its 172.17.0.1)
- `Forward Port` is the application port, running in a docker container, depending on what app you've setup to run and its specified exposed ports.
- set 'block common exploits' to on.

- Somtimes NPM can be finnicky, especially after it starts up, or after you try to re-create certs with the same domain, but on a new server. Try again if there's an internal error with npm during its automatic lets encrypt cert attempts.

| Purpose        | Domain Name          | Forward Hostname / IP | Forward Port | Description                                             |
| -------------- | -------------------- | --------------------- | ------------ | ------------------------------------------------------- |
| Base Domain    | myDomainName.com     | 172.17.0.1            | 3000         | Main NextJS application running on Docker network       |
| WWW Subdomain  | www.myDomainName.com | 172.17.0.1            | 3000         | Standard www prefix pointing to main NextJS application |
| CMS Subdomain  | cms.myDomainName.com | 172.17.0.1            | 1337         | Access point for Strapi CMS administration              |
| DNS Management | dns.myDomainName.com | 172.17.0.1            | 81           | Nginx Proxy Manager administration interface            |

On the SSL Certificate Tab of "New Proxy Host",

- Request a new SSL certificate
- enter your email
- switch "I agree to the Lets Encrypt Terms of Service" to on.
- Click save.
- If it fails, try again.
