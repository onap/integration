FROM python:2

ENV https_proxy "$https_proxy"
ENV TZ=Europe/Warsaw

ADD DMaaP.py /
ADD CommonEventFormat_28.3.json / 

RUN pip install jsonschema robotframework

EXPOSE 2222

CMD [ "python", "./DMaaP.py" ]