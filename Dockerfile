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
RUN mkdir -p /uwsgi /webarchive/collections/wayback/indexes /webarchive/collections/wayback/archive \
    && mv ./uwsgi.ini /uwsgi/ \
    && mv ./config.yaml /webarchive/ \
    && chown -R archivist:archivist /uwsgi /webarchive /pywb

# Ensure entrypoint script has correct permissions inside the container
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chown archivist:archivist /docker-entrypoint.sh && chmod u+x /docker-entrypoint.sh

# Switch to non-root user
USER archivist

# Set working directory
WORKDIR /webarchive

# Environment variables
ENV INIT_COLLECTION=""
ENV VOLUME_DIR="/webarchive"

# Declare volumes
VOLUME /webarchive

# Expose port
EXPOSE 8080

# Entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["uwsgi", "/uwsgi/uwsgi.ini"]
