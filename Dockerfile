FROM ubuntu:18.04 as golang-builder
RUN apt-get update && apt-get install -y curl make gcc g++ git python3 cmake supervisor
ENV GOLANG_VERSION 1.16.5
ENV GOLANG_DOWNLOAD_SHA256 b12c23023b68de22f74c0524f10b753e7b08b1504cb7e417eccebdd3fae49061
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
  && git checkout 72e848aaa7215a15df53496925b1a5b14546f30f \
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
#COPY conf.d/tracker.conf /etc/supervisor/conf.d/
# if you want to use a specified supervisor conf
# RUN cat /etc/supervisor/conf.d/node.conf

CMD supervisord -n -c /etc/supervisor/supervisord.conf

EXPOSE 5008 8545 8546 8547 37566 40404 5008/udp 40404/udp 40401 40401/udp
