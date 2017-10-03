#!/bin/bash
# Check up on some things and update a static html file for viewing

root_dir=/var/www/sysadmin
index=$root_dir/public/index.html.new
if [ $(hostname) = george ]; then
  master_version='true'
else
  master_version='false'
fi

function pretty_div {
  echo '<h3>'
  echo $2
  echo '</h3>'
  echo '<div class="codeblock"><pre><code>'
  cat $1
  echo '</code></pre></div>'
} 

if [ $master_version = true ]; then
  cat $root_dir/index_start.html > $index
else
  echo '<h2>Dulu</h2>' > $index
fi

# Backups Block
if [ $master_version = true ]; then
  smbclient \\\\Kelitah\\DuluBackup$ -U CMB\\BackupAgent%key20it25! -c ls > tmp
  grep '^\s\+[a-zA-Z]' tmp > tmp2
  pretty_div tmp2 Backups >> $index
fi

# Updates and Reboot Block
/usr/lib/update-notifier/apt-check --human-readable > tmp
/usr/lib/update-notifier/update-motd-reboot-required >> tmp
pretty_div tmp Updates >> $index

# Rails Logs
function rails_logs {
  cat $2 | grep 'FATAL' > tmp
  pretty_div tmp "Error Logs for $1"
}
if [ $master_version = true ]; then
  rails_logs LibArchives /var/www/libarchives/current/log/production.log >> $index
  rails_logs Payroll /var/www/cmbpayroll/current/log/production.log >> $index
else
  rails_logs Dulu /var/www/dulu/current/log/production.log >> $index
fi

# System Status
since=$($root_dir/an-hour-ago.sh)
sar -ur -s $since > tmp
pretty_div tmp 'System Status' >> $index

if [ $master_version = true ]; then
  # Copy in Dulu
  user_auth=$(cat $root_dir/dulu-auth)
  curl -u $user_auth http://192.168.0.101:99 >> $index

  # HTML footer
  cat $root_dir/index_finish.html >> $index
fi

mv $index $root_dir/public/index.html
