echo "== Copying/Preparing key"
cp ~/cluster_resources/id_rsa ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

echo "== Adding the cluster's public key to the authorized_keys file"
PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`
FOUND_PUBLIC_KEY=`grep -o "$PUBLIC_KEY" ~/.ssh/authorized_keys`

if [ "$PUBLIC_KEY" != "$FOUND_PUBLIC_KEY" ]; then
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

echo 'Key installation done . '
  