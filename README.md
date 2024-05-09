# Check Health of a HTTP Server

Checks health of a HTTP server. Makes a request, prints the result and exits with zero (success) or non-zero (failure) Suitable for [HEALTHCHECK in Dockerfile] or [healthcheck in docker-compose.yml].

```
❯ healthchk https://github.com
status: 200, type: text/html; charset=utf-8, size: 229912 bytes, duration: 2042 ms
```

* No dependencies (linked statically)
* Small size (700 kB)
* Easy to integrate (from builder Docker image)

## Synopsis

An example of `Dockerfile`:

```Dockerfile
FROM prantlf/healthchk as healthchk

FROM ...
COPY --from=healthchk /healthchk /
...
HEALTHCHECK --interval=1m CMD /healthchk http://localhost/ping || exit 1
```

An example of `docker-compose.yml`:

```yml
services:
  service:
    healthcheck:
      test: ["CMD", "/healthcheck", "http://localhost/ping"]
      interval: 1m
    restart: unless-stopped
```

## Configuration

```
usage: healthchk [option ...] <url>
options:
  -m <method>   HTTP method to use (default: GET)
  -t <seconds>  connection timeout (default: 30 seconds)
  -R            disallow redirects (default: allowed)
  -s            print nothing on success (default: no)
  -v            print the response body too (default: no)
```

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (C) 2024 Ferdinand Prantl

Licensed under the [MIT License].

[MIT License]: http://en.wikipedia.org/wiki/MIT_License
[HEALTHCHECK in Dockerfile]: https://docs.docker.com/reference/dockerfile/#healthcheck
[healthcheck in docker-compose.yml]: https://docs.docker.com/compose/compose-file/05-services/#healthcheck