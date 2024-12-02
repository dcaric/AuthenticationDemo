#!/bin/bash

# Setup useful aliases
echo "alias ll='ls -al'" >> ~/.bashrc
source ~/.bashrc

# Set environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-17.0.13.0.11-3.el8.x86_64
export PATH=$JAVA_HOME/bin:$PATH
export KC_BOOTSTRAP_ADMIN_USERNAME=admin
export KC_BOOTSTRAP_ADMIN_PASSWORD=admin

# Validate JBOSS_HOME and KEYCLOAK_HOME
if [[ -z "$JBOSS_HOME" ]]; then
  echo "Error: JBOSS_HOME is not set. Exiting..."
  exit 1
fi

if [[ -z "$KEYCLOAK_HOME" ]]; then
  echo "Error: KEYCLOAK_HOME is not set. Exiting..."
  exit 1
fi

echo "JAVA_HOME is set to: $JAVA_HOME"
echo "JBOSS_HOME is set to: $JBOSS_HOME"
echo "KEYCLOAK_HOME is set to: $KEYCLOAK_HOME"

# Start JBoss in standalone mode (if needed)
if [[ -d "$JBOSS_HOME" && -x "$JBOSS_HOME/bin/standalone.sh" ]]; then
  echo "Starting JBoss..."
  $JBOSS_HOME/bin/standalone.sh -b 0.0.0.0 > /var/log/jboss.log 2>&1 &
else
  echo "JBOSS_HOME is invalid or standalone.sh is missing!"
fi

# Set Keycloak options
export KEYCLOAK_OPTS='-Dkeycloak.profile.feature.docker=enabled -Dkeycloak.proxy.address.forwarding=true'

# Set Keycloak options
export KEYCLOAK_OPTS='-Dkeycloak.profile.feature.docker=enabled -Dkeycloak.proxy.address.forwarding=true'

# Start Keycloak with Proxy Settings
if [[ -d "$KEYCLOAK_HOME" && -x "$KEYCLOAK_HOME/bin/kc.sh" ]]; then
  echo "Starting Keycloak..."
  $KEYCLOAK_HOME/bin/kc.sh start-dev \
    --http-port=8543 \
    --http-host=0.0.0.0 \
    --hostname-strict=false \
    --proxy-headers=xforwarded \
    --http-relative-path=/keycloak \
    > /var/log/keycloak.log 2>&1 &
else
  echo "KEYCLOAK_HOME is invalid or kc.sh is missing!"
fi

# Health Check for Keycloak
echo "Waiting for Keycloak to start..."
until curl -sf http://localhost:8543 > /dev/null; do
  sleep 5
  echo "Still waiting..."
done
echo "Keycloak started successfully!"

# Keep the container running
echo "Services started. Keeping the container alive..."
tail -f /dev/null