FROM python:2.7

WORKDIR /opt/generic_sim
ADD ./  /opt/generic_sim

RUN pip install web.py

EXPOSE 8081

ENV NAME generic_sim

CMD ["/bin/sh", "-c", "python -u generic_sim.py 8081 > /generic_sim_logs/generic_sim.log 2>&1"]
