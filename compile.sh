#!/bin/bash
echo "coffe"
coffee -c ajaxpagination.coffee
echo "uglifyjs"
uglifyjs ajaxpagination.js -o ajaxpagination.min.js
echo "gzip"
gzip -k -f ajaxpagination.min.js
echo ""
