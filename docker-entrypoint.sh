#!/bin/sh
set -e

if [ -n "$INIT_COLLECTION" ] && [ ! -d "$VOLUME_DIR/collections/$INIT_COLLECTION" ]; then
    wb-manager init "$INIT_COLLECTION" || echo "Warning: Could not initialize collection."
fi

INDEX_DIR="$VOLUME_DIR/collections/$INIT_COLLECTION/indexes"
ARCHIVE_DIR="$VOLUME_DIR/collections/$INIT_COLLECTION/archive"

if [ -z "$(ls -A "$INDEX_DIR" 2>/dev/null)" ]; then
    echo "No indexes found, running manual indexing of archive..."
    wayback index --no-append --output-dir "$INDEX_DIR" "$ARCHIVE_DIR"/*.warc.gz || echo "Warning: Indexing failed or no WARCs found."
else
    echo "Indexes already present, skipping initial indexing."
fi

exec "$@"
