## 1. Repositorio de Conexión Principal: `ET-infra-principal`
Ubicación del archivo: Raíz de tu repositorio de orquestación donde se ejecutan las acciones de GitHub.

```markdown
# ☁️ Arquitectura DevSecOps de Orquestación e Infraestructura Unificada

Este repositorio centraliza y coordina el aprovisionamiento de la topología completa en la nube sobre
Amazon Web Services(AWS) mediante la integración de un pipeline robusto de **Integración Continua (CI/CD)**
y **Políticas de Seguridad Automatizadas (Policy as Code)**.

## 🗺️ Diagrama Lógico del Ciclo de Vida DevSecOps

El ciclo de desarrollo e integración de infraestructura sigue estrictamente el siguiente flujo automatizado:

 [Desarrollador Bryan] 
         │ (Crea rama característica local)
         ▼
 [Git Push a GitHub Org]
         │
         ▼
 [Apertura de Pull Request (PR)] ──► Interceptado por GitHub Actions
                                               │
               ┌───────────────────────────────┴──────────────────────────────┐
               ▼                                                              ▼
    [Job 1: TFSec Security]                                        [Job 2: Terraform Plan]
   Análisis Estático de Código                                    Validación de Estado e IaC
    CIS Benchmark de AWS                                          (fmt, init, validate, plan)
               │                                                              │
               └───────────────────────────────┬──────────────────────────────┘
                                               ▼
                                   ¿Pipeline Exitoso (Verde)?
                                        ├──► ❌ NO: Bloquea PR (Deniega Permisos)
                                        └──►  SI: Habilita el botón de Merge/Apply


🏗️ Gestión de Módulos mediante Versionado Semántico (SemVer)
Para mitigar riesgos de ruptura estructural en producción y garantizar compatibilidad hacia atrás, este repositorio
principal no consume el código de manera dinámica desde las ramas principales de desarrollo. En su lugar, consume los
módulos alojados en la organización externa utilizando Git Tags rígidos y precisos:

module "networking" {
  source   = "git::[https://github.com/BPainemilla-IaC-Org/terraform-aws-vpc-module.git?ref=v1.0.0](https://github.com/BPainemilla-IaC-Org/terraform-aws-vpc-module.git?ref=v1.0.0)"
  vpc_name = var.vpc_name
  # ... variables de entorno
}

module "compute" {
  source   = "git::[https://github.com/BPainemilla-IaC-Org/terraform-aws-ec2-module.git?ref=v1.0.0](https://github.com/BPainemilla-IaC-Org/terraform-aws-ec2-module.git?ref=v1.0.0)"
  subnet_id = module.networking.subnet_public_a_id
}

module "storage" {
  source   = "git::[https://github.com/BPainemilla-IaC-Org/terraform-aws-s3-module.git?ref=v1.0.0](https://github.com/BPainemilla-IaC-Org/terraform-aws-s3-module.git?ref=v1.0.0)"
}

🛡️ Características del Pipeline CI/CD (GitHub Actions)
El archivo de configuración .github/workflows/terraform-ci.yml actúa como nuestro sistema de permisos e integridad operativa:

Protección de Ramas Primarias: Se prohíben explícitamente los pushes y modificaciones directas hacia la rama main. Todo cambio estructural se ve obligado a canalizarse a través de una rama paralela (feature branch).

Calidad de Código y Estructuras (terraform fmt): El pipeline ejecuta un chequeo estricto del formato formal. Si los archivos presentan inconsistencias de indentación o legibilidad, el pipeline aborta, garantizando código homogéneo.

Análisis Estático de Seguridad (TFSec): Escanea los manifiestos de Terraform buscando malas configuraciones arquitectónicas (como Security Groups con puertos abiertos globalmente hacia Internet) antes de interactuar con AWS, protegiendo los activos en la nube de accesos maliciosos.

Backend Remoto Seguro: La persistencia del archivo de estado (terraform.tfstate) se gestiona remotamente dentro de un bucket S3 protegido, garantizando concurrencia, encriptación y soporte ante catástrofes de pérdida local de datos.

Diseño e Implementación por Bryan Painemilla - Duoc UC (Asignatura AUY1105)
