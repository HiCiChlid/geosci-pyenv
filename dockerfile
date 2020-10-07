FROM ubuntu:18.04

#user
#USER root

#encoding
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

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
    && apt-get install -y wget

# install ssh server about the remote operation
RUN apt-get install -y openssh-server \
    && mkdir /var/run/sshd \
    && echo "root:249784435" | chpasswd
# container needs to open SSH 22 port for visiting from outsides.
EXPOSE 22

# install JAVA
RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH $CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH

# install spark
WORKDIR /usr/local
RUN wget "http://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-hadoop2.7.tgz" \
    && tar -vxf spark-* \
    && mv spark-2.4.5-bin-hadoop2.7 spark \
    && rm -rf spark-2.4.5-bin-hadoop2.7.tgz
ENV SPARK_HOME /usr/local/spark
EXPOSE 6066 8080 7077 4044 18080 8888
ENV PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$SPARK_HOME/bin$PATH

# install python3
RUN apt install -y python3.6 \
&& apt install -y ipython3 \
&& apt install -y python3-pip \
&& ln -sf /usr/bin/python3.6 /usr/bin/python \
&& ln -sf /usr/bin/pip3 /usr/bin/pip

# install the dependence of igraph, rtree, geopandas, pysal 
RUN apt-get install -y zlib1g-dev \
    && apt-get install -y libxml2-dev \
    && apt-get install -y build-essential \ 
    && apt-get install -y libffi-dev \
    && apt-get install -y libcairo-dev \
    && apt-get install -y libtool \
    && apt-get install -y m4 \
    && apt-get install -y automake \
    && apt-get install -y bison flex \
    && apt-get install -y libigraph0-dev \
    && apt-get install -y libspatialindex-dev \
    && apt-get install -y libllvm-10-ocaml-dev libllvm10 llvm-10 llvm-10-dev llvm-10-doc llvm-10-examples llvm-10-runtime
ENV LLVM_CONFIG /usr/bin/llvm-config-10

#  install python3 packages
RUN pip3 install bs4 \ 
&& pip3 install Django \ 
&& pip3 install pandas \ 
&& pip3 install findspark \ 
&& pip3 install jupyter \ 
&& pip3 install joblib \
&& pip3 install psycopg2-binary \ 
&& pip3 install scikit-learn\ 
&& pip3 install pyemail  \ 
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
&& pip3 install prompt-toolkit==1.0.15 \
&& pip3 install python-igraph \
&& pip3 install sympy \
&& pip3 install mgwr \
&& pip3 install rtree \
&& pip3 install pysal \
&& pip3 install libpysal \
&& pip3 install nbconvert==5.4.1

# set default homepath
WORKDIR /home

# create jupyter shortcuts
RUN touch jp.sh \
&& echo jupyter notebook --ip=0.0.0.0 --no-browser --allow-root > jp.sh

CMD /bin/bash