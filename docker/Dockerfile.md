# ============================================================================
# Dockerfile pour environnement NGS avec Jupyter et VNC
#Auteur:Marwa ZIDI
# ============================================================================

FROM ubuntu:22.04

# Variables d'environnement
ENV DEBIAN_FRONTEND=noninteractive

# ============================================================================
# 1. INSTALLATION DES OUTILS DE BASE
# ============================================================================
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    openssl \
    curl \
    ca-certificates \
    wget \
    git \
    build-essential \
    unzip \
    procps \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 2. INSTALLATION DE NODE.JS
# ============================================================================
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# ============================================================================
# 3. INSTALLATION DE PYTHON ET JUPYTER
# ============================================================================
RUN pip3 install --upgrade pip setuptools wheel
RUN npm install -g configurable-http-proxy
RUN pip3 install jupyterlab notebook

# ============================================================================
# 3.1 INSTALLATION DES PACKAGES PYTHON POUR BIOINFORMATIQUE
# ============================================================================
RUN pip3 install \
    biopython \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scipy \
    pysam \
    scikit-learn \
    plotly

# ============================================================================
# 4. INSTALLATION DES OUTILS NGS
# ============================================================================
RUN apt-get update && apt-get install -y \
    samtools \
    bcftools \
    bedtools \
    bowtie2 \
    bwa \
    fastqc \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 5. INSTALLATION DE JAVA POUR IGV
# ============================================================================
RUN apt-get update && apt-get install -y \
    openjdk-17-jre \
    fonts-dejavu \
    fonts-liberation \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 6. INSTALLATION DE VNC ET COMPOSANTS GRAPHIQUES
# ============================================================================
RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    fluxbox \
    xterm \
    novnc \
    websockify \
    net-tools \
    tigervnc-standalone-server \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# 7. CONFIGURATION DU MOT DE PASSE VNC (CORRIGÉ)
# ============================================================================
RUN mkdir -p /root/.vnc && \
    echo "NGS" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# ============================================================================
# 8. TÉLÉCHARGEMENT ET INSTALLATION D'IGV
# ============================================================================
RUN wget https://data.broadinstitute.org/igv/projects/downloads/2.16/IGV_Linux_2.16.2_WithJava.zip -O /tmp/igv.zip && \
    unzip /tmp/igv.zip -d /opt/ && \
    rm /tmp/igv.zip && \
    ln -s /opt/IGV_Linux_2.16.2/igv.sh /usr/local/bin/igv

# ============================================================================
# 8b. TÉLÉCHARGEMENT DES DONNÉES COVID-19
# ============================================================================
RUN mkdir -p /opt/covid_data

# Génome SARS-CoV-2
RUN cd /opt/covid_data && wget -q https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz && \
    gunzip GCF_009858895.2_ASM985889v3_genomic.fna.gz && \
    mv GCF_009858895.2_ASM985889v3_genomic.fna NC_045512.2.fasta

# Annotations GenBank
RUN cd /opt/covid_data && wget -q https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.gbff.gz && \
    gunzip GCF_009858895.2_ASM985889v3_genomic.gbff.gz && \
    mv GCF_009858895.2_ASM985889v3_genomic.gbff NC_045512.2.gb

# Annotations GFF
RUN cd /opt/covid_data && wget -q https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.gff.gz && \
    gunzip GCF_009858895.2_ASM985889v3_genomic.gff.gz && \
    mv GCF_009858895.2_ASM985889v3_genomic.gff NC_045512.2.gff3

# Téléchargement FASTQ depuis ENA
RUN cd /opt/covid_data && wget -q ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR111/044/SRR11140744/SRR11140744_1.fastq.gz && \
    gunzip SRR11140744_1.fastq.gz && \
    head -n 200000 SRR11140744_1.fastq > sample_reads.fastq && \
    rm -f SRR11140744_1.fastq

# Indexation du génome
RUN cd /opt/covid_data && bwa index NC_045512.2.fasta && \
    samtools faidx NC_045512.2.fasta

# Lien symbolique dans /root pour faciliter l'accès
RUN ln -s /opt/covid_data /root/covid_data

# ============================================================================
# 9. CRÉATION DU SCRIPT DE DÉMARRAGE VNC
# ============================================================================
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
Xvfb :1 -screen 0 1280x1024x24 &\n\
sleep 2\n\
fluxbox &\n\
x11vnc -display :1 -rfbport 5900 -rfbauth /root/.vnc/passwd -forever -shared -bg\n\
websockify --web=/usr/share/novnc 6080 localhost:5900 &\n\
echo "VNC démarré sur le port 6080"\n\
' > /usr/local/bin/start-vnc.sh && \
    chmod +x /usr/local/bin/start-vnc.sh

# ============================================================================
# 9b. CONFIGURATION DU MENU FLUXBOX
# ============================================================================
RUN mkdir -p /root/.fluxbox && \
    echo '[begin] (Fluxbox Menu)\n\
    [exec] (Terminal) {xterm -bg black -fg white -fa "Monospace" -fs 12}\n\
    [exec] (IGV) {igv}\n\
    [separator]\n\
    [submenu] (Applications)\n\
        [exec] (Terminal) {xterm}\n\
        [exec] (IGV) {igv}\n\
    [end]\n\
    [separator]\n\
    [config] (Configuration)\n\
    [submenu] (Styles)\n\
        [stylesdir] (/usr/share/fluxbox/styles)\n\
    [end]\n\
    [separator]\n\
    [restart] (Restart)\n\
    [exit] (Exit)\n\
[end]' > /root/.fluxbox/menu

# ============================================================================
# 10. COPIE DU SCRIPT WRAPPER
# ============================================================================
COPY wrapper_script.sh /usr/local/lib/wrapper_script.sh
RUN ls /usr/local/lib/wrapper_script.sh
RUN chmod +x /usr/local/lib/wrapper_script.sh

# ============================================================================
# 11. CRÉATION DU RÉPERTOIRE DE TRAVAIL
# ============================================================================
WORKDIR /root

# ============================================================================
# 12. EXPOSITION DES PORTS
# ============================================================================
EXPOSE 6080 8888

# ============================================================================
# 13. POINT D'ENTRÉE
# ============================================================================
ENTRYPOINT ["/bin/bash", "/usr/local/lib/wrapper_script.sh"]
