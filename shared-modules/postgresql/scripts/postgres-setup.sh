#!/bin/bash

# =============================================================================
# PostgreSQL Setup Script
# =============================================================================
# Script de inicialização para PostgreSQL em EC2.
# Variáveis injetadas via templatefile():
#   - ${postgres_user}
#   - ${postgres_password}
#   - ${postgres_version}
#   - ${database_name}
# =============================================================================

set -e

# --- CONFIGURAÇÃO ---
DEVICE="/dev/xvdf"
MOUNT_POINT="/data"
LOG_FILE="/var/log/bootstrap.log"
POSTGRES_VERSION="${postgres_version}"

# Redireciona output para log
exec > >(tee -a $LOG_FILE) 2>&1
echo "=== Bootstrap iniciado em $(date) ==="
echo "PostgreSQL Version: $POSTGRES_VERSION"

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
# ETAPA 5: PREPARAR DIRETÓRIO DE DADOS
# =============================================================================

echo "Preparando diretório de dados PostgreSQL..."
mkdir -p $MOUNT_POINT/pgdata
chmod 700 $MOUNT_POINT/pgdata

# =============================================================================
# ETAPA 6: SUBIR POSTGRESQL
# =============================================================================

echo "Iniciando PostgreSQL $POSTGRES_VERSION..."
docker run -d \
  --name postgres \
  --restart always \
  -p 5432:5432 \
  -v $MOUNT_POINT/pgdata:/var/lib/postgresql/data \
  -e POSTGRES_USER=${postgres_user} \
  -e POSTGRES_PASSWORD=${postgres_password} \
  -e POSTGRES_DB=${database_name} \
  postgres:$POSTGRES_VERSION

echo "PostgreSQL iniciado!"

# =============================================================================
# ETAPA 7: HEALTH CHECK
# =============================================================================

echo "Aguardando PostgreSQL inicializar..."
sleep 15

# Verifica se o container está rodando
if docker ps | grep -q postgres; then
  echo "✓ PostgreSQL container está rodando"
else
  echo "✗ ERRO: PostgreSQL container não está rodando"
  docker logs postgres
  exit 1
fi

echo "=== Bootstrap finalizado em $(date) ==="

