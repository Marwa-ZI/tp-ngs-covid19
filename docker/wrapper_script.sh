#!/bin/bash
# ============================================================================
# Wrapper script - Avec mot de passe NGS partout
#Auteur:Marwa ZIDI
# ============================================================================

USER=$1
PASSWORD=$2

echo "=========================================="
echo "DEBUT DU SCRIPT - $(date)"
echo "=========================================="

set -e

# ============================================================================
# DÉMARRAGE VNC (appel du script créé dans le Dockerfile)
# ============================================================================
echo "🖥️  Démarrage VNC/IGV..."
/usr/local/bin/start-vnc.sh
sleep 3

# ============================================================================
# DÉMARRAGE JUPYTER LAB SANS MOT DE PASSE
# ============================================================================
echo "📓 Lancement de jupyter lab SANS mot de passe..."

cd /root
pwd
whoami

# Lancer Jupyter SANS mot de passe
exec jupyter lab \
    --allow-root \
    --no-browser \
    --ip="0.0.0.0" \
    --port=8888 \
    --IdentityProvider.token='' \
    --ServerApp.password='' \
    --ServerApp.shutdown_no_activity_timeout=1200 \
    --MappingKernelManager.cull_idle_timeout=1200 \
    --TerminalManager.cull_inactive_timeout=1200


