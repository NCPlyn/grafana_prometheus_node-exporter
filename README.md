# Guide to install __Prometheus__ & __Grafana__ & exporters

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
      - job_name: "nodes"
        scrape_interval: 15s  #time interval of scraping data
        scrape_timeout: 2s
        static_configs:
          - targets: ['localhost:9100'] #enter IP's of computers to scrape data from with port 9100 for node_exporter
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
- If you want to see your Nvidia statistics, install nvidia exporter on every node:
    ```
    sudo wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/download/v1.1.0/nvidia-gpu-exporter_1.1.0_linux_amd64.deb
    sudo dpkg -i nvidia-gpu-exporter_1.1.0_linux_amd64.deb
    ```
- Add new job with valid IPs to your prometheus config:
    ```
      - job_name: "nvidia"
        scrape_interval: 15s  #time interval of scraping data
        scrape_timeout: 2s
        static_configs:
          - targets: ['localhost:9835'] #enter IP's of computers to scrape data from with port 9835 for nvidia_gpu_exporter
    ```
- Restart prometheus with `sudo systemctl restart prometheus` and add dashboard with ID: 14574 in your Grafana

## ipmi_exporter
- If you want to see ipmi compatibile statistics:
- Every client server add new user to IPMI if doesn't already exist (-user list):
    ```
    wget https://github.com/NCPlyn/grafana_prometheus_node-exporter/raw/main/IPMICFG-Linux.x86_64
    sudo chmod +x IPMICFG-Linux.x86_64
    sudo ./IPMICFG-Linux.x86_64 -user add 4 Prometheus ExporterOfIPMI 2 #maybe use different user & pass
    ```
- On server with prometheus:
    - `sudo apt install freeipmi-tools`
    - Extract exporter binary
        ```
        wget https://github.com/prometheus-community/ipmi_exporter/releases/download/v1.6.1/ipmi_exporter-1.6.1.linux-amd64.tar.gz
        tar -xvf ipmi_exporter-1.6.1.linux-amd64.tar.gz
        sudo mv ipmi_exporter-1.6.1.linux-amd64/ipmi_exporter /usr/bin/ipmi_exporter
        sudo chmod 755 /usr/bin/ipmi_exporter
        ```
    - Make & edit config file
        ```
        wget https://raw.githubusercontent.com/prometheus-community/ipmi_exporter/master/ipmi_remote.yml
        nano ipmi_remote.yml #<- edit login details to ones you set
        sudo cp ipmi_remote.yml /etc/prometheus/ipmi_remote.yml
        ```
    - Make systemctl service: `sudo nano /etc/systemd/system/ipmi_exporter.service`
        ```
        [Unit]
        Description=IPMI Exporter
        Wants=network-online.target
        After=network-online.target
        [Service]
        User=root
        Group=root
        Type=simple
        ExecStart=/usr/bin/ipmi_exporter --config.file=/etc/prometheus/ipmi_remote.yml
        [Install]
        WantedBy=multi-user.target
        ```
        ```
        sudo systemctl enable ipmi_exporter
        sudo systemctl start ipmi_exporter
        ```
    - Set ipmi_exporter endpoints: sudo nano /etc/prometheus/ipmi_targets.yml
        ```
        - targets:
          - (ip or domain)
          labels:
            job: ipmi_exporter
        ```
    - Add new job to prometheus config: `sudo nano /etc/prometheus/prometheus.yml`
        ```
          - job_name: "ipmi_exporter"
            params:
              module: ['default']
            scrape_interval: 30s
            scrape_timeout: 30s
            metrics_path: /ipmi
            scheme: http
            file_sd_configs:
            - files:
              - /etc/prometheus/ipmi_targets.yml
              refresh_interval: 5m
            relabel_configs:
            - source_labels: [__address__]
              separator: ;
              regex: (.*)
              target_label: __param_target
              replacement: ${1}
              action: replace
            - source_labels: [__param_target]
              separator: ;
              regex: (.*)
              target_label: instance
              replacement: ${1}
              action: replace
            - separator: ;
              regex: .*
              target_label: __address__
              replacement: localhost:9290
              action: replace
        ```
    - Restart prometheus and add dashboard to your Grafana with ID: 15765
        - `sudo systemctl restart prometheus`

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
