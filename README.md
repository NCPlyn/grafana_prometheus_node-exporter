# Guide to install __Prometheus__ & __Grafana__ & __node_exporter__

## Prometheus:
- Create user, folders and set privileges for Prometheus
    ```
    sudo useradd --no-create-home --shell /bin/false prometheus
    sudo mkdir /etc/prometheus
    sudo mkdir /var/lib/prometheus
    sudo chown prometheus:prometheus /etc/prometheus
    sudo chown prometheus:prometheus /var/lib/prometheus
    ```
- Download Prometheus and extract files from archive
    ```
    sudo wget https://github.com/prometheus/prometheus/releases/download/v2.37.1/prometheus-2.37.1.linux-amd64.tar.gz
    sudo tar -xvf prometheus-2.37.1.linux-amd64.tar.gz
    cd prometheus-2.37.1.linux-amd64
    ```
- Copy Prometheus files and set privileges
    ```
    sudo cp prometheus /usr/local/bin/
    sudo cp prometool /usr/local/bin/
    sudo chown prometheus:prometheus /usr/local/bin/prometheus
    sudo chown prometheus:prometheus /usr/local/bin/promtool
    sudo cp -r consoles /etc/prometheus
    sudo cp -r console_libraries /etc/prometheus
    sudo cp -r prometheus.yml /etc/prometheus
    sudo chown -R prometheus:prometheus /etc/prometheus/consoles
    sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
    sudo chown -R prometheus:prometheus /etc/prometheus/prometheus.yml
    ```
- Configure Prometheus  
    ```sudo nano /etc/prometheus/prometheus.yml```  
    Add new job name "nodes" into the "scrape_configs:" at the end of the file, so it looks like this:
    ```
    ....
    scrape_configs:
      - job_name: "prometheus"
        static_configs:
          - targets: ["localhost:9090"]
      - job_name: "nodes" #you can name this however you want, or create more of these 'groups'
        scrape_interval: 15s  #time interval of scraping data
        scrape_timeout: 2s
        static_configs:
          - targets: ['localhost:9100'] #enter IP's of computers to scrape data from / monitor with port 9100 (for nvidia_gpu_exporter use port 9835)
    ```
- Configure Prometheus systemctl service  
    ```sudo nano /etc/systemd/system/prometheus.service```  
    Add this to the file and save:
    ```
    [Unit]
    Description=Prometheus
    Wants=network-online.target
    After=network-online.target
    [Service]
    User=prometheus
    Group=prometheus
    Type=simple
    ExecStart=/usr/local/bin/prometheus \
        --config.file /etc/prometheus/prometheus.yml \
        --storage.tsdb.path /var/lib/prometheus/ \
        --web.console.templates=/etc/prometheus/consoles \
        --web.console.libraries=/etc/prometheus/console_libraries \
        --storage.tsdb.retention.time=1y
    [Install]
    WantedBy=multi-user.target
    ```
- Restart systemctl and enable the service
    ```
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl status prometheus
    ```
- Remove downloaded, nomore needed files
    ```
    cd ..
    sudo rm prometheus-2.37.1.linux-amd64.tar.gz
    sudo rm -rf prometheus-2.37.1.linux-amd64
    ```

## Node_exporter:  
Install this on every machine you want to monitor  
You can also use bash script in this repo to install node_exporter in matter of seconds  
- Create user for node_exporter  
    ```sudo useradd --no-create-home --shell /bin/false node_exporter```
- Download and and extract files from archive
    ```
    sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
    sudo tar xvzf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
    cd node_exporter-1.4.0-rc.0.linux-amd64
    ```
- Copy the binary file and set privileges
    ```
    sudo cp node_exporter /usr/local/bin
    sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
    ```
- Configure node_exporter systemctl service  
    ```sudo nano /etc/systemd/system/node_exporter.service```  
    Add this to the file and save:
    ```
    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network-online.target
    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    ExecStart=/usr/local/bin/node_exporter
    [Install]
    WantedBy=multi-user.target
    ```
- Restart systemctl and enable the service
    ```
    sudo systemctl daemon-reload
    sudo systemctl start node_exporter
    sudo systemctl status node_exporter
    ```
- Remove downloaded, nomore needed files
    ```
    cd ..
    rm -rf node_exporter-1.4.0-rc.0.linux-amd64
    rm -rf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
    ```

## Nvidia_gpu_exporter:
- If you want to see your Nvidia statics too...  
    ```
    sudo wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.1.0/nvidia-gpu-exporter_1.1.0_linux_amd64.deb
    sudo dpkg -i nvidia-gpu-exporter_1.1.0_linux_amd64.deb
    ```

## Grafana:
- Add Grafana repo key and source
    ```
    sudo mkdir -p /etc/apt/keyrings/
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
    ```
- Update package information and install Grafana
    ```
    sudo apt update
    sudo apt install grafana
    ```
- Restart systemctl and enable the service
    ```
    sudo systemctl daemon-reload
    sudo systemctl start grafana-server
    sudo systemctl status grafana-server
    ```
- Configure Grafana
    - Open the grafana site: http://localhost:3000/
    - Login with default username and password: admin;admin
    - Set new password for admin when asked
    - In bottom left, hover over settings icon and click on "Data sources"
    - Add new Prometheus datasource
    - Set "http://localhost:9090" as the URL
    - Click on the "Test and save" button on the bottom
    - Now you can create your own graphs or import "Node Exporter Full" with ID: 1860
