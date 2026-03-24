# TP Bioinformatique — Analyse NGS COVID-19

> Travaux pratiques d'analyse de séquences SARS-CoV-2 par approche NGS (Next Generation Sequencing), dans un environnement Docker Jupyter pré-configuré.

**Auteur : Marwa Zidi** — Université Paris Cité

---

## Description

Ce TP guide les étudiants à travers un pipeline complet d'analyse de données de séquençage haut-débit appliqué au génome du **SARS-CoV-2 (NC_045512.2)**. Chaque notebook est autonome et couvre une étape clé du pipeline bioinformatique.

---

## Accès à l'environnement

L'environnement de TP est disponible en ligne via l'infrastructure Docker de l'Université Paris Cité :

**[Lancer l'environnement Jupyter](https://mydocker.universite-paris-saclay.fr/course/df98369f-0b3f-4efe-af02-8bc4955a03d0/magic-link)**

> Aucune installation locale nécessaire. L'environnement inclut tous les outils NGS pré-installés (BWA, Samtools, FastQC, IGV...) ainsi que les données COVID-19.

---

## Structure des notebooks

| # | Notebook | Thème | Durée |
|---|----------|-------|-------|
| 1 | `01_Introduction_Formats_Sequences.ipynb` | Séquençage Illumina, formats FASTA/FASTQ, scores Phred | ~20 min |
| 2 | `02_Genome_Reference_Annotation.ipynb` | Génome de référence SARS-CoV-2, formats GenBank/GFF3 | ~25 min |
| 3 | `03_Controle_Qualite_Reads.ipynb` | Contrôle qualité avec FastQC, GC%, Q30 | ~20 min |
| 4 | `04_Alignement_Genome.ipynb` | Alignement des reads sur le génome de référence (BWA) | — |
| 5 | `05_Visualisation_Couverture.ipynb` | Visualisation de la couverture, exploration avec IGV | — |

### Progression recommandée

```
01 → 02 → 03 → 04 → 05
Introduction  Annotation  QC  Alignement  Couverture
```

---

## Données utilisées

| Fichier | Description | Source |
|--------|-------------|--------|
| `NC_045512.2.fasta` | Génome de référence SARS-CoV-2 (~30 kb) | NCBI RefSeq |
| `NC_045512.2.gb` | Annotations GenBank complètes | NCBI RefSeq |
| `NC_045512.2.gff3` | Annotations au format GFF3 | NCBI RefSeq |
| `sample_reads.fastq` | Reads Illumina (50k reads, SRR11140744) | ENA / SRA |

Les données sont pré-téléchargées dans `/opt/covid_data/` au sein de l'environnement Docker.

---

## Outils et environnement

### Outils bioinformatiques
- **BWA** — Alignement de séquences courtes
- **Samtools** — Manipulation de fichiers BAM/SAM
- **FastQC** — Contrôle qualité des données de séquençage
- **BCFtools** — Appel de variants
- **BEDTools** — Opérations sur les intervalles génomiques
- **IGV** — Visualisation interactive des alignements (via VNC)

### Librairies Python
- `Biopython` — Manipulation de séquences biologiques
- `pysam` — Interface Python pour SAMtools
- `pandas`, `numpy`, `matplotlib`, `seaborn`

### Accès IGV (interface graphique)
L'environnement inclut un bureau VNC accessible depuis le navigateur sur le **port 6080** :
```
Mot de passe VNC : NGS
```

---

## Architecture Docker

```
Dockerfile
├── Ubuntu 22.04
├── Python 3 + JupyterLab
├── Outils NGS (BWA, Samtools, FastQC...)
├── Java 17 + IGV 2.16.2
├── VNC + noVNC (accès graphique)
└── Données COVID-19 pré-téléchargées
```

Pour construire l'image localement :
```bash
docker build -t ngs-covid19 .
docker run -p 8888:8888 -p 6080:6080 ngs-covid19
```

Puis ouvrir `http://localhost:8888` pour JupyterLab et `http://localhost:6080` pour IGV via VNC.

---

## Objectifs pédagogiques

A l'issue de ce TP, l'étudiant sera capable de :

- Comprendre les principes du séquençage Illumina
- Lire et manipuler les formats FASTA, FASTQ, GenBank, GFF3, BAM
- Evaluer la qualité de données NGS avec FastQC
- Aligner des reads courts sur un génome de référence (BWA)
- Visualiser la couverture de séquençage
- Explorer des alignements avec IGV

---

## Références

- Génome de référence : [NC_045512.2 — NCBI](https://www.ncbi.nlm.nih.gov/nuccore/NC_045512.2)
- Données de séquençage : [SRR11140744 — ENA](https://www.ebi.ac.uk/ena/browser/view/SRR11140744)
- [Documentation BWA](http://bio-bwa.sourceforge.net/)
- [Documentation FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [Documentation IGV](https://software.broadinstitute.org/software/igv/)

---

## Licence

Ce matériel pédagogique est distribué à des fins éducatives dans le cadre des enseignements de bioinformatique de l'Université Paris Cité.
