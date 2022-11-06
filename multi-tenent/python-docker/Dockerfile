FROM python:3
LABEL maintainer="srinivas@opsmx.io"

# Install dependencies.
RUN pip install --no-cache-dir requests

RUN useradd -m opsmx
USER opsmx
ENV PATH=$PATH:/home/opsmx/.local/bin
