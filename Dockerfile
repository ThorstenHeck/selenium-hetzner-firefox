FROM selenium/standalone-firefox

WORKDIR /home/seluser

RUN sudo apt-get update -y && sudo apt-get install python3-pip -y
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY hetzner_login/ /home/seluser

ENTRYPOINT ["python3","hetzner_login.py"]