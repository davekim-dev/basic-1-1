#!/bin/bash
set -e

CONTAINER_NAME="server"
AGENT_APP_SRC="$HOME/Downloads/agent-app"

# 기존 컨테이너 정리 (재실행 대비)
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo ">>> 기존 '$CONTAINER_NAME' 컨테이너를 제거합니다."
  docker rm -f "$CONTAINER_NAME"
fi

# ────────────────────────────────────────────────────
# 1. 컨테이너 생성 (기능 보안 및 네트워크 설정)
# ────────────────────────────────────────────────────
echo ""
echo "=== [1/15] 컨테이너 생성 (ubuntu:noble) ==="
docker run -dit \
  --name "$CONTAINER_NAME" \
  --init \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -p 15034:15034 \
  ubuntu:noble \
  /bin/bash

# ────────────────────────────────────────────────────
# 2. 패키지 업데이트 / 설치 / 타임존 설정
# ────────────────────────────────────────────────────
echo ""
echo "=== [2/15] 패키지 설치 및 타임존 설정 (Asia/Seoul) ==="
docker exec "$CONTAINER_NAME" bash -c "
  apt-get update -q &&
  DEBIAN_FRONTEND=noninteractive TZ=Asia/Seoul \
    apt-get install -y openssh-server ufw tzdata iproute2 cron &&
  ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime &&
  echo 'Asia/Seoul' > /etc/timezone
"

# ────────────────────────────────────────────────────
# 3. SSH 설정 (포트 20022 변경 / root 원격 로그인 차단)
# ────────────────────────────────────────────────────
echo ""
echo "=== [3/15] SSH 설정 — 포트 20022 / PermitRootLogin no ==="
docker exec "$CONTAINER_NAME" bash -c "
  sed -i 's/#Port 22/Port 20022/' /etc/ssh/sshd_config &&
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config &&
  service ssh restart
"

# ────────────────────────────────────────────────────
# 4. UFW 방화벽 설정
# ────────────────────────────────────────────────────
echo ""
echo "=== [4/15] UFW 방화벽 설정 (20022/tcp, 15034/tcp 허용) ==="
docker exec "$CONTAINER_NAME" bash -c "
  ufw default deny incoming &&
  ufw default allow outgoing &&
  ufw allow 20022/tcp &&
  ufw allow 15034/tcp &&
  ufw --force enable
"

# ────────────────────────────────────────────────────
# 5. 계정 생성 (agent-admin / agent-dev / agent-test)
# ────────────────────────────────────────────────────
echo ""
echo "=== [5/15] 계정 생성 (agent-admin / agent-dev / agent-test) ==="
docker exec "$CONTAINER_NAME" bash -c "
  useradd -m -s /bin/bash agent-admin &&
  echo 'agent-admin:Admin1234!' | chpasswd &&
  useradd -m -s /bin/bash agent-dev &&
  echo 'agent-dev:Dev1234!'   | chpasswd &&
  useradd -m -s /bin/bash agent-test &&
  echo 'agent-test:Test1234!' | chpasswd
"

# ────────────────────────────────────────────────────
# 6. 그룹 생성 및 계정 추가
#    agent-common: admin + dev + test
#    agent-core  : admin + dev
# ────────────────────────────────────────────────────
echo ""
echo "=== [6/15] 그룹 생성 및 계정 추가 (agent-common / agent-core) ==="
docker exec "$CONTAINER_NAME" bash -c "
  groupadd agent-common &&
  usermod -aG agent-common agent-admin &&
  for user in agent-dev agent-test; do usermod -aG agent-common \$user; done &&
  groupadd agent-core &&
  for user in agent-admin agent-dev; do usermod -aG agent-core \$user; done
"

# ────────────────────────────────────────────────────
# 7. 디렉토리 구조 및 권한 설정
#    /opt/agent/upload_files  → agent-common (770)
#    /opt/agent/api_keys      → agent-core   (770)
#    /var/log/agent-app       → agent-core   (770)
# ────────────────────────────────────────────────────
echo ""
echo "=== [7/15] 디렉토리 구조 및 권한 설정 ==="
docker exec "$CONTAINER_NAME" bash -c "
  mkdir -p /opt/agent/api_keys /opt/agent/upload_files /var/log/agent-app &&
  chown root:agent-common /opt/agent/upload_files &&
  chmod 770 /opt/agent/upload_files &&
  chown root:agent-core /opt/agent/api_keys &&
  chmod 770 /opt/agent/api_keys &&
  chown root:agent-core /var/log/agent-app &&
  chmod 770 /var/log/agent-app
"

# ────────────────────────────────────────────────────
# 8. 앱 디렉토리 / 키 파일 생성 + 바이너리 복사
# ────────────────────────────────────────────────────
echo ""
echo "=== [8/15] 앱 디렉토리·키 파일 생성 및 agent-app 바이너리 복사 ==="
docker exec "$CONTAINER_NAME" bash -c "
  mkdir -p /home/agent-admin/agent-app/api_keys \
           /home/agent-admin/agent-app/upload_files &&
  echo 'agent_api_key_test' > /home/agent-admin/agent-app/api_keys/secret.key &&
  chown agent-admin:agent-admin /home/agent-admin/agent-app &&
  chown root:agent-common /home/agent-admin/agent-app/upload_files &&
  chmod 770 /home/agent-admin/agent-app/upload_files &&
  chown root:agent-core /home/agent-admin/agent-app/api_keys &&
  chmod 770 /home/agent-admin/agent-app/api_keys &&
  chown agent-admin:agent-core /home/agent-admin/agent-app/api_keys/secret.key &&
  chmod 660 /home/agent-admin/agent-app/api_keys/secret.key
"

# 컨테이너 아키텍처 확인 후 맞는 바이너리 선택
CONTAINER_ARCH=$(docker exec "$CONTAINER_NAME" uname -m)
if [ "$CONTAINER_ARCH" = "aarch64" ]; then
  BINARY_NAME="agent-app-linux-arm64"
else
  BINARY_NAME="agent-app-linux-x86"
fi
echo ">>> 컨테이너 아키텍처: $CONTAINER_ARCH → $BINARY_NAME 복사"

docker cp "$AGENT_APP_SRC/$BINARY_NAME" "$CONTAINER_NAME:/home/agent-admin/agent-app/agent-app"

docker exec "$CONTAINER_NAME" bash -c "
  chown agent-admin:agent-admin /home/agent-admin/agent-app/agent-app &&
  chmod +x /home/agent-admin/agent-app/agent-app
"

# ────────────────────────────────────────────────────
# 9. 시스템 환경 변수 설정 (/etc/environment)
#    su - 로그인 셸 전환 시 PAM이 자동 로드 — 중복 export 불필요
# ────────────────────────────────────────────────────
echo ""
echo "=== [9/15] 시스템 환경 변수 설정 (/etc/environment) ==="
docker exec "$CONTAINER_NAME" bash -c "
  cat >> /etc/environment << 'EOF'
AGENT_HOME=/home/agent-admin/agent-app
AGENT_PORT=15034
AGENT_UPLOAD_DIR=/home/agent-admin/agent-app/upload_files
AGENT_KEY_PATH=/home/agent-admin/agent-app/api_keys
AGENT_LOG_DIR=/var/log/agent-app
EOF

  cat > /etc/profile.d/agent-env.sh << 'PROFEOF'
export AGENT_HOME=/home/agent-admin/agent-app
export AGENT_PORT=15034
export AGENT_UPLOAD_DIR=/home/agent-admin/agent-app/upload_files
export AGENT_KEY_PATH=/home/agent-admin/agent-app/api_keys
export AGENT_LOG_DIR=/var/log/agent-app
PROFEOF
  chmod 644 /etc/profile.d/agent-env.sh

  echo '--- /etc/environment ---'
  cat /etc/environment
  echo ''
  echo '--- /etc/profile.d/agent-env.sh ---'
  cat /etc/profile.d/agent-env.sh
"

# ────────────────────────────────────────────────────
# 10. 계정 / 그룹 현황 출력
# ────────────────────────────────────────────────────
echo ""
echo "=== [10/15] 계정 / 그룹 현황 ==="
echo ""
echo "--- /etc/passwd (agent 계정) ---"
docker exec "$CONTAINER_NAME" bash -c "cat /etc/passwd | grep agent"
echo ""
echo "--- /etc/group (agent 그룹) ---"
docker exec "$CONTAINER_NAME" bash -c "cat /etc/group | grep agent"

# ────────────────────────────────────────────────────
# 11. monitor.sh 파일 생성 및 권한 설정
#     /home/agent-admin/agent-app/bin/monitor.sh
#     owner: agent-dev:agent-core / 750
# ────────────────────────────────────────────────────
echo ""
echo "=== [11] monitor.sh 파일 생성 및 권한 설정 ==="
docker exec "$CONTAINER_NAME" bash -c "
  mkdir -p /home/agent-admin/agent-app/bin &&
  touch /home/agent-admin/agent-app/bin/monitor.sh &&
  chown agent-dev:agent-core /home/agent-admin/agent-app/bin/monitor.sh &&
  chmod 750 /home/agent-admin/agent-app/bin/monitor.sh &&
  ls -l /home/agent-admin/agent-app/bin/monitor.sh
"

# ────────────────────────────────────────────────────
# 12. cron 설치 및 편집
#     */1 * * * * monitor.sh >> monitor.log
# ────────────────────────────────────────────────────
echo ""
echo "=== [12] cron 설치 및 편집 ==="
docker exec "$CONTAINER_NAME" bash -c "
  service cron start &&
  echo '*/1 * * * * /home/agent-admin/agent-app/bin/monitor.sh >> /var/log/agent-app/monitor.log 2>&1' \
    | crontab -u agent-admin - &&
  echo '--- cron 상태 ---' &&
  service cron status &&
  echo '' &&
  echo '--- crontab (agent-admin) ---' &&
  crontab -u agent-admin -l | grep -v '^#' | grep -v '^\$'
"

# ────────────────────────────────────────────────────
# 13. 헬스체크 스크립트 작성
# ────────────────────────────────────────────────────
echo ""
echo "=== [13] 헬스체크 스크립트 작성 ==="
docker exec "$CONTAINER_NAME" bash -c "
  cat > /home/agent-admin/agent-app/bin/monitor.sh << 'MONEOF'
#!/bin/bash

# =====================
# Health Check
# =====================

TIMESTAMP=\$(date '+%Y-%m-%d %H:%M:%S')

# 1. 프로세스 확인
if ! pgrep -f 'agent-app' > /dev/null 2>&1; then
    echo \"[\$TIMESTAMP] [ERROR] agent-app process is not running\"
    exit 1
fi

# 2. 포트 확인
if ! ss -tlnp | grep -q ':15034'; then
    echo \"[\$TIMESTAMP] [ERROR] Port 15034 is not listening\"
    exit 1
fi

echo \"[\$TIMESTAMP] [OK] Health Check Passed\"
MONEOF
  echo '--- monitor.sh 내용 ---'
  cat /home/agent-admin/agent-app/bin/monitor.sh
"

# ────────────────────────────────────────────────────
# 14. 바이너리앱 백그라운드 실행 (agent-admin)
# ────────────────────────────────────────────────────
echo ""
echo "=== [14] 바이너리앱 백그라운드 실행 (agent-admin) ==="
echo ""

echo "--- agent-app 바이너리 확인 ---"
docker exec "$CONTAINER_NAME" ls -la /home/agent-admin/agent-app/agent-app 2>/dev/null || echo "(바이너리 없음)"
echo ""

docker exec "$CONTAINER_NAME" \
  su - agent-admin -c "
    . /etc/profile.d/agent-env.sh
    cd /home/agent-admin/agent-app && nohup ./agent-app > /tmp/agent-run.log 2>&1 &
    echo \$! > /tmp/agent-app.pid
  "

echo ">>> 'Agent READY' 대기 중..."
for i in $(seq 1 15); do
  if docker exec "$CONTAINER_NAME" grep -q "Agent READY" /tmp/agent-run.log 2>/dev/null; then
    docker exec "$CONTAINER_NAME" cat /tmp/agent-run.log
    break
  fi
  sleep 1
done

echo "--- agent-run.log ---"
docker exec "$CONTAINER_NAME" cat /tmp/agent-run.log 2>/dev/null || echo "(run log 없음)"

# ────────────────────────────────────────────────────
# 15. 프로세스 및 포트 확인
# ────────────────────────────────────────────────────
echo ""
echo "=== [15] 프로세스 및 포트 확인 ==="
echo ""
echo "--- 프로세스 (pgrep -f agent-app) ---"
docker exec "$CONTAINER_NAME" pgrep -f agent-app || echo "(실행 중인 agent-app 없음)"
echo ""
echo "--- 포트 (ss -tlnp | grep 15034) ---"
docker exec "$CONTAINER_NAME" ss -tlnp | grep 15034 || echo "(15034 포트 미감지)"

# ────────────────────────────────────────────────────
# 16. monitor.log 헬스체크 결과 출력
# ────────────────────────────────────────────────────
echo ""
echo "=== [16] monitor.log 헬스체크 결과 출력 ==="
echo ""
echo ">>> Health Check 실행 중 (5회)..."
docker exec "$CONTAINER_NAME" bash -c "
  for i in 1 2 3 4 5; do
    bash /home/agent-admin/agent-app/bin/monitor.sh >> /var/log/agent-app/monitor.log 2>&1 || true
    sleep 1
  done
"
echo ""
echo "--- cat /var/log/agent-app/monitor.log ---"
docker exec "$CONTAINER_NAME" cat /var/log/agent-app/monitor.log

echo ""
echo "================================================================"
echo "  완료."
echo "================================================================"
