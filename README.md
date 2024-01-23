# Parlament
Application show current state of Parlament, I mean presence of crew ;)

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
