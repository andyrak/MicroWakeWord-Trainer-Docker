# ARM64 Ubuntu base
FROM arm64v8/ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl git unzip software-properties-common build-essential \
    libsndfile1 libffi-dev g++ cmake python3-dev \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python 3.10 from source
RUN curl -O https://www.python.org/ftp/python/3.10.14/Python-3.10.14.tgz && \
    tar -xzf Python-3.10.14.tgz && \
    cd Python-3.10.14 && \
    ./configure --enable-optimizations && make -j$(nproc) && make altinstall && \
    cd .. && rm -rf Python-3.10.14 Python-3.10.14.tgz

# Install pip for Python 3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

# Install Python requirements
ADD https://raw.githubusercontent.com/andyrak/MicroWakeWord-Trainer-Docker/refs/heads/main/requirements.txt /tmp/requirements.txt
RUN python3.10 -m pip install --no-cache-dir -r /tmp/requirements.txt
RUN python3.10 -m pip install --no-cache-dir numpy==1.26.4

# Create a data directory
RUN mkdir -p /data

# Add notebooks
ADD https://raw.githubusercontent.com/andyrak/MicroWakeWord-Trainer-Docker/refs/heads/main/basic_training_notebook.ipynb /root/basic_training_notebook.ipynb
ADD https://raw.githubusercontent.com/andyrak/MicroWakeWord-Trainer-Docker/refs/heads/main/advanced_training_notebook.ipynb /root/advanced_training_notebook.ipynb

# Add startup script
ADD https://raw.githubusercontent.com/andyrak/MicroWakeWord-Trainer-Docker/refs/heads/main/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

WORKDIR /data

EXPOSE 8888

CMD ["/bin/bash", "-c", "/usr/local/bin/startup.sh && jupyter notebook --ip=0.0.0.0 --no-browser --allow-root --NotebookApp.token='' --notebook-dir=/data"]
