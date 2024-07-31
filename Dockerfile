FROM ruby:2.7.5-alpine

# Setup build variables
ARG RAILS_ENV
ARG DERIVATIVES_PATH
ARG UPLOADS_PATH
ARG CACHE_PATH
ARG FITS_VERSION

ENV APP_PRODUCTION=/data/

# Add backports to apt-get sources
# Install libraries, dependencies, java and fits

RUN apk update && \
    apk upgrade && \
    apk add bash build-base curl curl-dev gcompat imagemagick imagemagick-libs imagemagick-dev libarchive-tools  \
    libpq-dev libxml2-dev libxslt-dev nodejs openjdk11-jre-headless sqlite-dev mysql-dev tzdata yarn git

# COPY policy.xml /etc/ImageMagick-7/policy.xml

RUN mkdir -p /fits/fits-$FITS_VERSION \
    && curl --fail --location "https://github.com/harvard-lts/fits/releases/download/$FITS_VERSION/fits-$FITS_VERSION.zip" | bsdtar --extract --directory /fits/fits-$FITS_VERSION \
    && chmod +x "/fits/fits-$FITS_VERSION/fits.sh" "/fits/fits-$FITS_VERSION/fits-env.sh" "/fits/fits-$FITS_VERSION/fits-ngserver.sh"

# copy gemfiles to production folder
COPY Gemfile Gemfile.lock $APP_PRODUCTION

# install gems to system - use flags dependent on RAILS_ENV
RUN cd $APP_PRODUCTION \
    && bundle config build.nokogiri --use-system-libraries \
    && if [ "$RAILS_ENV" = "production" ]; then \
            bundle install --without test:development; \
        else \
            bundle install --without production --no-deployment; \
        fi \
    && mv Gemfile.lock Gemfile.lock.built_by_docker

# create a folder to store derivatives, file uploads and cache directory
RUN mkdir -p $DERIVATIVES_PATH
RUN mkdir -p $UPLOADS_PATH
RUN mkdir -p $CACHE_PATH

# copy the application
COPY . $APP_PRODUCTION

# use the just built Gemfile.lock, not the one copied into the container and verify the gems are correctly installed
RUN cd $APP_PRODUCTION \
    && mv Gemfile.lock.built_by_docker Gemfile.lock \
    && bundle check

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ] && [ ! -f "/data/yarn.lock" ]; then \
        cd $APP_PRODUCTION \
        && yarn install; \
    fi
RUN if [ "$RAILS_ENV" = "production" ]; then \
        cd $APP_PRODUCTION \
        && SECRET_KEY_BASE_PRODUCTION=0 bundle exec rake assets:clean assets:precompile; \
    fi

COPY docker-entrypoint.sh /bin/

WORKDIR $APP_PRODUCTION
RUN mkdir -p $APP_PRODUCTION/public/assets
RUN mkdir -p /data-backup/public
RUN cp -Rp $APP_PRODUCTION/public/assets /data-backup/public/

RUN chmod +x /bin/docker-entrypoint.sh
