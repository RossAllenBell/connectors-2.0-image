FROM ruby:2.6.9
ADD . /connector
WORKDIR /connector
RUN gem install bundler:2.2.3
RUN bundle install
EXPOSE 80
CMD ["/bin/bash"]
