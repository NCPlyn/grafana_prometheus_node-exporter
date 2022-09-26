sudo useradd --no-create-home --shell /bin/false node_exporter
sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0-rc.0/node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
sudo tar xvzf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
cd node_exporter-1.4.0-rc.0.linux-amd64
sudo cp node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
cd ..
rm -rf node_exporter-1.4.0-rc.0.linux-amd64
rm -rf node_exporter-1.4.0-rc.0.linux-amd64.tar.gz
sudo dd of=/lib/systemd/system/node_exporter.service << EOF
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
EOF
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
