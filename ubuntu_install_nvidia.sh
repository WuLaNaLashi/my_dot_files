#! /usr/bin/bash

# Test on ubuntu1804 & 2004

# ROOT 确认
if [ `id -u` -ne 0 ]; then
    echo "Error: This file has to be run with superuser privileges (under the root user on most systems)."
    exit 1
fi

# LOG输出
LOGFILE="/var/log/nvidia_driver_setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

# 阶段性输出
echo "只装驱动、不装 CUDA 和 cuDNN.确实需要再说."
echo "执行顺序: "
echo "1. 移除Nvidia Driver相关的内容."
echo "2. 移除CUDA."
echo "3. 安装特定版本驱动."
echo "=================安装后黑屏或者循环登录问题可以尝试卸载驱动相关=====================."
read -p "骚年，你渴望力量吗? [Y/n] " ans
if [[ "$ans" != "Y" && "$ans" != "y" && "$ans" != "" ]]; then
  echo "正确的选择，安装啥破驱动，能用就行，不行试试系统自带的额外驱动安装程序."
  exit 1
fi

# Remove CUDA 
/usr/local/cuda/bin/cuda-uninstaller

# Remove Nvidia 
apt-get remove --purge "*nvidia*" -y

# Find and delete
find /usr/lib -iname "*nvidia*" -delete

# Add 'nouveau' to /etc/modules
# echo 'nouveau' | sudo tee -a /etc/modules

# Remove xorg.conf
rm /etc/X11/xorg.conf

# A function to ask whether to reboot or not
reboot() {
  read -p "Reboot now? [Y/n] " ans
  if [[ "$ans" == "Y" || "$ans" == "y"  || "$ans" == "" ]]; then
    sync; sync; sync; systemctl reboot
  else
    read -n 1 -s -r -p "Press any key to exit..."
    echo
  fi
  exit 0
}

# Ask the user if they want to reinstall Nvidia drivers
echo "NVIDIA相关东西我已经删除了." 
read -p "确定执行后边的安装程序? [Y/n] " ans
if [[ "$ans" != "Y" && "$ans" != "y" && "$ans" != "" ]]; then
  echo "不安装，使用开源Nouveau."
  echo "See the log file at $LOGFILE"
  reboot
fi

# Install nvidia-common
apt-get install nvidia-common

# Add graphics-drivers PPA
echo | add-apt-repository ppa:graphics-drivers

# Update package list
apt-get update

# Check available drivers
echo
echo "查找可以安装的选项. 等会儿..."
echo
driver_info=$(ubuntu-drivers devices)

# Show options
devices_info=()
while IFS= read -r line; do
  devices_info+=("$line")
done <<< "$driver_info"

echo "Driver options:"
for ((i=4; i<${#devices_info[@]}; i++)); do
  option="${devices_info[$i]#*: }"
  echo "($((i-3))) $option"
done

while true; do
  read -p "Please select which to install: " choice

  if [[ $choice =~ ^[1-9][0-9]*$ && $choice -le $(( ${#devices_info[@]} - 4 )) ]]; then
    selected_driver=$(echo "${devices_info[$((choice+3))]}" | awk '{for(i=3;i<=NF;i++)printf "%s ", $i; print ""}')
    pkg_name=$(echo "${devices_info[$((choice+3))]}" | awk '{print $3}')
    read -p "Installing '$selected_driver', is that what you want? [Y/n] " ans

    if [[ "$ans" == "Y" || "$ans" == "y" || "$ans" == "" ]]; then
      break
    fi

  else
    echo "Error: Invalid input."
  fi
done

# Install the Nvidia driver choosen by user
apt-get install $pkg_name -y

# Clean the unused files
apt-get autoremove
apt-get autoclean

# Finish
echo
echo "'$selected_driver' <--- 这个版本的驱动安装好了. 需要CUDA和cudnn自己再装吧."
echo "See the log file at $LOGFILE"
echo "现在，Now，马上！！！重启电脑，输入nvidia-smi 确认驱动安装状态."
reboot
