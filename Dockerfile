FROM python:3.12-slim-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends gcc python3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

# 构建 wheel 包
RUN pip wheel --no-cache-dir -w dist .[speedup,gui]

FROM python:3.12-slim-bookworm

ARG TZ=Asia/Shanghai
ENV TZ=${TZ} \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从构建阶段复制 wheel 并安装
COPY --from=builder /build/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && \
    rm -rf /tmp/*

# 创建数据目录
RUN mkdir -p /app/data

# 设置环境变量
ENV TG_SIGNER_DATA_DIR=/app/data

VOLUME /app/data

ENTRYPOINT ["tg-signer"]
CMD ["--help"]

