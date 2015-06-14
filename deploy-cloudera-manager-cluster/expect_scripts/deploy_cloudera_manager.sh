#!/bin/bash
set -v

# Run the installation script on master
SSH_CMD="ssh -t -i cluster_resources/id_rsa $CSA_ADMIN_UNAME@$CSA_MASTER_IP"

${SSH_CMD} "bash -l -c '~/cluster_resources/install_cloudera_manager.sh; exit'"

set +v 