FROM manjarolinux/base:latest

# Set locale and timezone
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update and install tools and dependencies
RUN pacman -Sy archlinux-keyring manjaro-keyring
RUN pacman -Sy --noconfirm \
    vim git wget jre-openjdk \
    python python-pip ipython \
    zlib libxml2 base-devel \
    gcc llvm llvm-libs \
    cairo libtool m4 automake bison flex \
    igraph spatialindex \
    openssh gnupg zsh powerline powerline-fonts powerline-vim
    
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# 设置主题为 agnoster
RUN echo "ZSH_THEME=\"agnoster\"" >> ~/.zshrc

# 安装 Powerline 相关配置
RUN echo "powerline-daemon -q" >> ~/.zshrc && \
echo "POWERLINE_BASH_CONTINUATION=1" >> ~/.zshrc && \
echo "POWERLINE_BASH_SELECT=1" >> ~/.zshrc && \
echo "source /usr/share/powerline/bindings/zsh/powerline.zsh" >> ~/.zshrc

# 配置字体（确保终端字体支持 powerline）
#RUN mkdir -p ~/.local/share/fonts && \
#    cp /usr/share/fonts/TTF/* ~/.local/share/fonts/ && \
#    fc-cache -vf ~/.local/share/fonts/

# Clean up
RUN pacman -Scc --noconfirm

# Install Miniconda
WORKDIR /tmp
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Update Conda and configure the path
ENV PATH=/opt/conda/bin:$PATH
RUN conda update -n base -c defaults conda

# Create a Conda environment and install packages
RUN conda create -y -n myenv python=3.10 && \
    conda install -n myenv -y \
    beautifulsoup4 \
    django \
    pandas \
    jupyter \
    joblib \
    psycopg2 \
    scikit-learn \
    requests \
    scrapy \
    seaborn \
    sqlalchemy \
    pyarrow \
    pydot \
    pandarallel \
    geopandas \
    descartes \
    yellowbrick \
    xlrd \
    xlwt \
    tqdm \
    networkx \
    conda-forge::python-igraph \
    conda-forge::libgdal \
    sympy \
    mgwr \
    rtree \
    pysal \
    libpysal \
    nbconvert \
    pymc3 \
    plotly \
    conda-forge::powerline-status

# Install Spark
WORKDIR /usr/local
RUN wget "https://archive.apache.org/dist/spark/spark-3.2.1/spark-3.2.1-bin-hadoop2.7.tgz" && \
    tar -xvzf spark-3.2.1-bin-hadoop2.7.tgz && \
    mv spark-3.2.1-bin-hadoop2.7 spark && \
    rm spark-3.2.1-bin-hadoop2.7.tgz

# Install Hadoop
RUN wget "http://archive.apache.org/dist/hadoop/core/hadoop-2.7.7/hadoop-2.7.7.tar.gz" && \
    tar -xvzf hadoop-2.7.7.tar.gz && \
    mv hadoop-2.7.7 hadoop && \
    rm hadoop-2.7.7.tar.gz

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk
ENV SPARK_HOME /usr/local/spark
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH=$PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# SSH server setup
RUN mkdir -p /var/run/sshd && echo "root:abc123" | chpasswd && \
    sed -i "s/#\?PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Expose ports
EXPOSE 22
EXPOSE 6066 8080 7077 4044 18080 8888
EXPOSE 50010 50075 50475 50020 50070 50470 8020 8485 8480 8019

# Set default homepath and default python in Conda environment
WORKDIR /home
RUN echo 'source activate myenv' > ~/.bashrc

# Create Jupyter shortcuts
RUN echo 'jupyter notebook --ip=0.0.0.0 --no-browser --allow-root' > jp.sh && \
    echo 'ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa' > gs.sh

RUN chsh -s /bin/zsh

CMD ["/bin/zsh"]
