FROM python:3.6

WORKDIR /app

COPY src/requirements.txt ./
ARG HTTP_PROXY=http://10.144.1.10:8080
ARG HTTPS_PROXY=http://10.144.1.10:8080
RUN pip install --no-cache-dir -r requirements.txt

COPY src /app

EXPOSE 8000

CMD ["python", "ProvMnSProvider.py"]
