FROM nexus3.onap.org:10001/onap/integration-python:8.0.0

COPY . /app

WORKDIR /app
ARG HTTP_PROXY=http://10.144.1.10:8080
ARG HTTPS_PROXY=http://10.144.1.10:8080
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 2222 2223
