
# Force the excecution of apt-get update
include_recipe "apt"

# Setup Oracle Java
node.normal["java"]["install_flavor"] = "oracle"
node.normal["java"]["jdk_version"] = "7"
node.normal["java"]["oracle"]["accept_oracle_download_terms"] = true
  
include_recipe "java"
