FROM opensuse/leap:15.3
ENV APP_HOME=/root/bugzilla
RUN zypper install -y libxml2-devel ImageMagick-devel ruby2.5 ruby2.5-devel gcc git automake gdbm-devel libyaml-devel ncurses-devel readline-devel zlib-devel wget curl tar make sqlite3-devel libopenssl-devel

RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh

ENV PATH /root/.rbenv/bin:$PATH

RUN echo 'export PATH=/root/.rbenv/bin:$PATH' >> /root/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN source /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
RUN /root/.rbenv/bin/rbenv install 2.6.5 && /root/.rbenv/bin/rbenv global 2.6.5

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc
WORKDIR $APP_HOME
