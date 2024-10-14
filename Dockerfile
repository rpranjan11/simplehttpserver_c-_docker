# GCC support can be specified at major, minor, or micro version
# (e.g. 8, 8.2 or 8.2.0).
# See https://hub.docker.com/r/library/gcc/ for all supported GCC
# tags from Docker Hub.
# See https://docs.docker.com/samples/library/gcc/ for more on how to use this image

# simplehttpserver build stage
FROM alpine:3.17.0 AS build

RUN apk update && \ 
    apk add --no-cache \
    build-base \
    cmake \
    boost1.80-dev=1.80.0-r3

WORKDIR /simplehttpserver

COPY src/ ./src/
COPY CMakeLists.txt .

WORKDIR /simplehttpserver/build

RUN cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --parallel 8

# simplehttpserver image
FROM alpine:3.17.0

RUN apk update && \
    apk add --no-cache \
    libstdc++ \
    boost1.80-program_options=1.80.0-r3

RUN addgroup -S shs && adduser -S shs -G shs
USER shs

COPY --chown=shs:shs --from=build \
    ./simplehttpserver/build/src/simplehttpserver \
    ./app/

ENTRYPOINT [ "./app/simplehttpserver" ]
