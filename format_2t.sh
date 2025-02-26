#!/bin/bash

# 定义变量
DISK="/dev/sdb"
PARTITION="${DISK}1"
MOUNT_POINT="/www"
FILESYSTEM="ext4"

# 检查是否已安装所需工具
if ! command -v fdisk &> /dev/null || ! command -v mkfs.ext4 &> /dev/null || ! command -v mount &> /dev/null; then
    echo "Error: Required tools are not installed. Please install fdisk, mkfs.ext4, and mount."
    exit 1
fi

# 创建分区
echo "Creating partition on ${DISK}..."
sudo fdisk ${DISK} << EOF
n
p
1


w
EOF

# 检查分区是否成功创建
if ! lsblk | grep -q "${PARTITION}"; then
    echo "Error: Partition creation failed."
    exit 1
fi

# 创建文件系统
echo "Creating filesystem on ${PARTITION}..."
sudo mkfs.${FILESYSTEM} -i 2048 ${PARTITION}

# 创建挂载点
if [ ! -d ${MOUNT_POINT} ]; then
    echo "Creating mount point ${MOUNT_POINT}..."
    sudo mkdir ${MOUNT_POINT}
fi

# 挂载分区
echo "Mounting ${PARTITION} to ${MOUNT_POINT}..."
sudo mount ${PARTITION} ${MOUNT_POINT}

# 验证挂载
if ! mount | grep -q "${MOUNT_POINT}"; then
    echo "Error: Mount failed."
    exit 1
fi

# 更新fstab以实现自动挂载（可选）
echo "Updating /etc/fstab for automatic mounting..."
echo "${PARTITION}    ${MOUNT_POINT}    ${FILESYSTEM}    defaults    0 0" | sudo tee -a /etc/fstab > /dev/null

# 完成
echo "SSD formatted and mounted to ${MOUNT_POINT} successfully."
