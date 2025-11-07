#!/bin/bash
set -euo pipefail

BASE_DIR=/home/vagrant/projects               # 프로젝트 묶음 루트
PROJECT_DIR=${BASE_DIR}/django_test           # 실제 레포가 위치할 폴더
REPO_URL=https://github.com/gyuseok-1316/django_test.git
BRANCH=main

# 1) 디렉토리 준비
mkdir -p ${BASE_DIR}

if [ -d "${PROJECT_DIR}/.git" ]; then
    echo "[INFO] Git repo exists. Pulling changes..."
    cd "${PROJECT_DIR}"
    git fetch origin
    git reset --hard origin/$BRANCH
else
    echo "[INFO] Git repo NOT found. Cloning fresh..."
    rm -rf "${PROJECT_DIR}"
    git clone -b $BRANCH "$REPO_URL" "$PROJECT_DIR"
    cd "${PROJECT_DIR}"
fi

# 2) 가상환경 준비
cd "${PROJECT_DIR}"
python3 -m venv venv || true
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

# 3) 장고 작업
python3 manage.py migrate --noinput
python3 manage.py makemigrations --noinput
python3 manage.py migrate --noinput
python3 manage.py collectstatic --noinput

# 4) 기존 runserver 종료
pkill -f "manage.py runserver" || true

# 5) runserver 백그라운드 실행
nohup python3 manage.py runserver 0.0.0.0:8000 > /var/log/pybo_run.log 2>&1 &

echo "DEPLOY_OK $(date)"
