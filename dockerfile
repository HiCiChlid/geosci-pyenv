FROM ubuntu:18.04

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
RUN pip3 install --upgrade pip \
&& pip3 install bs4==0.0.1 \ 
&& pip3 install Django==3.1.2 \ 
&& pip3 install pandas==1.1.3 \ 
&& pip3 install findspark==1.4.2 \ 
&& pip3 install jupyter==1.0.0 \ 
&& pip3 install joblib==0.17.0 \
&& pip3 install psycopg2-binary==2.8.6 \ 
&& pip3 install scikit-learn==0.23.2\ 
&& pip3 install pyemail==0.0.1  \ 
&& pip3 install progressbar2==3.53.1 \ 
&& pip3 install pyecharts==1.8.1 \ 
&& pip3 install pyspark==3.0.1 \ 
&& pip3 install requests==2.18.4 \ 
&& pip3 install Scrapy==2.3.0 \ 
&& pip3 install seaborn==0.11.0 \ 
&& pip3 install selenium==3.141.0 \ 
&& pip3 install sqlalchemy==1.3.19 \
&& pip3 install vector-2d==1.5.2 \ 
&& pip3 install pyarrow==1.0.1 \ 
&& pip3 install pydot==1.4.1 \ 
&& pip3 install pandarallel==1.5.1 \ 
&& pip3 install geopandas==0.8.1 \ 
&& pip3 install descartes==1.1.0 \
&& pip3 install yellowbrick==1.1 \ 
&& pip3 install xlrd==1.2.0 \ 
&& pip3 install xlwt==1.3.0 \ 
&& pip3 install wkhtmltopdf==0.2 \ 
&& pip3 install DateTime==4.3 \ 
&& pip3 install async-timeout==3.0.1 \
&& pip3 install tqdm==4.50.1 \
&& pip3 install networkx==2.5 \
&& pip3 install prompt-toolkit==1.0.15 \
&& pip3 install python-igraph==0.8.2 \
&& pip3 install sympy==1.6.2 \
&& pip3 install mgwr==2.1.2 \
&& pip3 install rtree==0.9.4 \
&& pip3 install pysal==2.3.0 \
&& pip3 install libpysal==4.3.0 \
&& pip3 install nbconvert==5.4.1 \
&& pip3 install koalas==1.8.2

#  install Qgis
RUN apt -y update
RUN apt install -y gnupg software-properties-common
RUN wget -qO - https://qgis.org/downloads/qgis-2021.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import
RUN chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg
RUN add-apt-repository -y "deb https://qgis.org/ubuntu $(lsb_release -c -s) main"
RUN apt -y update
RUN apt -y install qgis qgis-plugin-grass saga
ENV PATH=$PATH:/usr/share/qgis/python/plugins:/usr/lib/qgis$PATH

# install R 3.4
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
#RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/'
#RUN apt update
RUN apt install -y r-base r-base-core r-recommended
ENV PATH=$PATH:/usr/lib/R/lib$PATH
RUN R -e "options(repos=structure( c(CRAN='https://cloud.r-project.org/')))"
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/pbdZMQ/pbdZMQ_0.3-0.tar.gz', type='source')"
RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'devtools', 'uuid', 'digest'))"
RUN R -e "devtools::install_github('IRkernel/IRkernel')"
RUN R -e "IRkernel::installspec(user = FALSE)"

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

# set default homepath
WORKDIR /home

# create jupyter shortcuts
RUN touch jp.sh \
&& echo jupyter notebook --ip=0.0.0.0 --no-browser --allow-root > jp.sh
RUN touch gs.sh \
&& echo ssh-keygen -t rsa -P \'\' -f ~/.ssh/id_rsa > gs.sh

CMD /bin/bash
