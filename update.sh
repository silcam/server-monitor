#!/bin/bash
# Check up on some things and update a static html file for viewing

root_dir=/var/www/sysadmin
index=$root_dir/public/index.html

function pretty_div {
  echo '<h3>'
  echo $2
  echo '</h3>'
  echo '<div class="codeblock"><pre><code>'
  cat $1
  echo '</code></pre></div>'
}

cat $root_dir/index_start.html > $index

# Backups Block
smbclient \\\\Kelitah\\DuluBackup$ -U CMB\\BackupAgent%key20it25! -c ls > tmp
grep '^\s\+[a-zA-Z]' tmp > tmp2
pretty_div tmp2 Backups >> $index

# Updates and Reboot Block
/usr/lib/update-notifier/apt-check --human-readable > tmp
/usr/lib/update-notifier/update-motd-reboot-required >> tmp
pretty_div tmp Updates >> $index

# Rails Logs
function rails_logs {
  cat $2 | grep 'FATAL' > tmp
  pretty_div tmp "Error Logs for $1"
}
rails_logs LibArchives /var/www/libarchives/current/log/production.log >> $index
rails_logs Payroll /var/www/cmbpayroll/current/log/production.log >> $index

# System Status
since=$($root_dir/an-hour-ago.sh)
sar -ur -s $since > tmp
pretty_div tmp 'System Status' >> $index

user_auth=$(cat dulu-auth)
curl -u $user_auth http://192.168.0.101:99 >> $index

cat $root_dir/index_finish.html >> $index
