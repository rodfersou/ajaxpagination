#!/bin/bash
coffee -c ajaxpagination.coffee
uglifyjs ajaxpagination.js -o ajaxpagination.min.js
gzip -k -f ajaxpagination.min.js
