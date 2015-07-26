FROM java:openjdk-7u65-jdk

# suppress warnings in apt-get that TERM is not set
ENV DEBIAN_FRONTEND=noninteractive

# update install and install required archives
RUN apt-get update && apt-get install -y wget git curl zip nano bzip2 vim

# remove downloaded archive files
RUN apt-get clean

#Copy private key into .ssh directory
RUN mkdir /.ssh
RUN chmod 700 /.ssh

#disable initial fingerprinting of this server
RUN echo "Host *" >> /etc/ssh/ssh_config
RUN echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config

#copy code to ci server and unpack
RUN mkdir /opt/xldeploy/
ADD https://dist.xebialabs.com/public/distributions/xl-deploy/5.0.1/xl-deploy-5.0.1-server-free-edition.zip /opt/xldeploy/xldeployserver.zip
ADD https://dist.xebialabs.com/public/distributions/xl-deploy/5.0.1/xl-deploy-5.0.1-cli-free-edition.zip /opt/xldeploy/xldeploycli.zip
RUN unzip -n /opt/xldeploy/xldeployserver.zip -d /opt/xldeploy 
RUN unzip -n /opt/xldeploy/xldeploycli.zip -d /opt/xldeploy 
RUN ln -s /opt/xldeploy/xl-deploy-5.0.1-server-free-edition /opt/xldeploy/xl-deploy-server
RUN ln -s /opt/xldeploy/xl-deploy-5.0.1-cli-free-edition /opt/xldeploy/xl-deploy-cli

#copy answer file and alternative startup.sh script to image
RUN mkdir /opt/xldeploy/xldeploy_scripts
COPY xldeploy.answers /opt/xldeploy/xldeploy_scripts/xldeploy.answers
COPY startxldeploy_withdefaults.sh /opt/xldeploy/xl-deploy-server/bin/startxldeploy_withdefaults.sh

# for main web interface:
EXPOSE 4516

VOLUME /opt/xldeploy/xl-deploy-server/data

#start xldeploy
CMD ["/opt/xldeploy/xl-deploy-server/bin/startxldeploy_withdefaults.sh"]
