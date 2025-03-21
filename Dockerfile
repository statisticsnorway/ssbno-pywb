ARG PYTHON=python:3.11
FROM $PYTHON

# Create archivist user and group
RUN groupadd -g 1001 archivist && useradd -m -u 1001 -g archivist -s /bin/bash archivist

WORKDIR /pywb

COPY requirements.txt extra_requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt -r extra_requirements.txt

COPY . ./

# Install package as root before switching to user
# Create directories with correct permissions
RUN python setup.py install \
 && mkdir /uwsgi && mv ./uwsgi.ini /uwsgi/ \
 && mkdir -p /webarchive/collections/wayback/indexes && mv ./config.yaml /webarchive/ \
 && chown -R archivist:archivist /uwsgi /webarchive /pywb

# Switch to non-root user
USER archivist

WORKDIR /webarchive

# auto init collection
# Environment variables
ENV INIT_COLLECTION=""
ENV VOLUME_DIR="/webarchive"

#USER archivist
COPY docker-entrypoint.sh ./

# volume and port
VOLUME /webarchive
EXPOSE 8080

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["uwsgi", "/uwsgi/uwsgi.ini"]

