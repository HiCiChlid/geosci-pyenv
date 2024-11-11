FROM ubuntu:24.04

#user
#USER root

#encoding
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# change to Mainland apt update source
#RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
#    && apt-get clean \
#    && apt-get update

# install some tools
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get remove -y vim-common \
    && apt-get install -y vim \
    && apt-get install -y git \
    && apt-get install -y wget \
    && apt-get install -y libssl-dev \
    && apt-get install -y net-tools \
    && apt-get install -y iputils-ping \
    && apt-get install -y libcurl4-openssl-dev

# install JAVA
RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH $CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH

# install spark
WORKDIR /usr/local
RUN wget "https://archive.apache.org/dist/spark/spark-3.2.1/spark-3.2.1-bin-hadoop2.7.tgz" \
    && tar -vxf spark-* \
    && mv spark-3.2.1-bin-hadoop2.7 spark \
    && rm -rf spark-3.2.1-bin-hadoop2.7.tgz
ENV SPARK_HOME /usr/local/spark
EXPOSE 6066 8080 7077 4044 18080 8888

# install hadoop
WORKDIR /usr/local
RUN wget "http://archive.apache.org/dist/hadoop/core/hadoop-2.7.7/hadoop-2.7.7.tar.gz" \
    && tar -vxf hadoop-* \
    && mv hadoop-2.7.7 hadoop \
    && rm -rf hadoop-2.7.7.tar.gz
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin$PATH
EXPOSE 50010 50075 50475 50020 50070 50470 8020 8485 8480 8019

# install python3
RUN apt install -y python3.12 \
&& apt install -y ipython3 \
&& apt install -y python3-pip \
&& apt install -y python3-venv \
&& apt install -y python3-full \
&& rm -rf /var/lib/apt/lists/*

# install the dependence of igraph, rtree, geopandas, pysal 
RUN apt-get -y update \
    && apt-get install -y zlib1g-dev \
    && apt-get install -y build-essential \ 
    && apt-get install -y libtool \
    && apt-get install -y m4 \
    && apt-get install -y automake \
    && apt-get install -y bison flex \
    && apt-get install -y libspatialindex-dev
ENV LLVM_CONFIG /usr/bin/llvm-config-10

#  install python3 packages
WORKDIR /app
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
RUN pip3 install --upgrade pip \
    && pip3 install bs4 \
    && pip3 install Django \
    && pip3 install pandas \
    && pip3 install findspark \
    && pip3 install jupyter \
    && pip3 install joblib \
    && pip3 install psycopg2-binary \
    && pip3 install scikit-learn \
    && pip3 install pyemail \
    && pip3 install progressbar2 \
    && pip3 install pyecharts \
    && pip3 install pyspark \
    && pip3 install requests \
    && pip3 install Scrapy \
    && pip3 install seaborn \
    && pip3 install selenium \
    && pip3 install sqlalchemy \
    && pip3 install vector-2d \
    && pip3 install pyarrow \
    && pip3 install pydot \
    && pip3 install pandarallel \
    && pip3 install geopandas \
    && pip3 install descartes \
    && pip3 install yellowbrick \
    && pip3 install xlrd \
    && pip3 install xlwt \
    && pip3 install wkhtmltopdf \
    && pip3 install DateTime \
    && pip3 install async-timeout \
    && pip3 install tqdm \
    && pip3 install networkx \
    && pip3 install prompt-toolkit \
    && pip3 install python-igraph \
    && pip3 install sympy \
    && pip3 install mgwr \
    && pip3 install rtree \
    && pip3 install pysal \
    && pip3 install libpysal \
    && pip3 install nbconvert

#  install Qgis
RUN apt -y update
RUN apt install -y gnupg software-properties-common
RUN wget -qO - https://qgis.org/downloads/qgis-2022.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
RUN chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
RUN add-apt-repository -y "deb https://qgis.org/ubuntu $(lsb_release -c -s) main"
RUN apt -y update
RUN apt -y install qgis qgis-plugin-grass saga
ENV PATH=$PATH:/usr/share/qgis/python/plugins:/usr/lib/qgis$PATH

# install ssh server about the remote operation
RUN apt-get install -y openssh-server \
    && mkdir -p /var/run/sshd \
    && echo "root:abc123" | chpasswd
# allow rootssh login
RUN sed -i "s/#\?PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN sed -i "s/#\?PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN sed -i "s/#\?PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

# container needs to open SSH 22 port for visiting from outsides.
EXPOSE 22
ENTRYPOINT service ssh restart && bash

# set default homepath and default python
WORKDIR /home
RUN ln -sf /usr/bin/python3.12 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip
    
# create jupyter shortcuts
RUN touch jp.sh \
&& echo jupyter notebook --ip=0.0.0.0 --no-browser --allow-root > jp.sh
RUN touch gs.sh \
&& echo ssh-keygen -t rsa -P \'\' -f ~/.ssh/id_rsa > gs.sh

CMD /bin/bash
