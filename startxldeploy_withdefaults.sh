#!/bin/bash

xldeploy_svr_dir=/opt/xldeploy/xl-deploy-server
#Make sure all relevant binary files have been copied!
if [ ! -f $xldeploy_svr_dir/bin/run.sh ]; then
	echo "ERROR: XLDeploy, server.sh not found! Make sure at docker build you have xldeploy binaries (cli and server) in xldeploy/bin/ directory"
	exit 1
fi

#initialize the xldeploy server when this was not done in a previous run.
if [ ! -f $xldeploy_svr_dir/data/deployit.conf ]; then
	echo "initializing the XL Deploy server"
	$xldeploy_svr_dir/bin/run.sh -setup -reinitialize -force -setup-defaults /opt/xldeploy/xldeploy_scripts/xldeploy.answers | while read line; do
		echo $line
		if echo $line | grep -q "JCR repository initialized"; then
			killall java

			# keep the conf file for the next time the container is started
			cp $xldeploy_svr_dir/conf/deployit.conf $xldeploy_svr_dir/data
		fi
	done
else
	ln -s $xldeploy_svr_dir/data/deployit.conf $xldeploy_svr_dir/conf/
fi

#start the intialized xldeploy server.
echo "start the initialized xldeploy server"
$xldeploy_svr_dir/bin/run.sh