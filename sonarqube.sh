#!/bin/bash

# Variables
SONARQUBE_VERSION="9.9.8.100196"
SONARQUBE_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"
INSTALL_DIR="/opt/sonarqube"
SONARQUBE_ZIP="sonarqube-${SONARQUBE_VERSION}.zip"

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y unzip openjdk-11-jdk

# Create installation directory
echo "Creating installation directory at ${INSTALL_DIR}..."
sudo mkdir -p ${INSTALL_DIR}

# Change to the installation directory
cd ${INSTALL_DIR}

# Download SonarQube
echo "Downloading SonarQube from ${SONARQUBE_URL}..."
curl -O ${SONARQUBE_URL}

# Unzip the downloaded file
echo "Unzipping SonarQube..."
sudo unzip ${SONARQUBE_ZIP}

# Remove the zip file after extraction
echo "Cleaning up..."
rm ${SONARQUBE_ZIP}

# Set permissions
echo "Setting permissions..."
sudo chown -R $(whoami):$(whoami) ${INSTALL_DIR}/sonarqube-${SONARQUBE_VERSION}

# Create a systemd service file for SonarQube
echo "Creating systemd service file..."
cat <<EOL | sudo tee /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=simple
User =$(whoami)
ExecStart=${INSTALL_DIR}/sonarqube-${SONARQUBE_VERSION}/bin/linux-x86-64/sonar.sh start
ExecStop=${INSTALL_DIR}/sonarqube-${SONARQUBE_VERSION}/bin/linux-x86-64/sonar.sh stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd..."
sudo systemctl daemon-reload

# Start SonarQube service
echo "Starting SonarQube service..."
sudo systemctl start sonarqube

# Enable SonarQube to start on boot
echo "Enabling SonarQube to start on boot..."
sudo systemctl enable sonarqube

# Output the status of SonarQube service
echo "SonarQube installation complete. Checking status..."
sudo systemctl status sonarqube

echo "You can access SonarQube at http://localhost:9000"
