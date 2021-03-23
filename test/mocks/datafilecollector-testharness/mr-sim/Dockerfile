FROM nexus3.onap.org:10001/onap/integration-python:8.0.0

COPY . /app

WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 2222 2223
