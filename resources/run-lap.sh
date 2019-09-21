#!/bin/bash

function exportBoolean {
    if [ "${!1}" = "**Boolean**" ]; then
            export ${1}=''
    else
            export ${1}='Yes.'
    fi
}

exportBoolean LOG_STDERR

if [ $LOG_STDERR ]; then
    /usr/bin/ln -sf /dev/stderr /var/log/httpd/error_log
fi

if [ $ALLOW_OVERRIDE == 'All' ]; then
    /usr/bin/sed -i 's/AllowOverride\ None/AllowOverride\ All/g' /etc/httpd/conf/httpd.conf
fi

# stdout server info:

/usr/bin/ln -sf /dev/stdout /var/log/httpd/access_log

# Set PHP timezone
/usr/bin/sed -i "s/\;date\.timezone\ \=/date\.timezone\ \=\ ${DATE_TIMEZONE}/" /etc/php.ini

# Run Postfix
2>/dev/null /usr/sbin/postfix stop
/usr/sbin/postfix start

# Run Apache:
2>/dev/null /usr/sbin/httpd -k stop
&>/dev/null /usr/sbin/httpd -DFOREGROUND -k start
