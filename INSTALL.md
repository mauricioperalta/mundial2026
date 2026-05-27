# AudiMundial — Guía de Instalación

## Requisitos del servidor

- **SO recomendado:** Ubuntu 24.04 LTS
- **RAM mínima:** 1 GB (recomendado 2 GB)
- **Docker** y **Docker Compose**
- **Node.js 20+** (solo para compilar el frontend)
- **Git**
- Puerto **8090** (backend) y **80/443** (si usás Nginx como proxy)

---

## 1. Instalar dependencias en el servidor

```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar Git
sudo apt install -y git

# Instalar Docker
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
newgrp docker

# Instalar Docker Compose
sudo apt install -y docker-compose

# Instalar Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
```

---

## 2. Clonar el repositorio

```bash
cd ~
git clone https://github.com/TU_USUARIO/TU_REPO.git audimundial
cd audimundial
```

---

## 3. Configurar el entorno

```bash
cp .env.example .env
nano .env
```

Completá los valores en `.env`:

```env
HTTP_PORT=8090

# Superusuario administrador (se crea automáticamente al primer inicio)
PB_ADMIN_EMAIL=admin@tudominio.com
PB_ADMIN_PASSWORD=una-contraseña-segura

# Google OAuth (opcional — dejá vacío para deshabilitarlo)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
```

---

## 4. Compilar el frontend

```bash
cd frontend
npm install
npm run build
cd ..
```

---

## 5. Construir y levantar con Docker

```bash
docker-compose up -d --build
```

Verificá que esté corriendo:

```bash
docker ps
docker logs fhun_tips
```

La app estará disponible en: **http://IP-DEL-SERVIDOR:8090**

---

## 6. Configurar envío de emails (SMTP)

1. Entrá al panel de administración: `http://IP-DEL-SERVIDOR:8090/_/`
2. Iniciá sesión con el email y contraseña del paso 3
3. Andá a **Settings → Mail settings**
4. Completá los datos de tu servidor SMTP:
   - **Host:** smtp.tuproveedor.com
   - **Puerto:** 587
   - **Usuario y contraseña** de tu cuenta SMTP
   - **Sender email:** noreply@tudominio.com
5. Guardá y enviá un email de prueba

---

## 7. Configurar la URL pública

En el panel de admin:  
**Settings → Application → Application URL**  
Poné la URL pública del servidor, por ejemplo: `https://audimundial.tudominio.com`

Esto es necesario para que los links de recuperación de contraseña funcionen correctamente.

---

## 8. (Opcional) Nginx como proxy inverso con HTTPS

Si querés exponer la app en el puerto 80/443 con un dominio propio:

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

Creá el archivo de configuración de Nginx:

```bash
sudo nano /etc/nginx/sites-available/audimundial
```

```nginx
server {
    listen 80;
    server_name audimundial.tudominio.com;

    location / {
        proxy_pass http://localhost:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/audimundial /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Obtener certificado SSL gratuito
sudo certbot --nginx -d audimundial.tudominio.com
```

---

## 9. Configurar Google OAuth (opcional)

1. Entrá a https://console.cloud.google.com
2. Creá un proyecto → **APIs y servicios → Credenciales → Crear credenciales → ID de cliente OAuth**
3. Tipo: **Aplicación web**
4. Orígenes autorizados: `https://audimundial.tudominio.com`
5. URI de redirección: `https://audimundial.tudominio.com/api/oauth2-redirect`
6. Copiá el **Client ID** y **Client Secret** al archivo `.env`
7. Reiniciá: `docker-compose restart`

---

## Comandos útiles

```bash
# Ver logs en tiempo real
docker logs -f fhun_tips

# Reiniciar la app
docker-compose restart

# Detener la app
docker-compose down

# Actualizar (después de un git pull)
docker-compose down
docker-compose up -d --build

# Hacer backup de la base de datos
docker cp fhun_tips:/pb_data ./backup_$(date +%Y%m%d)
```

---

## Resetear la base de datos

> ⚠️ Esto borra TODOS los usuarios y datos.

```bash
docker-compose down
docker volume rm audimundial_pb_data
docker-compose up -d
```

