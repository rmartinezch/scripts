#!/bin/bash

# --------------------------------------------------
# Instalador y verificación de TrueRNG en Linux Ubuntu Desktop 24.04.2 LTS
# ~$ chmod u+x script_instalacion_true_rng.sh
# ~$ sudo ./script_instalacion_true_rng.sh
# --------------------------------------------------

RULES_FILE="/etc/udev/rules.d/99-TrueRNG.rules"

echo "=================================================="
echo " Instalando reglas para TrueRNG..."
echo "=================================================="

# 1. Crear el archivo 99-TrueRNG.rules con el contenido indicado
cat << 'EOF' > /tmp/99-TrueRNG.rules
# Rule for TrueRNG V1/V2/V3
SUBSYSTEM=="tty", ATTRS{product}=="TrueRNG", SYMLINK+="TrueRNG%n", RUN+="/bin/stty raw -echo -ixoff -F /dev/%k speed 3000000"
ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="f5fe", ENV{ID_MM_DEVICE_IGNORE}="1", MODE="0666"
EOF

# 2. Copiar el archivo de reglas a /etc/udev/rules.d/
echo "[INFO] Copiando archivo de reglas a $RULES_FILE"
cp /tmp/99-TrueRNG.rules "$RULES_FILE"

# 3. Verificar que se copió correctamente
if [[ -f "$RULES_FILE" ]]; then
    echo "[OK] El archivo se copió correctamente."
else
    echo "[ERROR] No se pudo copiar el archivo."
    exit 1
fi

# 4. Asignar permisos correctos
echo "[INFO] Estableciendo permisos correctos para el archivo..."
chmod 0644 "$RULES_FILE"

# 5. Recargar reglas de udev
echo "[INFO] Recargando reglas de udev..."
udevadm control --reload-rules
udevadm trigger

# 6. Esperar activamente que el dispositivo esté disponible
echo "[INFO] Esperando a que el dispositivo /dev/TrueRNG0 esté disponible..."
MAX_INTENTOS=10
for i in $(seq 1 $MAX_INTENTOS); do
    if [[ -e /dev/TrueRNG0 ]]; then
        echo "[OK] El dispositivo /dev/TrueRNG0 está listo para usarse."
        break
    fi
    echo "[INFO] Intento $i/$MAX_INTENTOS: dispositivo aún no disponible, reintentando..."
    sleep 1
done

# 7. Si después de los intentos no existe, error
if [[ ! -e /dev/TrueRNG0 ]]; then
    echo "[ERROR] No se detectó el dispositivo /dev/TrueRNG0."
    echo "  - Verifique que el TrueRNG está conectado."
    echo "  - Puede revisar mensajes con: dmesg | tail"
    exit 1
fi

# 8. Probar lectura de datos desde el TrueRNG
echo
echo "=================================================="
echo " PRUEBA DE GENERACIÓN DE NÚMEROS ALEATORIOS"
echo "=================================================="
echo "[INFO] Leyendo 16 bytes desde /dev/TrueRNG0..."
echo

# 9. Ejecutar la prueba
cat /dev/TrueRNG0 | hexdump -C | head

echo
echo "[OK] Si ves datos en hexadecimal, el generador está funcionando."
echo "=================================================="
echo " Instalación y prueba completadas con éxito."
echo "=================================================="