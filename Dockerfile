FROM ubuntu:18.04
RUN apt-get update && apt-get install -y curl make gcc g++ git python3 cmake supervisor nginx
ENV GOLANG_VERSION 1.17
ENV GOLANG_DOWNLOAD_SHA256 6bf89fc4f5ad763871cf7eac80a2d594492de7a818303283f1366a7f6a30372d
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
RUN mkdir -p /work/src
RUN mkdir -p /work/bin/plugins

# full node config
RUN cd /work/src && git clone https://github.com/CortexFoundation/CortexTheseus.git \
  && cd CortexTheseus \
  && git checkout e75a2ad9c3fbd40011acd31887dfbfbe59a998c2 \
  && make

RUN cp -r /work/src/CortexTheseus/build/bin/cortex /work/bin/
RUN cp /work/src/CortexTheseus/plugins/* /work/bin/plugins

WORKDIR /work/bin

RUN ls -alt /work/bin/plugins

RUN rm -rf /work/src/CortexTheseus

# tracker config
RUN cd /work/src && git clone https://github.com/chihaya/chihaya.git \
  && cd chihaya \
  && git checkout 057f7afefc383717e7ba9d95ec6622aa950de272 \
  && go build ./cmd/chihaya

RUN cp -r /work/src/chihaya/chihaya /work/bin/
COPY chihaya.yaml /etc

RUN rm -rf /work/src/chihaya

# finally
RUN ls /etc/supervisor/conf.d/
RUN ls /work/bin

COPY conf.d/node.conf /etc/supervisor/conf.d/
COPY nginx.conf /etc/nginx/conf.d/
RUN service nginx restart
#COPY conf.d/tracker.conf /etc/supervisor/conf.d/
# if you want to use a specified supervisor conf
RUN cat /etc/supervisor/conf.d/node.conf

CMD supervisord -n -c /etc/supervisor/supervisord.conf

EXPOSE 5008 8545 8546 8547 37566 30089 40404 5008/udp 40404/udp 40401 40401/udp
