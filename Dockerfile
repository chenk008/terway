FROM golang:1.9.4 as builder
WORKDIR /go/src/gitlab.alibaba-inc.com/cos/terway/
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-X \"main.gitVer=`git rev-parse --short HEAD 2>/dev/null`\" " -o terwayd .
RUN cd plugin && CGO_ENABLED=0 GOOS=linux go build -o terway .

FROM registry.aliyuncs.com/wangbs/netdia:latest
COPY script/ /bin/
RUN apk --update add ipset bash && chmod +x /bin/traffic && chmod +x /bin/policyinit.sh && rm -f /var/cache/apk/*
RUN curl -sSL -o /bin/calico-felix https://docker-plugin.oss-cn-shanghai.aliyuncs.com/calico-felix && chmod +x /bin/calico-felix
COPY --from=builder /go/src/gitlab.alibaba-inc.com/cos/terway/terwayd /usr/bin/terwayd
COPY --from=builder /go/src/gitlab.alibaba-inc.com/cos/terway/plugin/terway /usr/bin/terway
ENTRYPOINT ["/usr/bin/terwayd"]
