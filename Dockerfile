FROM registry.access.redhat.com/ubi8/ubi

# Install dependencies
RUN yum update -y && yum install -y \
    java-17-openjdk \
    unzip \
    procps \
    net-tools \
    lsof \
    iputils \
    openldap-clients \
    && yum clean all

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-17.0.13.0.11-3.el8.x86_64
ENV JBOSS_HOME=/opt/jboss
ENV KEYCLOAK_HOME=/opt/keycloak
ENV PATH=$JAVA_HOME/bin:$JBOSS_HOME/bin:$KEYCLOAK_HOME/bin:$PATH


# Add JBoss and Keycloak ZIP Distributions
ADD jboss-eap-8.0.zip /opt
ADD keycloak-26.0.5.zip /opt


# Unzip and Configure
RUN unzip /opt/jboss-eap-8.0.zip -d /opt && \
    mv /opt/jboss-eap-8.0 /opt/jboss && \
    rm /opt/jboss-eap-8.0.zip && \
    unzip /opt/keycloak-26.0.5.zip -d /opt && \
    mv /opt/keycloak-26.0.5 /opt/keycloak && \
    rm /opt/keycloak-26.0.5.zip


# Add setup script
ADD setup-eap-keycloak.sh /opt/jboss/setup-eap-keycloak.sh
RUN chmod +x /opt/jboss/setup-eap-keycloak.sh

# Expose ports for JBoss and Kycloak
EXPOSE 8080 9990 8543

# Start JBoss
CMD ["/bin/bash", "/opt/jboss/setup-eap-keycloak.sh"]
