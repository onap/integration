FROM python:2.7

EXPOSE 8080

RUN mkdir -p /{tmp,etc}/generic_sim

WORKDIR /opt/generic_sim/

COPY . .
RUN pip install --no-cache-dir -r requirements.txt

CMD [ "python", "generic_sim.py" ]
