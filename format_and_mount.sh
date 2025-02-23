#!/bin/bash

# 定义变量
DISK="/dev/sdb"
MOUNT_POINT="/www"
FILESYSTEM="ext4"

# 检查是否已安装所需工具
if ! command -v parted &> /dev/null || ! command -v mkfs.ext4 &> /dev/null || ! command -v mount &> /dev/null; then
    echo "Error: Required tools are not installed. Please install parted, mkfs.ext4, and mount."
    exit 1
fi

# 使用 parted 创建 GPT 分区表并分区
echo "Creating GPT partition table and partition on ${DISK}..."
sudo parted -s ${DISK} mklabel gpt
sudo parted -s --align optimal ${DISK} mkpart primary ext4 0% 100%

# 等待分区同步
sync

# 创建文件系统
echo "Creating filesystem on ${DISK}..."
sudo mkfs.${FILESYSTEM} -i 2048 ${DISK}

# 创建挂载点（如果不存在）
if [ ! -d ${MOUNT_POINT} ]; then
    echo "Creating mount point ${MOUNT_POINT}..."
    sudo mkdir ${MOUNT_POINT}
fi

# 挂载分区
echo "Mounting ${DISK} to ${MOUNT_POINT}..."
sudo mount ${DISK} ${MOUNT_POINT}

# 验证挂载
if ! mount | grep -q "${MOUNT_POINT}"; then
    echo "Error: Mount failed."
    exit 1
fi

# 更新 /etc/fstab 实现自动挂载（可选）
echo "Updating /etc/fstab for automatic mounting..."
echo "${DISK}    ${MOUNT_POINT}    ${FILESYSTEM}    defaults    0 0" | sudo tee -a /etc/fstab > /dev/null

# 完成
echo "8TB SSD formatted with GPT and mounted to ${MOUNT_POINT} successfully."
