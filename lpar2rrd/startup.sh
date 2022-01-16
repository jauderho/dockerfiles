#!/bin/bash

if [ -f /firstrun ]; then
    # remote syslog server to docker host
    SYSLOG=`netstat -rn|grep ^0.0.0.0|awk '{print $2}'`
    echo "*.* @$SYSLOG" >> /etc/rsyslog.conf

    # Start syslog server to see something
    # /usr/sbin/rsyslogd

    echo "Running for the first time.. need to configure..."

    ln -s /etc/apache2/sites-available/*.conf /etc/apache2/conf.d/

    cat <<EOF > /etc/apache2/conf.d/mod_cgi.conf
<IfModule !mpm_prefork_module>
  LoadModule cgid_module modules/mod_cgid.so
</IfModule>
  <IfModule mpm_prefork_module>
  LoadModule cgi_module modules/mod_cgi.so
</IfModule>
EOF

    # RRDp module not found, move it
    mv /usr/share/vendor_perl/RRDp.pm  /usr/share/perl5/vendor_perl/

    # change ownership of files, mounted volumes
    chown -R lpar2rrd /home/lpar2rrd
    chown -R lpar2rrd /tmp/lpar2rrd-$LPAR_VER

    # setup products
    if [ -f "/home/lpar2rrd/lpar2rrd/etc/lpar2rrd.cfg" ]; then
        # spoof files to force update, not install
        #mkdir -p /home/lpar2rrd/lpar2rrd/bin
        #touch /home/lpar2rrd/lpar2rrd/bin/lpar2rrd.pl
        #touch /home/lpar2rrd/lpar2rrd/load.sh
        OLD_VER=`tail -1 /home/lpar2rrd/lpar2rrd/etc/version.txt | sed 's/ .*//'`
        ITYPE="update.sh"
        if [ -f "/home/lpar2rrd/lpar2rrd/bin/premium.sh" ]; then
            echo "Premium version detected, no update will be done"
        elif [ "$OLD_VER" = "$LPAR_VER" ]; then
            echo "The version is still the same, no update needed"
        else
            su - lpar2rrd -c "cd /tmp/lpar2rrd-$LPAR_VER/; yes '' | ./update.sh"
            su - lpar2rrd -c "cd /home/lpar2rrd/lpar2rrd; ./load.sh html"
        fi
    else
        su - lpar2rrd -c "cd /tmp/lpar2rrd-$LPAR_VER/; yes '' | ./install.sh"

        # copy .htaccess files for ACL
        cp -p /home/lpar2rrd/lpar2rrd/html/.htaccess /home/lpar2rrd/lpar2rrd/www
        cp -p /home/lpar2rrd/lpar2rrd/html/.htaccess /home/lpar2rrd/lpar2rrd/lpar2rrd-cgi

        # enable LPAR2RRD daemon on default port (8162)
        sed -i "s/LPAR2RRD_AGENT_DAEMON\=0/LPAR2RRD_AGENT_DAEMON\=1/g" /home/lpar2rrd/lpar2rrd/etc/lpar2rrd.cfg

        # set DOCKER env var
        su - lpar2rrd -c "echo 'export DOCKER=1' >> /home/lpar2rrd/lpar2rrd/etc/.magic"
    fi

    rm -r /tmp/lpar2rrd-$LPAR_VER

    if [[ -z "${TIMEZONE}" ]]; then
        # set default TZ to London, enable TZ change via GUI
        TIMEZONE="Europe/London"
    fi
    echo "${TIMEZONE}" > /etc/timezone
    chmod 666 /etc/timezone
    ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

    if [ $XORMON ] && [ "$XORMON" != "0" ]; then
            su - lpar2rrd -c "echo 'export XORMON=1' >> /home/lpar2rrd/lpar2rrd/etc/.magic"
    fi

    # initialize lpar2rrd's crontab
    crontab -u lpar2rrd /var/spool/cron/crontabs/lpar2rrd

    # clean up
    rm /firstrun
fi

# Sometimes with un unclean exit the rsyslog pid doesn't get removed and refuses to start
if [ -f /var/run/rsyslogd.pid ]; then
    rm /var/run/rsyslogd.pid
fi

# The same for Apache daemon
if [ -f /var/run/apache2/httpd.pid ]; then
    rm /var/run/apache2/httpd.pid
fi

# Start supervisor to start the services
/usr/bin/supervisord -c /etc/supervisord.conf -l /var/log/supervisor.log -j /var/run/supervisord.pid
