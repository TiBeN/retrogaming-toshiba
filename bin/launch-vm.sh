# #!/bin/bash
#
# Launch iso in VirtualBox

script_path=$(readlink -f `dirname $0`)

# Detach previous image

VBoxManage storageattach iso-debian \
  --storagectl SATA \
  --port 0 \
  --type hdd \
  --medium none

# Remove medium from VirtualBox DB

VBoxManage closemedium $script_path/../build/retrogaming.vdi

# Attach the new image

VBoxManage storageattach iso-debian \
  --storagectl SATA \
  --port 0 \
  --type hdd \
  --medium $script_path/../build/retrogaming.vdi

VBoxManage startvm iso-debian
