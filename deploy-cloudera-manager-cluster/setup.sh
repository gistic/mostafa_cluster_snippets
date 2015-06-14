#!/bin/bash
	
function print_help() {

  echo "Command line options :" 
  echo ""
  echo "= Actions"
  echo ""
  echo "  --action-update-cluster-resources       "
  echo "                            Copy the given cluster key to all cluster's machines"
  echo "  --action-deploy-key       Copy the given cluster key to all cluster's machines"
  echo "  --action-install-cloudera-manager"
  echo "                            Install cloudera manager on the master"
  echo ""
  echo "= Credentials" 
  echo ""
  echo "  --admin-uname      The user name used to access the machines (master and slaves)"  
  echo "  --admin-password   (Optional) The password used to access the machines in case"
  echo "                     this machine has no 'public key' access to all machines"
  echo "  --admin-key-path   (Optional) Path to your private key (if you have public "
  echo "                     key access to cluster's machines"
  echo "  --master-ip        IP of the machine deignated as master"
  echo "  --slaves-ips       (Optional) Comma-separated list of the slave machines, "
  echo "                     if none is provided, then no slaves will be created"      
  echo "  --cluster-key      Path to key used to access the machine"
  echo ""
  echo "= Options"
  echo ""
  echo "  --cm-installer     (Optional) URL of the Cloudera Manager installer, default to : http://archive.cloudera.com/cm5/installer/latest/cloudera-manager-installer.bin"
  echo ""
  echo ""
  echo "= Common tasks :"
  echo ""
  echo "Do everything :"
  echo ""
  echo "./setup.sh --admin-uname=ubuntu --admin-key-path=~/.ssh/id_rsa --master-ip=52.8.74.43 --cluster-key=./key/id_rsa --action-update-cluster-resources --action-deploy-key --action-install-cloudera-manager --slaves-ips=52.8.138.244, 52.8.138.238, 52.8.138.243 --cm-installer=http://archive.cloudera.com/cm5/installer/5.3.0/cloudera-manager-installer.bin"
  echo ""  
  echo "Install Manager + Update resources :"
  echo ""
  echo "./setup.sh --admin-uname=ubuntu --admin-key-path=~/.ssh/id_rsa --master-ip=52.8.74.43 --cluster-key=./key/id_rsa --action-update-cluster-resources --action-install-cloudera-manager --cm-installer=http://archive.cloudera.com/cm5/installer/5.3.0/cloudera-manager-installer.bin"
  echo ""
  echo "Install Manager :"
  echo ""
  echo "./setup.sh --admin-uname=ubuntu --admin-key-path=~/.ssh/id_rsa --master-ip=52.8.74.43 --cluster-key=./key/id_rsa --action-install-cloudera-manager --cm-installer=http://archive.cloudera.com/cm5/installer/5.3.0/cloudera-manager-installer.bin"
  echo ""
  echo "Install Slaves + Update resources :"
  echo ""
  echo "./setup.sh --admin-uname=ubuntu --admin-key-path=~/.ssh/id_rsa --master-ip=52.8.74.43 --cluster-key=./key/id_rsa --action-update-cluster-resources --action-deploy-key --slaves-ips=52.8.53.61,52.8.51.159,52.8.49.117 --cm-installer=http://archive.cloudera.com/cm5/installer/5.3.0/cloudera-manager-installer.bin"
  echo ""
  


  exit 1
}


# parse command line options
for i in $@
do  
  case $i in
  	--admin-uname=* )
  	  export CSA_ADMIN_UNAME="${i#*=}"
  	  ;;
  	--admin-password=* )
  	  export CSA_ADMIN_PASSWORD="${i#*=}"
  	  ;;
  	--admin-key-path=* )
      export CSA_ADMIN_KEY_PATH="${i#*=}"
      ;;
  	--master-ip=* )
  	  export CSA_MASTER_IP="${i#*=}"
  	  ;;
  	--slaves-ips=* )
  	  export CSA_SLAVES_IPS="${i#*=}"
  	  ;;
  	--cluster-key=* )
  	  export CSA_CLUSTER_KEY="${i#*=}"
  	  ;;
    --cm-installer=* )
      rm -f cluster_resources/props/cm_installer.v
      printf "${i#*=}" > cluster_resources/props/cm_installer.v
      CSA_INSTALLER_GIVEN=1
      ;;
  	--action-deploy-key )
      export CSA_ACTION_DEPLOY_KEY="1"
      ;;
    --action-install-cloudera-manager )
      export CSA_ACTION_INSTALL_CLOUDERA_MANAGER="1"
      ;;
    --action-update-cluster-resources )
      export CSA_ACTION_UPDATE_CLUSTER_RESOURCES="1"
      ;;
    --help=* )
      print_help 
      ;;
  esac
done

function deploy_cluster_resources() {

  # Making a flag, containing the ip
  IP_CLEANED=$(echo $CSC_CURRENT_MACHINE_IP | tr '.' '_')

  FLAG=CSA_ACTION_UPDATE_CLUSTER_RESOURCES___$IP_CLEANED

  echo $FLAG
  echo "${!FLAG}"
  # Making sure we've not deployed to this machine before
  if [ -n "$CSA_ACTION_UPDATE_CLUSTER_RESOURCES" ] && [ -z "${!FLAG}" ]; then
    echo ""; echo "===== Deploying cluster resources ..."
    
    echo ""; echo "=== Preparing the resources"
    rm -rf cluster_resources.tar.gz
    cp "$CSA_CLUSTER_KEY" cluster_resources/id_rsa
    tar -zcvf cluster_resources.tar.gz cluster_resources    

    echo ""; echo "=== Uploading cluster resources"; echo "";        
    ./expect_scripts/upload_cluster_resources.sh

    echo ""; echo "=== Deploying cluster resources"; echo "";
    ./expect_scripts/deploy_cluster_resources.sh

    echo ""; 
  fi

  # Mark that we have visited this machine
  declare $FLAG=1;
}

echo ""
echo "===== Starting ..."
echo ""

echo "===== Checking parameters ..."
echo ""

if [ -z "$CSA_INSTALLER_GIVEN" ]; then
  cp cluster_resources/props/cm_installer_default.v  cluster_resources/props/cm_installer.v
fi

if [ -z "$CSA_ADMIN_UNAME" ]; then
  echo " "
  echo " ==== Error ==== : Admin username isn't set, please set one using the argument (--admin-uname)"
  echo " "
  print_help 
fi

if [ -z "$CSA_CLUSTER_KEY" ]; then
  echo " "
  echo " ==== Error ==== : Cluster-key isn't provided, please set one using the argument (--cluster-key)"
  echo " "
  print_help 
fi

if [ ! -e "$CSA_CLUSTER_KEY" ]; then
  echo " "
  echo " ==== Error ==== : Cluster-key can't be found at the given path ($CSA_CLUSTER_KEY)"
  echo " "
  print_help 
fi

if [  -z "$CSA_ADMIN_KEY_PATH" ] && [ -z "$CSA_ADMIN_PASSWORD" ]; then
  echo " "
  echo " ==== Error ==== : No valid access to the machines is provided, You need to either set --admin-password or --admin-key-path"
  echo " "
  print_help 
fi

if [ -n "$CSA_ACTION_DEPLOY_KEY" ]; then
    
  IFS=","

  for ip in $(echo "$CSA_MASTER_IP,$CSA_SLAVES_IPS"); do

    echo "===================================================="
    echo "==== Deploy key to machine : $ip"
    echo "===================================================="

    export CSC_CURRENT_MACHINE_IP=$ip

    deploy_cluster_resources
    
    echo ""; echo "=== Deploying the cluster's key on the cluster machine"; echo "";
    ./expect_scripts/deploy_cluster_key.sh  

    echo ""; echo ""  
  done
  
fi


if [ -n "$CSA_ACTION_INSTALL_CLOUDERA_MANAGER" ]; then
  echo ""; echo "===== Installing cloudera-manager on the master ..."; echo "";
  
  export CSC_CURRENT_MACHINE_IP=$CSA_MASTER_IP

  deploy_cluster_resources

  echo ""; echo "=== Running cludera manager installer"; echo "";
  ./expect_scripts/deploy_cloudera_manager.sh
fi


unset CLUSTER_RESOURCES_DEPLOYED


echo " "
echo " "













