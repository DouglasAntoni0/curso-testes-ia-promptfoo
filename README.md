<div align="center">

# Automação de Testes de IA com promptfoo

**Estudos práticos de qualidade para chatbots e aplicações com modelos de linguagem.**

![Status: projeto de estudos](https://img.shields.io/badge/status-projeto_de_estudos-blue)
![Node.js: 22.22 ou superior](https://img.shields.io/badge/Node.js-%3E%3D22.22-339933?logo=nodedotjs&logoColor=white)
![promptfoo](https://img.shields.io/badge/testes-promptfoo-7C3AED)
![Ollama](https://img.shields.io/badge/IA_local-Ollama-111111)

[Sobre](#sobre-o-projeto) · [Testes](#testes-implementados) · [Como executar](#como-executar) · [Calibração do juiz](#calibração-do-juiz) · [Integração contínua](#integração-contínua) · [Curso](#curso-e-créditos)

</div>

## Sobre o projeto

Este repositório reúne minha prática durante o curso **Automação de Testes de IA: Chatbots e LLMs com promptfoo**, ministrado por **Jeferson Fabiano Caye**, na Udemy. O objetivo é transformar comportamentos esperados de uma aplicação com IA em testes automatizados, versionados e reproduzíveis.

O sistema sob teste é o **ShopDemo Assistente**, um chatbot de atendimento de uma loja fictícia. Ele permite explorar perguntas sobre pedidos, produtos e políticas da loja, além de situações de recusa, preservação de contexto, fidelidade ao RAG, contrato JSON de classificação e proteção de instruções internas.

O projeto acompanha minha evolução no curso. A suíte atual combina regressão funcional, avaliação com IA, testes de segurança e execução no GitHub Actions.

## O que estou praticando

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
| **Ollama** | Execução local dos modelos do assistente (`qwen3.5:9b`) e do juiz (`qwen3.8`) |
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

### Modelos personalizados configurados

| Papel | Modelo configurado | Uso no projeto |
| --- | --- | --- |
| **Modelo principal (Assistente / Classificador)** | `qwen3.5:9b` | Atendimento em `POST /chat`, classificação em `POST /classify`, `smoke.yaml` e `compare-models.yaml` |
| **Modelo avaliador (Juiz / Red Team)** | `qwen3.8` | Avaliação `llm-rubric`, RAG (`context-relevance` / `context-faithfulness`), calibração (`judge-check.yaml`), `compare-models.yaml` e `redteam` |

*(Ambos os modelos estão configurados com `think: false` para respostas diretas e sem blocos de raciocínio intermediário).*

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
| `judge-check.yaml` | Calibração | Calibração do juiz (`qwen3.8`) com respostas fixas (`echo`) em português, português com termo citado, inglês e misto (`llm-rubric` e `not-llm-rubric`) |
| `smoke.yaml` | `deterministic` | Teste de fumaça direto com o provider `ollama:chat:qwen3.5:9b` |
| `compare-models.yaml` | `deterministic` | Comparação lado a lado entre `qwen3.5:9b` e `qwen3.8` |
| `redteam/promptfooconfig.yaml` | `redteam` | Varredura automatizada de vulnerabilidades (`prompt-extraction`, `pii:direct`, `excessive-agency`, `hallucination` e políticas) com `qwen3.8` |

```mermaid
flowchart LR
    A[Casos YAML / CSV] --> B[promptfoo]
    B -->|POST /chat ou /classify| C["ShopDemo Assistente (simulado ou LLM)"]
    C -->|Resposta HTTP| B
    B --> D[Asserções determinísticas e JS]
    B --> E["Juiz no Ollama (qwen3.8)"]
    D --> F[Relatório e CI Summary]
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

O arquivo `tests/judge-check.yaml` usa `qwen3.8` com `temperature: 0` e `think: false` para verificar como o juiz aplica a rubrica de idioma. Os quatro casos rodam diretamente com o Ollama, sem precisar iniciar o assistente.

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
| `tests/promptfooconfig.yaml` | `defaultTest.options.provider.id` | `ollama:chat:qwen3.8` | Modelo juiz da suíte principal |
| `tests/judge-check.yaml` | `defaultTest.options.provider.id` | `ollama:chat:qwen3.8` | Modelo juiz na calibração |

Se mudar a porta do assistente, atualize os endereços em `tests/targets/assistant.yaml` e `tests/classifier.yaml`. Use os arquivos `.env.example` para preparar a configuração local. O `.gitignore` exclui os arquivos `.env` e os dados locais do promptfoo.

## API disponível

| Método | Rota | Uso |
| --- | --- | --- |
| `GET` | `/` | Interface web do assistente |
| `GET` | `/health` | Estado, modo, versão e modelo em uso |
| `POST` | `/chat` | Atendimento; recebe `message` e, opcionalmente, `sessionId` |
| `POST` | `/classify` | Classificação de intenção. Na `v2`, retorna o texto JSON com `intent`, `orderId` e `confidence` esperado pela suíte de contrato |

## Integração contínua

O workflow **AI Tests** executa em pushes, pull requests e por acionamento manual. [Acompanhar execuções no GitHub Actions](https://github.com/DouglasAntoni0/curso-testes-ia-promptfoo/actions/workflows/ai-tests.yml)

| Etapa | O que roda |
| --- | --- |
| **Regressão funcional** | Testes determinísticos de atendimento e contrato do classificador com `MODE=simulated` e `VERSION=v2`. |
| **Avaliação com IA** | Ollama no runner, calibração com `qwen3.8` e casos com juiz usando o assistente em `MODE=llm`. Esta etapa tem caráter informativo (`continue-on-error`). |
| **Relatórios** | Resumos e relatórios HTML nos artefatos da execução. O job de Pages reúne os HTMLs disponíveis para publicar um índice. |

O GitHub Pages precisa estar configurado com **Settings → Pages → Source → GitHub Actions** para o deploy dos relatórios. [Guia de configuração do GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site).

## Curso e créditos

O aplicativo **ShopDemo Assistente** e sua base didática são de **Jeferson Fabiano Caye**. Este repositório registra minha adaptação do ambiente e a construção dos testes durante os estudos.

- **Curso:** [Automação de Testes de IA: Chatbots e LLMs com promptfoo — Udemy](https://www.udemy.com/course/automacao-de-testes-de-ia-chatbots-e-llms-com-promptfoo/)
- **Material original:** [jefersoncaye/curso-testes-ia-promptfoo](https://github.com/jefersoncaye/curso-testes-ia-promptfoo)
- **Estudos e evolução deste repositório:** [Douglas Antonio](https://github.com/DouglasAntoni0)
