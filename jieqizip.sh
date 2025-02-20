#!/bin/bash

# 设置网站名称（从脚本参数获取）
SITE_NAME=$1

# 设置压缩包名称变量
ARCHIVE_NAME="${SITE_NAME}.zip"

# 输出目录
DIR_OUT="/www/wwwroot/site/"

# 检查并创建输出目录结构
if [ ! -d "$DIR_OUT" ]; then
  mkdir -p "$DIR_OUT/files/article/txt"
  echo "Directory created: $DIR_OUT/files/article/txt"
else
  echo "Directory already exists: $DIR_OUT"
fi

# 设置要压缩的目录和排除的目录
DIRECTORY_TO_ZIP="/www/wwwroot/$SITE_NAME/"
EXCLUDE_DIRECTORY="files"

# 检查要压缩的目录是否存在
if [ ! -d "$DIRECTORY_TO_ZIP" ]; then
  echo "Error: Directory to zip does not exist: $DIRECTORY_TO_ZIP"
  exit 1
fi

# 压缩网站根目录文件，排除files目录
zip -r "$DIR_OUT$ARCHIVE_NAME" "$DIRECTORY_TO_ZIP" -x "$DIRECTORY_TO_ZIP/$EXCLUDE_DIRECTORY/*"

# 压缩image目录（如果存在）
IMAGE_DIR="$DIRECTORY_TO_ZIP/files/article/images"
if [ -d "$IMAGE_DIR" ]; then
  zip -r "$DIR_OUT/files/article/image.zip" "$IMAGE_DIR"
else
  echo "Image directory does not exist: $IMAGE_DIR"
fi

# 进入txt目录进行批量化压缩（如果存在）
TXT_DIR="$DIRECTORY_TO_ZIP/files/article/txt"
if [ -d "$TXT_DIR" ]; then
  cd "$TXT_DIR"
  for i in *; do
    if [ -d "$i" ]; then
      zip -r "$DIR_OUT/files/article/txt/${i}.zip" "$i"
    fi
  done
  cd - # 返回原始目录
else
  echo "Txt directory does not exist: $TXT_DIR"
fi
