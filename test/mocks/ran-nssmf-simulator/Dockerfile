FROM onap/integration-python:10.0.0

USER root

WORKDIR /home/onap
COPY ./requirements.txt ./

RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

ENV user=onap group=onap
USER onap

ENV PATH=$PATH:/home/onap/.local/bin

COPY --chown=onap:onap main.py /home/onap
COPY --chown=onap:onap setup.py /home/onap
COPY --chown=onap:onap RanNssmfSimulator /home/onap/RanNssmfSimulator

RUN chmod 770 /home/onap/main.py && \
    chmod 770 /home/onap/setup.py && \
    chmod 770 -R /home/onap/RanNssmfSimulator

CMD [ "python3", "main.py" ]

