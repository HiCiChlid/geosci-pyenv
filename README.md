# geosci-pyenv

## Contents:
1. python3
2. R
3. Spark
4. QGIS

## How to install it:
### Method 1
1. Download docker and install it (https://www.docker.com/get-started).
2. Start docker using `systemctl start docker.service` in Linux; 
                   or `sudo service docker start` in WSL2 linux-sub-system in Windows;
                   or double click docker icons to make sure it open in Windows/MacOS.
3. RUN 

   `docker build -t [your_image_name]:[version] https://raw.githubusercontent.com/HiCiChlid/geosci-pyenv/main/dockerfile`

6. Wait for it to finish.

-----
### Method 2
1. Download docker and install it (https://www.docker.com/get-started).
2. Start docker using `systemctl start docker.service` in Linux; 
                   or `sudo service docker start` in WSL2 linux-sub-system in Windows;
                   or double click docker icons to make sure it open in Windows/MacOS.
3. Download dockerfile (https://github.com/HiCiChlid/geosci-pyenv/blob/main/dockerfile) to the specified location.
4. Open Terminal or CMD, and locate to the specified location using `cd` (in Windows for switching to another volume, you can directly input the volume mark in the CMD, e.g., `D:`).
5. Run 

   `docker build -t [your_image_name]:[version] [dockerfile location]`, e.g., `docker build -t test:v1 .`
   
6. Wait for it to finish.

## How to use it:
1. Open Terminal and make sure docker is open.
2. Run 

   `docker run -v [connected_path_in_your_computer]:/home/current -id --name=[container_name] -p 8888:8888 -p 4040:4040  --shm-size 2g [your_image_name]:[version]`

   **Note that**: in windows, `[connected_path_in_your_computer]` is in the format of `/mnt/d/"path with space/next layer/next layer"`

3. In windows, if you hope to exploit your Nvidia GUP in docker, you can download and install the driver first (https://developer.nvidia.com/cuda/wsl/download), and then run

   `docker run -v [connected_path_in_your_computer]:/home/current -id --name=[container_name] -p 8888:8888 -p 4040:4040  --shm-size 2g --gpus all [your_image_name]:[version]`
   
6. After container building, you can start your container through 

   `docker exec -it [container_name] /bin/bash`
   
8. you can use `sh jp.sh` to start Jupyter notebook.
