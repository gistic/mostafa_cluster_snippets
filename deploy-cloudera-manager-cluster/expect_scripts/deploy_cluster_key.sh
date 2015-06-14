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
send "~/cluster_resources/install_key.sh\r"	
expect "\\$"
send "exit\r"
sleep 1



