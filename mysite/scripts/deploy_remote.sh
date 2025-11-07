#!/bin/bash
set -euo pipefail

PROJECT_DIR=/home/vagrant/django_git/mysite
REPO_URL=https://github.com/gyuseok-1316/django_test.git
BRANCH=main   # 또는 master

# 1) 디렉토리 준비
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}

# 2) Git repo 존재 여부 확인
if [ -d "$PROJECT_DIR/.git" ]; then
    echo "[INFO] Git repo exists. Pulling changes..."
    cd "$PROJECT_DIR"
    git fetch origin
    git reset --hard origin/$BRANCH
else
    echo "[INFO] Git repo NOT found. Cloning..."
    rm -rf ${PROJECT_DIR}/*   # 혹시 잔여 파일 있는 경우 대비
    rm -rf ${PROJECT_DIR}/.??*
    git clone -b $BRANCH "$REPO_URL" "$PROJECT_DIR"
    cd "$PROJECT_DIR"
fi

# 3) 가상환경 준비
python3 -m venv venv || true
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

# 4) 환경변수 파일(.env)이 필요하면 복사/설정 (수동으로 .env를 서버에 배치)
# cp /home/vagrant/.env.production .env || true

# 5) 장고 작업
python3 manage.py migrate --noinput
python3 manage.py makemigrations --noinput
python3 manage.py migrate --noinput
python3 manage.py collectstatic --noinput

# 6) 기존 runserver 종료 (비정상적인 경우도 있으므로 pkill로 처리)
pkill -f "manage.py runserver" || true
# 7) runserver 백그라운드 실행, 로그는 /var/log/pybo_run.log
nohup python3 manage.py runserver 0.0.0.0:8000 > /var/log/pybo_run.log 2>&1 &

echo "DEPLOY_OK $(date)"

