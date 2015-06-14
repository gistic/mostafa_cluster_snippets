#!/usr/bin/expect -f

set timeout 30

spawn scp cluster_resources.tar.gz $env(CSA_ADMIN_UNAME)@$env(CSC_CURRENT_MACHINE_IP):~/cluster_resources.tar.gz

expect {
  "assword" { 
    send "$env(CSA_ADMIN_PASSWORD)\r"

    expect "100%"  
  }
  "yes" {
  	send "yes\r"

  	expect {
  	  "assword" { 
  	    send "$env(CSA_ADMIN_PASSWORD)\r" 
  	    expect "100%" 
  	  }
  	  "100%" {}
  	}
  }

}

