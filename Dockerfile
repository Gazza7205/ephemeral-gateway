FROM caapim/gateway:latest

USER root
ARG build_number
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8 --quiet
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV ENV.PROPERTY.gateway.otk.port="443"
ENV ENV.PROPERTY.jenkins_build_number=$build_number


#Copy the file that we build during gradle build
RUN ls
RUN pwd
COPY build/gateway/prague-1.0.0.gw7 /opt/docker/rc.d/deployment.gw7

RUN touch /opt/SecureSpan/Gateway/node/default/etc/bootstrap/services/restman
USER ${ENTRYPOINT_UID}