#!/bin/bash
# push.sh - 智能提交脚本

# 自动定位到仓库根目录
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "❌ 当前不在 git 仓库内"
    exit 1
fi
cd "$REPO_ROOT"

# 删除仿真产生的临时文件（可选）
echo "清理临时文件..."
cd /workspaces/ic_study/project/sim && make clean
cd /workspaces/ic_study/project/syn && make clean
cd /workspaces/ic_study

# 提交信息，默认为 "更新代码"
MSG=${1:-"更新代码"}

git add .
git commit -m "$MSG"
git push

echo "✅ 提交成功: $MSG"
