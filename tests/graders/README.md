# Prompts de avaliação (juiz)

Prompts próprios para as asserções de RAG, usados em `cases/05-rag.yaml` com `rubricPrompt: file://...`.

| Arquivo | Asserção | Por que existe |
|---|---|---|
| `context-relevance.txt` | `context-relevance` | Com o prompt padrão, o juiz reescreve as frases do contexto e o promptfoo reprova com "Grader output does not quote the provided context" |
| `faithfulness-statements.txt` | `context-faithfulness` (etapa 1) | Extrai afirmações da resposta e mantém valores e condições juntos para a verificação |
| `faithfulness-verdicts.txt` | `context-faithfulness` (etapa 2) | Solicita uma linha no formato `Yes.` / `No.` esperado pelo promptfoo e inclui um exemplo com uma afirmação apoiada e outra contradita |

As variáveis entre `{{ }}` são preenchidas pelo promptfoo: `query` e `context` na relevância; `question`, `answer`, `context` e `statements` na fidelidade.

