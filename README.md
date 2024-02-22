# Parlament
Application show current state of Parlament, I mean presence of crew ;)

## Requirements

* PostgreSQL
* Redis
* vips (libvips)

## Installation

Recommended way is to use docker. See docker-compose.yml file.

### .env file

```
POSTGRES_USER=parlament
POSTGRES_PASSWORD=changeme
DATABASE_NAME=parlament
DATABASE_HOST=postgres
RAILS_MASTER_KEY=your_master_key_here
```

### post-install
Needs run migration and install Spina CMS.

```bash
be rails spina:first_deploy
# OR ?
be rails spina:bootstrap
```
## Credentials
List of used credentials, encrypted.
```yaml
presence_api_key: your_api_key_here
```

There are two option for authentication:
1. use HTTP Authorization header
2. use parameter `key` in query string

## Presence reporting
* `state=On`
* `state=Off`
```bash
curl -X POST -H "Authorization: Token your_api_key" https://<url>/parlament/presence/On
```
or 
```bash
curl -X POST https://<url>/parlament/presence/On?key=your_api_key
```
