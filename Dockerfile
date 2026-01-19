FROM python:3.12-slim-bookworm

ARG TZ=Asia/Shanghai
ENV TZ=${TZ} \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    TG_SIGNER_DATA_DIR=/app/data

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    tzdata && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN pip install --no-cache-dir .[speedup,gui]
RUN mkdir -p /app/data
VOLUME /app/data

ENTRYPOINT ["tg-signer"]
CMD ["--help"]


