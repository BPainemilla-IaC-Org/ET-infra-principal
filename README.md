<div align="center">
  <img src="https://img.shields.io/badge/Amazon_AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/Terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform"/>
  <img src="https://img.shields.io/badge/GitHub_Actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions"/>
  <img src="https://img.shields.io/badge/Ubuntu-%23E95420.svg?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu"/>
  <img src="https://img.shields.io/badge/Security_TFSec-%23E32119.svg?style=for-the-badge&logo=security&logoColor=white" alt="TFSec"/>
</div>

<br>

# ☁️ Arquitectura DevSecOps de Orquestación e Infraestructura Unificada

Este repositorio centraliza y coordina el aprovisionamiento de la topología completa en la nube sobre Amazon Web Services (AWS) mediante la integración de un pipeline robusto de **Integración Continua (CI/CD)** y **Políticas de Seguridad Automatizadas (Policy as Code)**.

## 🏛️ Topología de Arquitectura DevSecOps

El siguiente diagrama ilustra la interconexión de nuestro ecosistema. Abarca desde la orquestación del código y escaneos de seguridad automatizados en GitHub, hasta el aprovisionamiento de la infraestructura física en AWS.

```mermaid
graph TD
    classDef github fill:#24292e,stroke:#ffffff,stroke-width:2px,color:#ffffff,font-weight:bold;
    classDef actions fill:#2088FF,stroke:#ffffff,stroke-width:2px,color:#ffffff,font-weight:bold;
    classDef aws fill:#232F3E,stroke:#FF9900,stroke-width:2px,color:#ffffff,font-weight:bold;
    classDef vpc fill:#00A4A6,stroke:#ffffff,stroke-width:2px,color:#ffffff;
    classDef ec2 fill:#FF9900,stroke:#232F3E,stroke-width:3px,color:#232F3E,font-weight:bold;
    classDef s3 fill:#3F8624,stroke:#ffffff,stroke-width:2px,color:#ffffff;
    classDef security fill:#cb2431,stroke:#ffffff,stroke-width:2px,color:#ffffff,font-weight:bold;

    Dev(("👨‍💻 Ingeniero Cloud")) -->|Inicia Pull Request| Repo["🐙 Org GitHub (Consumo v1.0.0)"]:::github
    Repo -->|Dispara Webhook| CI["⚙️ GitHub Actions Server"]:::actions

    subgraph Pipeline ["🛡️ Pipeline de Integración Continua (CI/CD)"]
        direction TB
        TFSec["🔍 TFSec Scanner"]:::security
        TFPlan["🏗️ Terraform Core (Plan)"]:::actions
        TFSec -->|Código Seguro| TFPlan
    end
    CI --> Pipeline

    TFPlan -->|Verifica y Bloquea| State["🪣 Bucket S3 (Backend)"]:::s3
    TFPlan -->|Aprovisiona| AWS(("☁️ API de AWS (us-east-1)")):::aws

    subgraph AWS_Cloud ["🌐 Infraestructura Física en AWS"]
        direction TB
        IGW["🌍 Internet Gateway (IGW)"]:::aws
        
        subgraph VPC ["🔒 Virtual Private Cloud (VPC: 10.0.0.0/16)"]
            direction LR
            SubA["🌐 Subred Pública A"]:::vpc
            SubB["🌐 Subred Pública B"]:::vpc
            
            SG["🛡️ Grupo de Seguridad (22, 80, 443)"]:::security
            EC2["💻 Instancia EC2 (Ubuntu + Apache)"]:::ec2
            
            SubA --> SG
            SG --> EC2
        end
        
        AppBucket["🗄️ Bucket S3 Productivo (AES256)"]:::s3
        
        IGW --> SubA & SubB
    end

    AWS --> IGW
    AWS -.-> AppBucket
```

### 📋 Leyenda de Componentes
| Logo / Símbolo | Componente Técnico | Función en la Arquitectura |
| :---: | :--- | :--- |
| 🐙 | **GitHub Org** | Orquestador de código y host de módulos (VPC, EC2, S3) bajo *SemVer*. |
| ⚙️ | **GitHub Actions** | Servidor virtual temporal (`ubuntu-latest`) que ejecuta el pipeline. |
| 🔍 | **TFSec** | Barrera de seguridad *Policy as Code*. Bloquea código vulnerable. |
| 🪣 | **Backend S3** | Almacenamiento seguro del estado de Terraform para prevenir *Drift*. |
| ☁️ | **AWS Cloud** | Proveedor de infraestructura física para recursos de red y cómputo. |
| 💻 | **EC2** | Servidor de aplicaciones web aprovisionado automáticamente. |

---

## 🏗️ Gestión de Módulos mediante Versionado Semántico (SemVer)

Para mitigar riesgos de ruptura estructural en producción y garantizar compatibilidad hacia atrás, este repositorio principal no consume el código de manera dinámica desde las ramas principales de desarrollo. En su lugar, consume los módulos alojados en la organización externa utilizando *Git Tags* rígidos y precisos:

```hcl
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
```

---

## 🛡️ Características del Pipeline CI/CD (GitHub Actions)

El archivo de configuración `.github/workflows/terraform-ci.yml` actúa como nuestro sistema de permisos e integridad operativa:

1. **Protección de Ramas Primarias:** Se prohíben explícitamente los *pushes* y modificaciones directas hacia la rama `main`. Todo cambio estructural se ve obligado a canalizarse a través de una rama paralela (*feature branch*).
2. **Calidad de Código y Estructuras (`terraform fmt`):** El pipeline ejecuta un chequeo estricto del formato formal. Si los archivos presentan inconsistencias de indentación o legibilidad, el pipeline aborta, garantizando código homogéneo.
3. **Análisis Estático de Seguridad (`TFSec`):** Escanea los manifiestos de Terraform buscando malas configuraciones arquitectónicas (como Security Groups con puertos abiertos globalmente hacia Internet) antes de interactuar con AWS, protegiendo los activos en la nube de accesos maliciosos.
4. **Backend Remoto Seguro:** La persistencia del archivo de estado (`terraform.tfstate`) se gestiona remotamente dentro de un bucket S3 protegido, garantizando concurrencia, encriptación y soporte ante catástrofes
