# gemini-cli-config

Este repositório armazena as configurações do Gemini CLI.

## Estrutura do Diretório

- **.gemini/**: Contém os arquivos de configuração e contexto do Gemini CLI.
  - **.env**: Arquivo para definir variáveis de ambiente.
  - **GEMINI.md**: Arquivo de contexto principal que pode ser usado para fornecer informações ao modelo.
  - **settings.json**: Arquivo de configuração principal do Gemini CLI.
  - **commands/**: Diretório para definir comandos personalizados.

## O arquivo `settings.json`

O arquivo `settings.json` é usado para configurar o comportamento do Gemini CLI.

### `context`

Define o arquivo de contexto a ser usado. Por padrão, é `GEMINI.md`.

```json
"context": {
  "fileName": "GEMINI.md"
}
```

### `mcpServers`

Esta seção configura os servidores do Model Context Protocol (MCP). O MCP permite que o Gemini CLI interaja com várias ferramentas e serviços.

- **context7**: Fornece documentação de código atualizada e específica da versão para evitar que o modelo gere código desatualizado. Mais informações em [upstash/context7](https://github.com/upstash/context7).
- **atlassian**: Permite a interação com as ferramentas da Atlassian, como Jira e Confluence. Mais informações em [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian).
- **github**: Integra o Gemini CLI com a plataforma GitHub, permitindo ações como navegar em repositórios, gerenciar issues e pull requests. Mais informações em [github/github-mcp-server](https://github.com/github/github-mcp-server).

```json
"mcpServers": {
  "context7": {
    "httpUrl": "https://mcp.context7.com/mcp"
  },
  "atlassian": {
    "command": "npx",
    "args": [
      "-y",
      "mcp-remote",
      "https://mcp.atlassian.com/v1/sse"
    ]
  },
  "github": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-github"
    ],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "seu_token_aqui"
    }
  }
}
```

### `ui`

Configura a aparência da interface do usuário.

```json
"ui": {
  "theme": "ANSI"
}
```

### `preferedEditor`

Define o editor de código preferido.

```json
"preferedEditor": "vscode"
```

## O arquivo `GEMINI.md`

O arquivo `GEMINI.md` serve como um prompt de sistema persistente para o Gemini. O conteúdo deste arquivo é pré-anexado a cada prompt enviado ao modelo. Isso é útil para fornecer contexto, diretrizes e instruções consistentes para o modelo em todas as interações.

Neste repositório, o `GEMINI.md` contém o Guia de Estilo Python do Google, garantindo que o modelo siga as convenções de codificação do Google ao gerar ou analisar código Python.

## Comandos Personalizados

O diretório `commands` permite a criação de comandos personalizados que podem ser executados no Gemini CLI. Cada comando é definido por um arquivo `.toml` que contém uma descrição e um prompt.

### `/explain`

O comando `explain` é definido em `explain.toml`. Ele instrui o modelo a analisar o código e responder a perguntas sobre ele em um modo somente leitura.

- **Descrição**: "Explain mode. Analyzes the codebase to answer questions and provide insights."
- **Uso**: `/explain <sua_pergunta>`

### `/plan`

O comando `plan` é um comando aninhado com subcomandos definidos no diretório `plan/`.

#### `/plan new`

Definido em `plan/new.toml`, este comando gera um plano de implementação detalhado para uma nova funcionalidade.

- **Descrição**: "Plan mode. Generates a plan for a feature based on a description"
- **Uso**: `/plan new <descrição_da_feature>`

#### `/plan impl`

Definido em `plan/impl.toml`, este comando executa um plano de implementação existente.

- **Descrição**: "Implementation mode. Implements a plan for a feature based on a description"
- **Uso**: `/plan impl <caminho_para_o_plano>`

#### `/plan refine`

Definido em `plan/refine.toml`, este comando refina um plano de implementação existente com base no feedback do usuário.

- **Descrição**: "Refinement mode. Refines an existing plan based on user feedback."
- **Uso**: `/plan refine <caminho_para_o_plano>`