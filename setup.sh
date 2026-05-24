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
echo "=== [1/11] 컨테이너 생성 (ubuntu:noble) ==="
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
echo "=== [2/11] 패키지 설치 및 타임존 설정 (Asia/Seoul) ==="
docker exec "$CONTAINER_NAME" bash -c "
  apt-get update -q &&
  DEBIAN_FRONTEND=noninteractive TZ=Asia/Seoul \
    apt-get install -y openssh-server ufw tzdata &&
  ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime &&
  echo 'Asia/Seoul' > /etc/timezone
"

# ────────────────────────────────────────────────────
# 3. SSH 설정 (포트 20022 변경 / root 원격 로그인 차단)
# ────────────────────────────────────────────────────
echo ""
echo "=== [3/11] SSH 설정 — 포트 20022 / PermitRootLogin no ==="
docker exec "$CONTAINER_NAME" bash -c "
  sed -i 's/#Port 22/Port 20022/' /etc/ssh/sshd_config &&
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config &&
  service ssh restart
"

# ────────────────────────────────────────────────────
# 4. UFW 방화벽 설정
# ────────────────────────────────────────────────────
echo ""
echo "=== [4/11] UFW 방화벽 설정 (20022/tcp, 15034/tcp 허용) ==="
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
echo "=== [5/11] 계정 생성 (agent-admin / agent-dev / agent-test) ==="
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
echo "=== [6/11] 그룹 생성 및 계정 추가 (agent-common / agent-core) ==="
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
echo "=== [7/11] 디렉토리 구조 및 권한 설정 ==="
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
echo "=== [8/11] 앱 디렉토리·키 파일 생성 및 agent-app 바이너리 복사 ==="
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

docker cp "$AGENT_APP_SRC" "$CONTAINER_NAME:/home/agent-admin/agent-app/agent-app"

docker exec "$CONTAINER_NAME" bash -c "
  chown agent-admin:agent-admin /home/agent-admin/agent-app/agent-app &&
  chmod +x /home/agent-admin/agent-app/agent-app
"

# ────────────────────────────────────────────────────
# 9. 시스템 환경 변수 설정 (/etc/environment)
#    su - 로그인 셸 전환 시 PAM이 자동 로드 — 중복 export 불필요
# ────────────────────────────────────────────────────
echo ""
echo "=== [9/11] 시스템 환경 변수 설정 (/etc/environment) ==="
docker exec "$CONTAINER_NAME" bash -c "
  cat >> /etc/environment << 'EOF'
AGENT_HOME=/home/agent-admin/agent-app
AGENT_PORT=15034
AGENT_UPLOAD_DIR=/home/agent-admin/agent-app/upload_files
AGENT_KEY_PATH=/home/agent-admin/agent-app/api_keys/secret.key
AGENT_LOG_DIR=/var/log/agent-app
EOF
"

# ────────────────────────────────────────────────────
# 10. 계정 / 그룹 현황 출력
# ────────────────────────────────────────────────────
echo ""
echo "=== [10/11] 계정 / 그룹 현황 ==="
echo ""
echo "--- /etc/passwd (agent 계정) ---"
docker exec "$CONTAINER_NAME" bash -c "cat /etc/passwd | grep agent"
echo ""
echo "--- /etc/group (agent 그룹) ---"
docker exec "$CONTAINER_NAME" bash -c "cat /etc/group | grep agent"

# ────────────────────────────────────────────────────
# 11. agent-app 실행 — 'Agent READY' 출력 시 스크립트 종료
#     /etc/environment 가 su - 로그인 셸에 자동 적용되므로
#     별도 export 없이 바로 실행
# ────────────────────────────────────────────────────
echo ""
echo "=== [11/11] agent-app 실행 — 'Agent READY' 확인 시 스크립트 종료 ==="
echo ""

docker exec "$CONTAINER_NAME" \
  su - agent-admin -c "
    cd \$AGENT_HOME && ./agent-app
  " | sed '/Agent READY/q'

echo ""
echo "================================================================"
echo "  설정 완료: 'Agent READY' 확인됨."
echo "  컨테이너 '$CONTAINER_NAME' 는 백그라운드에서 계속 실행됩니다."
echo "  (docker exec -it $CONTAINER_NAME bash 로 접속 가능)"
echo "================================================================"
