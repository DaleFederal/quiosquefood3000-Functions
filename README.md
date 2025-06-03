# QuiosqueFood3000 Functions 🚀

Este projeto implementa um backend serverless com **Cloud Functions**, **BigQuery**, **Pub/Sub**, e **API Gateway**, utilizando **Terraform** para infraestrutura como código e **Firebase Identity Platform** para autenticação.

---

## 🏗️ Arquitetura

- **Google Cloud Functions:** CRUD de clientes
- **BigQuery:** Armazenamento dos dados dos clientes
- **Pub/Sub:** Processamento assíncrono de eventos
- **API Gateway:** Exposição pública e segura das funções HTTP
- **Firebase Identity Platform:** Autenticação JWT via Firebase


---

## ☁️ Pré-requisitos

- Conta Google Cloud com billing ativo
- Projeto GCP criado (`quiosquefood3000`)
- Ativar as seguintes APIs:
  - Cloud Functions
  - Cloud Build
  - Artifact Registry
  - BigQuery
  - Pub/Sub
  - API Gateway
  - IAM & Service Management
  - Identity Platform (Firebase Auth)
- Instalar localmente:
  - [Terraform](https://developer.hashicorp.com/terraform)
  - [gcloud CLI](https://cloud.google.com/sdk/docs/install)
  - [Node.js (v20+)](https://nodejs.org)

---

## 🔑 Autenticação Firebase

1. Acesse **Identity Platform** no Console GCP.
2. Configure um método de autenticação (ex.: E-mail e senha).
3. Crie usuários para autenticação.
4. O Firebase irá gerar JWTs que serão usados para acessar as Cloud Functions protegidas.

