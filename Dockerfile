FROM prantlf/vlang AS builder

WORKDIR /src
COPY . .
RUN make RELEASE=1

FROM scratch
LABEL maintainer="Ferdinand Prantl <prantlf@gmail.com>"

COPY --from=builder /src/healthchk /
