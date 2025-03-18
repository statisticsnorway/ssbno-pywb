ARG PYTHON=python:3.11
FROM $PYTHON

# Create archivist user and group
RUN groupadd -g 1001 archivist && useradd -m -u 1001 -g archivist -s /bin/bash archivist

# Set working directory
WORKDIR /pywb

# Copy dependencies and install them as root
COPY requirements.txt extra_requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r extra_requirements.txt

# Copy source code before switching users
COPY . ./

# Install package as root before switching to user
RUN python setup.py install

# Create directories with correct permissions
RUN python setup.py install \
 && mv ./docker-entrypoint.sh / \
 && mkdir /uwsgi && mv ./uwsgi.ini /uwsgi/ \
 && mkdir /webarchive && mv ./config.yaml /webarchive/ \ 
 && chown -R archivist:archivist /uwsgi /webarchive /pywb

# Switch to non-root user
USER archivist

# Set working directory
WORKDIR /webarchive

# Environment variables
ENV INIT_COLLECTION=""
ENV VOLUME_DIR="/webarchive"

COPY docker-entrypoint.sh ./

# Declare volumes
VOLUME /webarchive

# Expose port
EXPOSE 8080

# Entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["uwsgi", "/uwsgi/uwsgi.ini"]
