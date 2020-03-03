FROM python:2.7

WORKDIR /app

COPY src/requirements.txt ./ 

RUN pip install -r requirements.txt

COPY src /app

EXPOSE 8000

CMD ["python", "ProvMnSProvider.py"]
