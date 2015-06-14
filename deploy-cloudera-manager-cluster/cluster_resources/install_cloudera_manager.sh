echo "== Downloading cloudera manager installer"

set -v 

cat ~/cluster_resources/props/cm_installer.v | xargs -0 wget -O ~/cluster_resources/cloudera-manager-installer.bin

chmod +x ~/cluster_resources/cloudera-manager-installer.bin

sudo ~/cluster_resources/cloudera-manager-installer.bin

set +v

