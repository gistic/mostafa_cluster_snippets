#!/usr/bin/expect -f

set timeout 30

# Run the installation script on master
spawn ssh $env(CSA_ADMIN_UNAME)@$env(CSC_CURRENT_MACHINE_IP) 

expect {
  "assword" {
    send "$env(CSA_ADMIN_PASSWORD)\r"
  }
  "\\$" {
    send "\r"    
  }
  timeout { 
    send_user "=== ERROR === server took so long time to respond\r"
    exit 1 
  }
}

expect "\\$"
send "rm -rf ~/cluster_resources\r"
expect "\\$"
send "tar xvf ~/cluster_resources.tar.gz\r"
expect "\\$"
send "rm ~/cluster_resources.tar.gz\r"
expect "\\$"
send "chmod +x ~/cluster_resources/*.sh\r"
expect "\\$"
send "exit\r"
sleep 1



