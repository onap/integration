FROM python:3.6

WORKDIR /app

COPY src/requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY src /app

EXPOSE 8000

CMD ["python", "ProvMnSProvider.py"]
