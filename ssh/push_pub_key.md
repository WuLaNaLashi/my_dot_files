# 1. 生成密钥对（如果尚未生成）
ssh-keygen -t ed25519 -C "hanxiaoguang@aiforctech.com"

# 2. 将公钥上传至目标服务器
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@hostname

# 3. 在 ~/.ssh/config 配置密钥路径
Host myserver
  HostName 192.168.1.100
  User myuser
  IdentityFile ~/.ssh/id_ed25519  # 指定私钥文件
