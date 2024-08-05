ARG BASETAG="15.7"
FROM postgres:${BASETAG}

ENV POSTGRES_DB="**None**" \
    POSTGRES_HOST="**None**" \
    POSTGRES_PORT=5432 \
    POSTGRES_USER="**None**" \
    POSTGRES_PASSWORD="**None**" \
    BACKUP_DIR="/backups" \
    BACKUP_N_KEEP="5" \ 
    TELEGRAM_BOT_TOKEN="**None**" \ 
    TELEGRAM_CHAT_ID="**None**" 

VOLUME /backups
    
RUN apt update -y \
    && apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git \
    && curl https://pyenv.run | bash \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \ 
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \ 
    && echo 'eval "$(pyenv init --path)"' >> ~/.bashrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc \
    && exec $SHELL 
    
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

RUN . ~/.bashrc  \
    && pyenv install 3.11.9 \
    && pyenv global 3.11.9

COPY requirements.txt /requirements.txt
RUN . ~/.bashrc  \
    && python -m pip install -r requirements.txt

COPY backup.sh /backup.sh
COPY backup.py /backup.py
ENTRYPOINT ["/bin/sh", "-c"]
CMD [ "/backup.sh" ]
