<div align="center">

# Automação de Testes de IA com promptfoo

**Engenharia de qualidade para IA aplicada a um chatbot de e-commerce.**

Projeto de portfólio de **Douglas Antonio** · Node.js, promptfoo, Ollama e GitHub Actions

![Status: projeto de estudos](https://img.shields.io/badge/status-projeto_de_estudos-blue)
![Node.js: 22.22 ou superior](https://img.shields.io/badge/Node.js-%3E%3D22.22-339933?logo=nodedotjs&logoColor=white)
![promptfoo](https://img.shields.io/badge/testes-promptfoo-7C3AED)
![Ollama](https://img.shields.io/badge/IA_local-Ollama-111111)
[![AI Tests](https://github.com/DouglasAntoni0/curso-testes-ia-promptfoo/actions/workflows/ai-tests.yml/badge.svg?branch=main)](https://github.com/DouglasAntoni0/curso-testes-ia-promptfoo/actions/workflows/ai-tests.yml)

[Sobre](#sobre-o-projeto) · [Testes](#testes-implementados) · [Como executar](#como-executar) · [Calibração do juiz](#calibração-do-juiz) · [Integração contínua](#integração-contínua) · [Curso](#curso-e-créditos)

</div>

## Sobre o projeto

Este repositório reúne minha prática durante o curso **Automação de Testes de IA: Chatbots e LLMs com promptfoo**, ministrado por **Jeferson Fabiano Caye**, na Udemy. O objetivo é transformar comportamentos esperados de uma aplicação com IA em testes automatizados, versionados e reproduzíveis.

O sistema sob teste é o **ShopDemo Assistente**, um chatbot de atendimento de uma loja fictícia. Ele permite explorar perguntas sobre pedidos, produtos e políticas da loja, além de situações de recusa, preservação de contexto, fidelidade ao RAG, contrato JSON de classificação e proteção de instruções internas.

O projeto acompanha minha evolução no curso, desde a primeira avaliação HTTP até uma suíte que confere regras de negócio, contrato JSON, conversas e respostas baseadas em dados da loja. O pipeline executa **35 avaliações** na `v2`, com resultados rastreáveis por commit.

## Minhas contribuições

- **Transformei regras de atendimento em verificações repetíveis.** A suíte confere limites de desconto, preços de catálogo, prazos de entrega e o contrato do classificador, além de verificar se a conversa mantém a sessão.
- **Calibrei o modelo que avalia as respostas.** Usei respostas de referência com vereditos esperados e adaptei os prompts do juiz de RAG para checar cada afirmação contra a base de conhecimento.
- **Adaptei a execução ao runner do GitHub.** Mantive os casos e os critérios de avaliação. O CI baixa modelos que cabem no runner, executa as avaliações em série e registra os relatórios por commit.
- **Aprofundei a cobertura do ShopDemo.** Ajustei a recuperação de políticas da `v2` com sinônimos de pagamento, devolução e entrega e verifiquei a diferença entre a versão com falhas didáticas e a corrigida.

## Técnicas aplicadas

- Integração do promptfoo com uma aplicação por meio de um provider HTTP (`targets/assistant.yaml` e `classifier.yaml`).
- Escrita de cenários e asserções em YAML, CSV e JavaScript (`asserts/rules.js`).
- Validação determinística de texto, expressões regulares, JSON Schema (`is-json`) e latência (`latency`).
- Avaliação de critérios semânticos e de RAG (`llm-rubric`, `context-relevance` e `context-faithfulness`) com um modelo local atuando como juiz.
- **Calibração do modelo juiz** (`judge-check.yaml`) com casos positivos e negativos conhecidos (`llm-rubric` e `not-llm-rubric`).
- Conversas multi-turno com preservação de sessão (`sessionId`) e testes de segurança / Red Team local.
- Uso de modelos locais personalizados com Ollama (`qwen3.5:9b` como assistente e `qwen3.8` como juiz) e pipeline no GitHub Actions.

## Aplicação e tecnologias

| Componente | Papel no projeto |
| --- | --- |
| **Node.js e JavaScript** | API HTTP do assistente, regras de atendimento, asserções customizadas e resumo de CI |
| **promptfoo** | Execução dos cenários, calibração do juiz, avaliação de RAG e Red Team |
| **YAML e CSV** | Configuração de providers, suítes de testes, massas de dados e rubricas |
| **Ollama** | Inferência na própria máquina em desenvolvimento e no runner do GitHub em CI |
| **HTML, CSS e JavaScript** | Interface web para exploração manual do chatbot |

### Modos e versões

| Configuração | Comportamento |
| --- | --- |
| `MODE=simulated` | Usa respostas programadas e dispensa um modelo para o assistente |
| `MODE=llm` | Gera respostas com o modelo configurado via Ollama (`qwen3.5:9b`) |
| `VERSION=v1` | Disponibiliza falhas intencionais para os exercícios |
| `VERSION=v2` | Aplica as correções didáticas para comparação e regressão |

O modo e a versão são independentes. É possível estudar as duas versões tanto no modo simulado quanto com o modelo de linguagem.

Na `v2`, a busca de políticas também expande termos de pagamento, devolução e entrega. Perguntas como “Posso parcelar em quantas vezes?” ajudam a verificar se o contexto recuperado sustenta a resposta.

### Modelos por ambiente

| Papel | Padrão local | GitHub Actions |
| --- | --- | --- |
| **Assistente e smoke** | `qwen3.5:9b` | `qwen3.5:9b` |
| **Juiz de respostas e RAG** | `qwen3.8` | `qwen3.5:9b` |
| **Segundo modelo na comparação** | `qwen3.8` | `qwen3.5:4b` |

O Ollama usa `think: false` nas avaliações. O runner carrega um modelo por vez e roda sem chaves de API. A calibração é executada com o mesmo juiz usado nos cenários semânticos daquele ambiente.

## Testes implementados

A suíte em `tests/` agrupa os casos por finalidade e usa `metadata.type` para separar os testes determinísticos dos avaliados pelo juiz.

| Arquivo / Pasta | Tipo | O que valida |
| --- | --- | --- |
| `cases/01-basic.yaml` | `deterministic` | Saudação, formas de pagamento (`icontains-all`) e proteção básica de canary (`SD-CANARY-7731`) |
| `cases/02-policies.csv` | `deterministic` / `judge` | Massa de testes em CSV para políticas de frete grátis, parcelamento, teto de desconto, prazo de troca e recusa fora do escopo |
| `cases/03-rules.yaml` | `deterministic` | Teto de desconto via regex e JavaScript (`discountWithinPolicy`), validação de preços contra `products.json` (`priceMatchesCatalog`) e SLA de latência (`< 3000ms`) |
| `cases/04-judge.yaml` | `judge` | Recusa de assuntos fora do escopo e resposta integralmente em português mesmo quando a pergunta inclui termos em inglês |
| `cases/05-rag.yaml` | `judge` | Relevância do contexto recuperado (`context-relevance`) e fidelidade sem alucinação (`context-faithfulness`) usando prompts customizados em `graders/` |
| `cases/06-conversation.yaml` | `deterministic` | Memória de múltiplos turnos na mesma sessão (`sessionId: conversation-4521`, `runSerially: true`) |
| `cases/07-security.yaml` | `deterministic` / `judge` | Resistência a prompt injection (encenação, tradução, extração de regras) e bloqueio de acesso a pedidos de outros clientes (BOLA / pedido `7788`) |
| `classifier.yaml` | `deterministic` | Contrato JSON Schema (`is-json`) e precisão das intenções no endpoint `POST /classify` |
| `judge-check.yaml` | Calibração | Classificação do idioma de quatro respostas fixas com o provider `echo` |
| `smoke.yaml` | Conectividade | Resposta direta do modelo principal pelo Ollama |
| `compare-models.yaml` | Comparação | Duas verificações de política aplicadas a cada um dos dois modelos |
| `redteam/promptfooconfig.yaml` | `redteam` | Varredura automatizada de vulnerabilidades (`prompt-extraction`, `pii:direct`, `excessive-agency`, `hallucination` e políticas) com `qwen3.8` |

```mermaid
flowchart LR
    A[Casos YAML / CSV] --> B[promptfoo]
    B -->|POST /chat ou /classify| C["ShopDemo Assistente (simulado ou LLM)"]
    C -->|Resposta HTTP| B
    B --> D[Asserções determinísticas e JS]
    B --> E[Juiz no Ollama]
    D --> F[Relatórios no GitHub Actions]
    E --> F
```

## Estrutura do repositório

```text
curso-testes-ia-promptfoo/
├── .github/workflows/
│   └── ai-tests.yml            # Testes, calibração, artefatos e GitHub Pages
├── app/
│   ├── data/                   # Pedidos, produtos e políticas da loja (.json e .md)
│   ├── prompts/                # Instruções de sistema das versões v1 e v2
│   ├── public/                 # Interface web do chat
│   ├── .env.example            # Exemplo de configuração do assistente (qwen3.5:9b)
│   ├── assistant.js            # Pipeline RAG -> tools -> modelo/simulado -> sessão
│   ├── config.js               # Leitura das variáveis de ambiente
│   ├── intents.js              # Detecção de intenção e heurísticas
│   ├── llm.js                  # Cliente Ollama (/api/chat com think: false) e OpenAI
│   ├── rag.js                  # Busca nas políticas e catálogo
│   ├── server.js               # Servidor HTTP (/health, /chat, /classify)
│   ├── sessions.js             # Histórico por sessão
│   ├── simulated.js            # Respostas determinísticas (v1 e v2)
│   ├── text.js                 # Utilitários de normalização e extração
│   ├── tools.js                # Consulta de pedidos (getOrderStatus)
│   └── package.json
├── tests/
│   ├── asserts/
│   │   └── rules.js            # Regras de negócio em JS (desconto e catálogo de preços)
│   ├── cases/                  # Suíte modular de testes (01-basic a 07-security)
│   ├── ci/
│   │   └── summary.js          # Gerador de resumo em Markdown para o GitHub Actions
│   ├── graders/                # Prompts calibrados para context-relevance e faithfulness
│   ├── redteam/
│   │   └── promptfooconfig.yaml # Configuração de Red Team local com qwen3.8
│   ├── targets/
│   │   └── assistant.yaml      # Provider HTTP reutilizável do assistente
│   ├── .env.example            # Exemplo de variáveis de ambiente dos testes
│   ├── classifier.yaml         # Testes de contrato JSON do endpoint /classify
│   ├── compare-models.yaml     # Comparação entre qwen3.5:9b e qwen3.8
│   ├── judge-check.yaml        # Calibração do juiz de idioma (qwen3.8)
│   ├── package.json            # Scripts npm para todas as execuções
│   ├── promptfooconfig.yaml    # Configuração principal da suíte
│   └── smoke.yaml              # Teste rápido de conectividade com o modelo
├── .gitignore
├── setup.ps1                   # Script de preparação automatizada no Windows
└── README.md
```

## Como executar

### 1. Pré-requisitos

- **Node.js 22.22.0 ou superior**, com npm.
- **Git** para controle de versão.
- **Ollama** para o modo `llm`, a calibração, os testes com juiz e o red team. Os testes determinísticos e de contrato rodam sem Ollama no modo simulado.

### 2. Clonar e preparar o ambiente

```powershell
git clone https://github.com/DouglasAntoni0/curso-testes-ia-promptfoo.git
cd curso-testes-ia-promptfoo
npm ci --prefix app
npm ci --prefix tests
if (-not (Test-Path app/.env)) { Copy-Item app/.env.example app/.env }
if (-not (Test-Path tests/.env)) { Copy-Item tests/.env.example tests/.env }
```

### 3. Preparar os modelos para avaliações com IA

Com o Ollama em execução em `http://localhost:11434`, baixe os modelos configurados. Para rodar apenas os testes determinísticos e o classificador no modo simulado, avance para a próxima etapa.

```powershell
ollama pull qwen3.5:9b
ollama pull qwen3.8
ollama list
```

### 4. Iniciar o assistente

Para reproduzir o ambiente dos testes determinísticos do CI, rode a `v2` no modo simulado. A partir da raiz do projeto, em PowerShell:

```powershell
$env:MODE = 'simulated'
$env:VERSION = 'v2'
npm start --prefix app
```

- **Chat no navegador:** [http://localhost:3000](http://localhost:3000)
- **Estado da aplicação:** [http://localhost:3000/health](http://localhost:3000/health)

Para avaliar respostas geradas pelo modelo, reinicie com `$env:MODE = 'llm'`. Defina `$env:VERSION = 'v1'` para explorar as falhas didáticas. Os valores definidos no terminal têm prioridade sobre `app/.env`.

### 5. Executar os testes e a calibração

Com o assistente em execução, abra outro terminal na raiz do projeto e rode a bateria desejada.

```powershell
cd tests

npm run test:deterministic -- --no-cache
npm run test:classifier -- --no-cache
```

| Comando | O que executa |
| --- | --- |
| `npm run test:judge-check` | Quatro casos de calibração com respostas fixas e o juiz no Ollama |
| `npm run test:judge` | Casos semânticos, de RAG e de segurança que usam o juiz |
| `npm test` | Suíte principal de atendimento em `tests/cases/` |
| `npm run test:smoke` | Verificação direta do modelo do assistente no Ollama |
| `npm run test:compare` | Comparação dos dois modelos com os mesmos prompts |
| `npm run redteam` | Geração e avaliação local de ataques contra o assistente |
| `npm run report` | Visualizador das avaliações locais do promptfoo |

Os comandos locais acima executam as avaliações com um caso por vez (`-j 1`). Acrescente `-- --no-cache` a `npm test` ou `npm run test:judge` para obter respostas novas. A calibração, o smoke e a comparação usam `--no-cache` por padrão.

## Calibração do juiz

O arquivo `tests/judge-check.yaml` usa o modelo definido em `JUDGE_MODEL` com `temperature: 0` e `think: false`. Os quatro casos rodam diretamente com o Ollama, sem precisar iniciar o assistente.

- Usa o provider `echo` (as respostas já são conhecidas e fixas, isolando apenas o comportamento do juiz).
- **2 casos que o juiz deve aprovar (`llm-rubric`):** resposta em português puro e resposta em português citando a palavra `"status"`.
- **2 casos que o juiz deve reprovar (`not-llm-rubric`):** resposta 100% em inglês e resposta mista (inglês + português).

Para rodar apenas a calibração:

```powershell
cd tests
npm run test:judge-check
```

## Configuração principal

| Arquivo | Variável ou campo | Valor configurado | Finalidade |
| --- | --- | --- | --- |
| `app/.env` | `PORT` | `3000` | Porta HTTP do assistente |
| `app/.env` | `MODE` | `simulated` | Use `llm` para gerar respostas com o modelo |
| `app/.env` | `VERSION` | `v1` | Use `v2` para testar a versão corrigida |
| `app/.env` | `OLLAMA_BASE_URL` | `http://localhost:11434` | URL base da API nativa do Ollama |
| `app/.env` | `LLM_BASE_URL` | `http://localhost:11434/v1` | Base do provedor. No Ollama, o cliente usa `/api/chat` |
| `app/.env` | `LLM_MODEL` | `qwen3.5:9b` | Modelo principal do assistente |
| `tests/.env` | `OLLAMA_BASE_URL` | `http://localhost:11434` | Endereço do Ollama para o promptfoo |
| `tests/.env` | `JUDGE_MODEL` | `qwen3.8` | Juiz da suíte principal e da calibração |
| `tests/.env` | `APP_MODEL` | `qwen3.5:9b` | Modelo avaliado diretamente no smoke e na comparação |
| `tests/.env` | `COMPARE_MODEL` | `qwen3.8` | Segundo modelo na comparação |

Se mudar a porta do assistente, atualize os endereços em `tests/targets/assistant.yaml` e `tests/classifier.yaml`. Use os arquivos `.env.example` para preparar a configuração local. O `.gitignore` exclui os arquivos `.env` e os dados locais do promptfoo.

## API disponível

| Método | Rota | Uso |
| --- | --- | --- |
| `GET` | `/` | Interface web do assistente |
| `GET` | `/health` | Estado, modo, versão e modelo em uso |
| `POST` | `/chat` | Atendimento; recebe `message` e, opcionalmente, `sessionId` |
| `POST` | `/classify` | Classificação de intenção. Na `v2`, retorna o texto JSON com `intent`, `orderId` e `confidence` esperado pela suíte de contrato |

## Integração contínua

O workflow **AI Tests** executa em pushes, pull requests e por acionamento manual. Qualquer falha nas avaliações conta como falha no pipeline. [Acompanhar o GitHub Actions](https://github.com/DouglasAntoni0/curso-testes-ia-promptfoo/actions/workflows/ai-tests.yml)

| Etapa | Avaliações | Cobertura |
| --- | ---: | --- |
| **Regressão funcional** | 17 | Atendimento, regras de negócio, latência, sessão e segurança na `v2` simulada |
| **Contrato da API** | 3 | Formato JSON e classificação em `/classify` |
| **Smoke do Ollama** | 1 | Conectividade e resposta do modelo principal |
| **Calibração do juiz** | 4 | Critérios de idioma com respostas e vereditos de referência |
| **Avaliação com IA** | 6 | Escopo, idioma, segurança e fidelidade ao contexto com a `v2` em modo `llm` |
| **Comparação de modelos** | 4 | Dois cenários avaliados em dois modelos |

Cada execução gera um resumo e guarda relatórios HTML, JSON e JUnit nos artefatos `suite-deterministic` e `suite-ai`. O deploy público do índice é opcional. Ele roda após aprovação da suíte na `main` quando o repositório usa **GitHub Actions** como origem no Pages e tem a variável `PUBLISH_REPORTS=true`. [Configuração do GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)

## Curso e créditos

O aplicativo **ShopDemo Assistente** e a base dos exercícios são de **Jeferson Fabiano Caye**. A formação tem 30 aulas em nove seções que vão da configuração do ambiente e da primeira avaliação até asserções, RAG, segurança e integração contínua. Este repositório é minha implementação e evolução desses exercícios.

- **Curso:** [Automação de Testes de IA: Chatbots e LLMs com promptfoo — Udemy](https://www.udemy.com/course/automacao-de-testes-de-ia-chatbots-e-llms-com-promptfoo/)
- **Material original:** [jefersoncaye/curso-testes-ia-promptfoo](https://github.com/jefersoncaye/curso-testes-ia-promptfoo)
- **Estudos e evolução deste repositório:** [Douglas Antonio](https://github.com/DouglasAntoni0)
