FROM public.ecr.aws/lambda/ruby:2.7
COPY . ${LAMBDA_TASK_ROOT}
RUN bundle config --local silence_root_warning true
RUN bundle install --path vendor/bundle --clean
USER root
RUN yum -y install wget unzip

# Chromium
COPY google-chrome.repo /etc/yum.repos.d/google-chrome.repo
RUN yum install google-chrome-stable -y

# Chromedriver
RUN wget https://chromedriver.storage.googleapis.com/102.0.5005.61/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip -d /usr/bin/
RUN rm chromedriver_linux64.zip

CMD [ "lambda_function.lambda_handler" ]