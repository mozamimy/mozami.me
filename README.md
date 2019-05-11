# mozami.me

Source of [https://mozami.me/](https://mozami.me/).

They are supposed to build with [salmon](https://github.com/mozamimy/salmon).

## Build

```sh
docker-compose pull # If needed
docker-compose run salmon salmon build
```

## Server

```sh
docker-compose up nginx
```
