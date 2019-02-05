FROM phusion/baseimage
MAINTAINER  Javier Calles "javiercalles@gmail.com"
ENV LANG en_US.UTF-8
CMD ["/bin/bash"]
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

COPY ./install.sh /install.sh

RUN chmod +x /install.sh \
&& sh /install.sh puppet

COPY ./site.pp /etc/puppet/manifests/site.pp

RUN  sh /install.sh puppetfile && apt-get update

RUN puppet apply /etc/puppet/manifests/site.pp  --modulepath=/etc/puppet/modules/  --detailed-exitcodes || [ $? -eq 2 ]
###########
RUN  mkdir /root/sourceguardian \
&&  cd /root/sourceguardian \
&&  wget http://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz \
&& tar xzf loaders.linux-x86_64.tar.gz \
&& cp ixed.7.0.lin /etc/php/7.0/mods-available/ixed.7.0.lin \
&& touch /etc/php/7.0/mods-available/sourceguardian.ini \
&& echo "zend_extension=/etc/php/7.0/mods-available/ixed.7.0.lin" >> /etc/php/7.0/mods-available/sourceguardian.ini

###########
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x  /docker-entrypoint.sh \
&& apt-get clean


ENTRYPOINT ["/docker-entrypoint.sh"]
