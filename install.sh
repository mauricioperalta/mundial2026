#!/bin/bash
# ============================================================
#  AudiMundial — Script de instalación automática
#  Compatible con Ubuntu 24.04 LTS
#  Uso: sudo bash install.sh
# ============================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ─── Verificar que se corre como root ───────────────────────
if [ "$EUID" -ne 0 ]; then
  error "Ejecutá el script como root: sudo bash install.sh"
fi

echo ""
echo -e "${CYAN}=================================================${NC}"
echo -e "${CYAN}   AudiMundial — Instalación automática         ${NC}"
echo -e "${CYAN}=================================================${NC}"
echo ""

# ─── Variables configurables ────────────────────────────────
APP_DIR="/opt/audimundial"
APP_USER="audimundial"

# ─── 1. Actualizar sistema ──────────────────────────────────
info "Actualizando el sistema..."
apt update -qq && apt upgrade -y -qq
success "Sistema actualizado"

# ─── 2. Instalar dependencias base ──────────────────────────
info "Instalando dependencias base..."
apt install -y -qq git curl nano ufw
success "Dependencias base instaladas"

# ─── 3. Instalar Node.js 20 ─────────────────────────────────
info "Instalando Node.js 20..."
if ! command -v node &>/dev/null || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 20 ]]; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
  apt install -y -qq nodejs
  success "Node.js $(node -v) instalado"
else
  success "Node.js $(node -v) ya instalado"
fi

# ─── 4. Instalar Docker ─────────────────────────────────────
info "Instalando Docker..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | bash > /dev/null 2>&1
  success "Docker instalado"
else
  success "Docker ya instalado"
fi

# ─── 5. Instalar Docker Compose ─────────────────────────────
info "Instalando Docker Compose..."
if ! command -v docker-compose &>/dev/null; then
  apt install -y -qq docker-compose
  success "Docker Compose instalado"
else
  success "Docker Compose ya instalado"
fi

# ─── 6. Crear usuario del sistema ───────────────────────────
info "Creando usuario del sistema '$APP_USER'..."
if ! id "$APP_USER" &>/dev/null; then
  useradd -r -m -d "$APP_DIR" -s /bin/bash "$APP_USER"
  usermod -aG docker "$APP_USER"
  success "Usuario '$APP_USER' creado"
else
  warn "Usuario '$APP_USER' ya existe, continuando..."
fi

# ─── 7. Clonar repositorio ──────────────────────────────────
echo ""
echo -e "${YELLOW}Ingresá la URL del repositorio GitHub privado:${NC}"
echo -e "${YELLOW}(Ejemplo: https://github.com/tuusuario/audimundial.git)${NC}"
read -rp "URL del repo: " REPO_URL

if [ -d "$APP_DIR/.git" ]; then
  warn "El directorio ya existe. Actualizando..."
  cd "$APP_DIR" && sudo -u "$APP_USER" git pull
else
  info "Clonando repositorio en $APP_DIR..."
  sudo -u "$APP_USER" git clone "$REPO_URL" "$APP_DIR"
fi
success "Repositorio listo"

# ─── 8. Configurar .env ─────────────────────────────────────
cd "$APP_DIR"

if [ ! -f ".env" ]; then
  info "Configurando archivo .env..."
  cp .env.example .env

  echo ""
  echo -e "${YELLOW}─── Configuración del administrador ───${NC}"
  read -rp "Email del administrador: " PB_EMAIL
  read -rsp "Contraseña del administrador: " PB_PASS
  echo ""

  echo ""
  echo -e "${YELLOW}─── Google OAuth (Enter para omitir) ───${NC}"
  read -rp "GOOGLE_CLIENT_ID: " G_ID
  read -rp "GOOGLE_CLIENT_SECRET: " G_SECRET

  sed -i "s|PB_ADMIN_EMAIL=.*|PB_ADMIN_EMAIL=$PB_EMAIL|" .env
  sed -i "s|PB_ADMIN_PASSWORD=.*|PB_ADMIN_PASSWORD=$PB_PASS|" .env
  [ -n "$G_ID" ]     && sed -i "s|GOOGLE_CLIENT_ID=.*|GOOGLE_CLIENT_ID=$G_ID|" .env
  [ -n "$G_SECRET" ] && sed -i "s|GOOGLE_CLIENT_SECRET=.*|GOOGLE_CLIENT_SECRET=$G_SECRET|" .env

  chown "$APP_USER:$APP_USER" .env
  chmod 600 .env
  success "Archivo .env configurado"
else
  warn ".env ya existe, no se sobreescribe"
fi

# ─── 9. Compilar frontend ───────────────────────────────────
info "Instalando dependencias del frontend..."
cd "$APP_DIR/frontend"

# Detectar IP local para PUBLIC_API_BASE
LOCAL_IP=$(hostname -I | awk '{print $1}')

if [ ! -f ".env" ]; then
  echo "PUBLIC_API_BASE=http://$LOCAL_IP:8090" > .env
  chown "$APP_USER:$APP_USER" .env
fi

sudo -u "$APP_USER" npm install --silent
info "Compilando frontend (puede tardar unos minutos)..."
sudo -u "$APP_USER" npm run build
success "Frontend compilado"

cd "$APP_DIR"

# ─── 10. Construir y levantar Docker ────────────────────────
info "Construyendo imagen Docker..."
docker-compose build --quiet
info "Levantando servicios..."
docker-compose up -d
success "Servicios levantados"

# ─── 11. Configurar firewall ────────────────────────────────
info "Configurando firewall..."
ufw allow OpenSSH > /dev/null 2>&1
ufw allow 8090/tcp > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
success "Firewall configurado (SSH y puerto 8090 abiertos)"

# ─── 12. Configurar inicio automático ──────────────────────
info "Configurando inicio automático del servicio..."
cat > /etc/systemd/system/audimundial.service << EOF
[Unit]
Description=AudiMundial App
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=300
User=$APP_USER

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable audimundial.service > /dev/null 2>&1
success "Inicio automático configurado"

# ─── Resumen final ──────────────────────────────────────────
echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}   ¡Instalación completada exitosamente!        ${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo -e "  ${CYAN}Aplicación:${NC}      http://$LOCAL_IP:8090"
echo -e "  ${CYAN}Panel admin:${NC}     http://$LOCAL_IP:8090/_/"
echo ""
echo -e "  ${YELLOW}Próximos pasos:${NC}"
echo -e "  1. Entrá al panel admin y configurá el SMTP en Settings → Mail settings"
echo -e "  2. Configurá la URL pública en Settings → Application URL"
echo -e "  3. (Opcional) Instalá Nginx + Certbot para HTTPS con dominio propio"
echo ""
echo -e "  ${CYAN}Comandos útiles:${NC}"
echo -e "  Ver logs:     docker logs -f fhun_tips"
echo -e "  Reiniciar:    docker-compose -f $APP_DIR/docker-compose.yml restart"
echo -e "  Detener:      docker-compose -f $APP_DIR/docker-compose.yml down"
echo ""
