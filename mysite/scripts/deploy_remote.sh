#!/bin/bash
set -euo pipefail

# 실제 배포되는 디렉토리
PROJECT_DIR=/home/vagrant/projects/

# GitHub repository
REPO_URL=https://github.com/gyuseok-1316/django_test.git
BRANCH=main

echo "[INFO] Deploying to: ${PROJECT_DIR}"

# 1) 프로젝트 디렉토리 준비
mkdir -p ${PROJECT_DIR}

# 2) clone 또는 pull
if [ -d "${PROJECT_DIR}/.git" ]; then
    echo "[INFO] Existing Git repo found. Pulling latest changes..."
    cd "${PROJECT_DIR}"
    git fetch origin
    git reset --hard origin/${BRANCH}
else
    echo "[INFO] Git repo NOT found. Cloning fresh..."
    rm -rf "${PROJECT_DIR}"
    git clone -b ${BRANCH} "${REPO_URL}" "${PROJECT_DIR}"
    cd "${PROJECT_DIR}"
fi

# 3) 가상환경 준비
cd "${PROJECT_DIR}"
python3 -m venv venv || true
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

# 4) Django 작업
python3 manage.py makemigrations --noinput || true
python3 manage.py migrate --noinput
python3 manage.py collectstatic --noinput

# 5) 기존 runserver 종료
pkill -f "manage.py runserver" || true

# 6) runserver 재시작
nohup python3 manage.py runserver 0.0.0.0:8000 > /var/log/mysite_run.log 2>&1 &

echo "DEPLOY_OK $(date)"

