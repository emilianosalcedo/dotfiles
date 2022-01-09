#!/bin/sh

# PERFORMS HTML ENCODING ON A STRING FOR SPECIAL CHARACTERS UP TO ASCII
echo "${1}" | sed 's/%/%25/g;
s/\s/%20/g;
s/!/%21/g;
s/"/%22/g;
s/#/%22/g;
s/\$/%24/g;
s/&/%26/g;
s/\x27/%27/g;
s/)/%29/g;
s/(/%28/g;
s/\*/%2A/g;
s/\+/%2B/g;
s/,/%2C/g;
s/-/%2D/g;
s/\./%2E/g;
s/\//%2F/g;
s/:/%3A/g;
s/;/%3B/g;
s/</%3C/g;
s/=/%3D/g;
s/>/%3E/g;
s/\?/%3F/g;
s/@/%40/g;
s/]/%5D/g;
s/\\/%5C/g;
s/\[/%5B/g;
s/\^/%5E/g;
s/_/%5F/g;
s/`/%60/g;
s/}/%7D/g;
s/|/%7C/g;
s/{/%7B/g;
s/~/%7E/g'
