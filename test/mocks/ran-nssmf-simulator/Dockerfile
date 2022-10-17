FROM python:3.8.14-slim-bullseye

WORKDIR /usr/src/app
COPY ./requirements.txt ./
COPY ./main.py ./
COPY ./setup.py ./
COPY ./RanNssmfSimulator ./RanNssmfSimulator

RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python3", "main.py" ]

