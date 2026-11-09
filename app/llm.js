// Single client supporting Ollama native /api/chat (with think: false)
// and OpenAI-compatible /v1/chat/completions endpoints.
const config = require('./config');

async function chatCompletion(messages) {
  const isOllama =
    config.llm.apiKey === 'ollama' ||
    config.llm.baseUrl.includes(':11434');

  if (isOllama) {
    const ollamaRoot = config.llm.baseUrl.replace(/\/v1$/, '');
    const response = await fetch(`${ollamaRoot}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: config.llm.model,
        messages,
        stream: false,
        think: false,
        options: {
          temperature: config.llm.temperature,
        },
      }),
      signal: AbortSignal.timeout(180000),
    });

    if (!response.ok) {
      const body = await response.text();
      throw new Error(`LLM ${response.status}: ${body.slice(0, 300)}`);
    }

    const data = await response.json();
    const content = data.message?.content ?? '';
    return content.replace(/<think>[\s\S]*?<\/think>/g, '').replace(/^[\s\S]*<\/think>/, '').trim();
  }

  const response = await fetch(`${config.llm.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${config.llm.apiKey}`,
    },
    body: JSON.stringify({
      model: config.llm.model,
      messages,
      temperature: config.llm.temperature,
      think: false,
      reasoning_effort: 'none',
    }),
    signal: AbortSignal.timeout(180000),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`LLM ${response.status}: ${body.slice(0, 300)}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content ?? '';
  // Removes a reasoning block if the model returns one inside the content
  return content.replace(/<think>[\s\S]*?<\/think>/g, '').replace(/^[\s\S]*<\/think>/, '').trim();
}

module.exports = { chatCompletion };
