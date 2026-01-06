#!/bin/bash
# Remove preview dylib files to prevent Watch App Bundle from trying to create universal binaries for them
find "${BUILT_PRODUCTS_DIR}" -name "__preview.dylib" -delete 2>/dev/null || true

