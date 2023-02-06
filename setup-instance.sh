#!/bin/bash

main_function() {
USER='opc'

# Resize root partition
printf "fix\n" | parted ---pretend-input-tty /dev/sda print
VALUE=$(printf "unit s\nprint\n" | parted ---pretend-input-tty /dev/sda |  grep lvm | awk '{print $2}' | rev | cut -c2- | rev)
printf "rm 3\nIgnore\n" | parted ---pretend-input-tty /dev/sda
printf "unit s\nmkpart\n/dev/sda3\n\n$VALUE\n100%%\n" | parted ---pretend-input-tty /dev/sda
pvresize /dev/sda3
pvs
vgs
lvextend -l +100%FREE /dev/mapper/ocivolume-root
xfs_growfs -d /

dnf install git python3.9 -y

# Install ffmpeg
sudo dnf -y install https://download.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
sudo dnf config-manager --set-enabled ol8_codeready_builder
sudo dnf -y install ffmpeg

# Stable diffusion service
cat <<EOT > /etc/systemd/system/automatic1111.service
[Unit]
Description=systemd service start automatic1111

[Service]
Environment="python_cmd=python3.9"
ExecStart=/bin/bash /home/$USER/stable-diffusion-webui/webui.sh --api
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
# Image SmartCrop extension
su -c "git clone https://github.com/d8ahazard/sd_smartprocess /home/$USER/stable-diffusion-webui/extensions/sd_smartprocess" $USER
# Remove background extension
su -c "git clone https://github.com/KutsuyaYuki/ABG_extension /home/$USER/stable-diffusion-webui/extensions/ABG_extension" $USER
# OutPaint extension
su -c "git clone https://github.com/zero01101/openOutpaint-webUI-extension /home/$USER/stable-diffusion-webui/extensions/openOutpaint-webUI-extension" $USER
# Deforum extension
su -c "git clone https://github.com/deforum-art/deforum-for-automatic1111-webui /home/$USER/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui" $USER
# Image Browser extension
su -c "git clone https://github.com/yfszzx/stable-diffusion-webui-images-browser /home/$USER/stable-diffusion-webui/extensions/stable-diffusion-webui-images-browser" $USER

# Download model
su -c "wget https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt -O /home/$USER/stable-diffusion-webui/models/Stable-diffusion/v1-5-pruned-emaonly.ckpt" $USER

systemctl daemon-reload
systemctl enable automatic1111.service
systemctl start automatic1111.service
}

main_function 2>&1 >> /var/log/startup.log
