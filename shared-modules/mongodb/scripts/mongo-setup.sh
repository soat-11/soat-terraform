#!/bin/bash

# =============================================================================
# MongoDB Setup Script
# =============================================================================
# Script de inicialização para MongoDB em EC2.
# Variáveis injetadas via templatefile():
#   - ${mongo_user}
#   - ${mongo_password}
#   - ${mongo_version}
#   - ${database_name}
# =============================================================================

set -e

# --- CONFIGURAÇÃO ---
DEVICE="/dev/xvdf"
MOUNT_POINT="/data"
LOG_FILE="/var/log/bootstrap.log"
MONGO_VERSION="${mongo_version}"

# Redireciona output para log
exec > >(tee -a $LOG_FILE) 2>&1
echo "=== Bootstrap iniciado em $(date) ==="
echo "MongoDB Version: $MONGO_VERSION"

# =============================================================================
# ETAPA 1: AGUARDAR VOLUME EBS
# =============================================================================

echo "Aguardando dispositivo $DEVICE..."
WAIT_COUNT=0
MAX_WAIT=60

while [ ! -b $DEVICE ]; do
  sleep 5
  WAIT_COUNT=$((WAIT_COUNT + 1))
  echo "Tentativa $WAIT_COUNT de $MAX_WAIT..."
  
  if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
    echo "ERRO: Dispositivo $DEVICE não encontrado após $MAX_WAIT tentativas"
    exit 1
  fi
done

echo "Dispositivo $DEVICE encontrado!"

# =============================================================================
# ETAPA 2: FORMATAR DISCO (IDEMPOTENTE)
# =============================================================================

if ! blkid $DEVICE > /dev/null 2>&1; then
  echo "Formatando $DEVICE com XFS..."
  mkfs.xfs $DEVICE
else
  echo "Disco já formatado, pulando formatação."
fi

# =============================================================================
# ETAPA 3: MONTAR DISCO
# =============================================================================

echo "Criando mount point $MOUNT_POINT..."
mkdir -p $MOUNT_POINT

echo "Montando $DEVICE em $MOUNT_POINT..."
mount $DEVICE $MOUNT_POINT

# Obtém UUID para persistência
UUID=$(blkid -s UUID -o value $DEVICE)

# Adiciona ao fstab se ainda não existir (idempotente)
if ! grep -q "$UUID" /etc/fstab; then
  echo "Adicionando entrada ao fstab..."
  echo "UUID=$UUID $MOUNT_POINT xfs defaults,nofail 0 2" >> /etc/fstab
else
  echo "Entrada já existe no fstab."
fi

echo "Disco montado com sucesso!"
df -h $MOUNT_POINT

# =============================================================================
# ETAPA 4: INSTALAR DOCKER
# =============================================================================

echo "Atualizando sistema..."
yum update -y

echo "Instalando Docker..."
amazon-linux-extras install docker -y

echo "Iniciando Docker..."
systemctl start docker
systemctl enable docker

usermod -a -G docker ec2-user

echo "Docker instalado e rodando!"
docker --version

# =============================================================================
# ETAPA 5: SUBIR MONGODB
# =============================================================================

echo "Iniciando MongoDB $MONGO_VERSION..."
docker run -d \
  --name mongodb \
  --restart always \
  -p 27017:27017 \
  -v $MOUNT_POINT/db:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=${mongo_user} \
  -e MONGO_INITDB_ROOT_PASSWORD=${mongo_password} \
  -e MONGO_INITDB_DATABASE=${database_name} \
  mongo:$MONGO_VERSION

echo "MongoDB iniciado!"

# =============================================================================
# ETAPA 6: HEALTH CHECK
# =============================================================================

echo "Aguardando MongoDB inicializar..."
sleep 10

# Verifica se o container está rodando
if docker ps | grep -q mongodb; then
  echo "✓ MongoDB container está rodando"
else
  echo "✗ ERRO: MongoDB container não está rodando"
  docker logs mongodb
  exit 1
fi

echo "=== Bootstrap finalizado em $(date) ==="

