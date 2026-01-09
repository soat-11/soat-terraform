#!/bin/bash
# =============================================================================
# Bootstrap Base Template - Database EC2 Module
# =============================================================================
# Template base para scripts de inicialização de bancos de dados.
# Este script deve ser usado como referência ou incluído via templatefile().
#
# Responsabilidades:
#   1. Aguardar o volume EBS ser anexado (race condition fix)
#   2. Formatar o disco apenas se necessário (idempotente)
#   3. Montar o disco em /data com persistência via fstab
#   4. Instalar e iniciar Docker
#
# Uso:
#   Copie este script para sua stack e adicione o comando do container no final.
#   Use templatefile() para injetar variáveis (ex: credenciais do banco).
# =============================================================================

set -e

# --- CONFIGURAÇÃO ---
DEVICE="/dev/xvdf"
MOUNT_POINT="/data"
LOG_FILE="/var/log/bootstrap.log"

# Redireciona output para log
exec > >(tee -a $LOG_FILE) 2>&1
echo "=== Bootstrap iniciado em $(date) ==="

# =============================================================================
# ETAPA 1: AGUARDAR VOLUME EBS
# =============================================================================
# O Terraform pode levar alguns segundos para anexar o volume após o boot.
# Este loop aguarda até o dispositivo estar disponível.

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
# Formata apenas se o disco não tiver sistema de arquivos.
# Isso previne perda de dados em reboots ou recriações de instância.

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

# Obtém UUID para persistência (mais confiável que device name)
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

# Permite ec2-user rodar docker sem sudo
usermod -a -G docker ec2-user

echo "Docker instalado e rodando!"
docker --version

# =============================================================================
# ETAPA 5: SUBIR CONTAINER DO BANCO
# =============================================================================
# ADICIONE SEU COMANDO DOCKER RUN AQUI
#
# Exemplo MongoDB:
# docker run -d \
#   --name mongodb \
#   --restart always \
#   -p 27017:27017 \
#   -v $MOUNT_POINT/db:/data/db \
#   -e MONGO_INITDB_ROOT_USERNAME=admin \
#   -e MONGO_INITDB_ROOT_PASSWORD=senha_segura \
#   mongo:6.0
#
# Exemplo PostgreSQL:
# docker run -d \
#   --name postgres \
#   --restart always \
#   -p 5432:5432 \
#   -v $MOUNT_POINT/pgdata:/var/lib/postgresql/data \
#   -e POSTGRES_USER=admin \
#   -e POSTGRES_PASSWORD=senha_segura \
#   -e POSTGRES_DB=mydb \
#   postgres:15-alpine
#
# =============================================================================

echo "=== Bootstrap finalizado em $(date) ==="

