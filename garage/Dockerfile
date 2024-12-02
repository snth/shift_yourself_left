FROM debian:bookworm-slim
# FROM dxflrs/garage:v1.0.1
COPY --from=dxflrs/garage:v1.0.1 /garage /

RUN apt-get update && apt-get install -y openssl

WORKDIR /

COPY init.sh .

ENTRYPOINT ["/bin/bash"]
CMD ["init.sh"]
