# Capivara (v2.2.0)

Capivara é um projeto open-source que visa ajudar QAs e DEVs a criarem templates rápidos para automações de testes, tanto para FRONTEND quanto para BACKEND. 

Nesta versão (v2.2.0), a ferramenta está sendo reconstruída em **Rust**, adotando uma abordagem híbrida (TUI + CLI) para oferecer maior extensibilidade de frameworks (Capybara, Playwright, Cypress).

## Dependências

- [Rust / Cargo](https://www.rust-lang.org/tools/install)

## Instalação (Desenvolvimento)

Faça o clone do projeto e recompile via Cargo:

```bash
git clone https://github.com/seu-usuario/capivara.git
cd capivara
cargo build --release
```

> **Nota de Migração**: O código original (v1) em Ruby foi movido de forma segura para a pasta `legacy_ruby/` para referência histórica.

## Comandos Disponíveis (Épico 1)

### Ajuda (HELP)

Você pode verificar todos os comandos disponíveis e a versão atual do Capivara:

```bash
capivara --help
capivara -V
```

### Configurações (CONFIG)

O Capivara utiliza um arquivo `capivara.json` no projeto para saber como gerenciar e gerar os seus arquivos de teste.

#### Iniciar Configuração

Gera um arquivo de configuração padrão no diretório atual.

```bash
capivara config --init
```
> *Nota: Se o arquivo já existir, a ferramenta alertará você e pedirá confirmação antes de sobrescrever, para evitar perdas acidentais.*

#### Remover Configuração

Remove o arquivo `capivara.json` do diretório atual de forma segura.

```bash
capivara config --remove
# ou
capivara config -r
```

#### Exibir Configurações

Exibe no terminal todo o conteúdo formatado do seu `capivara.json` atual, se ele existir.

```bash
capivara configs
```

#### Salvar Template

Salva um template YAML em `$HOME/.capivara/templates` para reutilização no comando `create`.

```bash
capivara config --template-save meu_template.yml
# ou
capivara config -T meu_template.yml
```

#### Listar Templates

Lista os templates internos e os templates salvos pelo usuário.

```bash
capivara config --list-template
# ou
capivara config -L
```

O arquivo `capivara.json` criado pelo `config --init` define os paths usados pelo comando `generate`:

```json
{
  "project_name": "automation_project",
  "framework": "capybara",
  "language": "ruby",
  "template": "default_front",
  "paths": {
    "features": "features",
    "gherkin": "features/specs",
    "pages": "features/page_objects/pages",
    "steps": "features/step_definitions",
    "sections": "features/page_objects/sections",
    "services": "features/services"
  }
}
```

### Criar Projeto (CREATE)

Cria uma estrutura de projeto de automação a partir de um template. Quando o template é omitido, o Capivara utiliza `default_front`.

```bash
capivara create --new meu_projeto
capivara create --new meu_projeto -T default_back
capivara c --new meu_projeto -T meu_template
```

### Criação de Templates

Os templates do Capivara são arquivos YAML (`.yml` ou `.yaml`) que descrevem a estrutura de pastas e arquivos que será criada pelo comando `create`.

Atualmente, existem dois tipos de templates:

- Templates internos, disponíveis no próprio Capivara: `default_front` e `default_back`.
- Templates do usuário, salvos em `$HOME/.capivara/templates`.

Para listar todos os templates disponíveis:

```bash
capivara config --list-template
# ou
capivara config -L
```

Para salvar um template próprio na pasta global de templates:

```bash
capivara config --template-save meu_template.yml
# ou
capivara config -T meu_template.yml
```

Depois de salvo, o template pode ser usado pelo nome do arquivo sem a extensão:

```bash
capivara create --new meu_projeto -T meu_template
```

A estrutura do YAML segue estas regras:

- Chaves com objetos criam diretórios.
- Chaves com `null` criam arquivos vazios.
- Chaves com texto criam arquivos com o conteúdo informado.

Exemplo de template:

```yaml
README.md: "Projeto criado com Capivara"
Gemfile: null
features:
  specs:
    .keep: null
  support:
    env.rb: null
```

No exemplo acima, o Capivara criará `README.md` com conteúdo, `Gemfile` vazio, a pasta `features/specs` com um `.keep` e o arquivo `features/support/env.rb`.

Templates também podem usar o marcador `project_name` em nomes de pastas ou arquivos. Durante a criação, esse marcador será substituído pelo nome do projeto em letras minúsculas.

```yaml
features:
  support:
    env:
      project_name:
        dev:
          base.yml: "basedomain:"
```

Ao criar `capivara create --new minha_automacao`, o caminho gerado será `features/support/env/minha_automacao/dev/base.yml`.

### Gerar Arquivos (GENERATE)

O comando `generate` cria arquivos dentro de um projeto já existente, usando as configurações do `capivara.json`.

Na versão `v2.2.0`, o `generate --all` usa o padrão Capybara/Ruby e cria três arquivos principais:

- Gherkin em `paths.gherkin`.
- Page object em `paths.pages`.
- Step definition em `paths.steps`.

Exemplo:

```bash
capivara generate --all login
# ou
capivara generate -A login
# ou
capivara g --all login
```

Com o `capivara.json` padrão, o comando acima cria:

```text
features/specs/login/login.feature
features/page_objects/pages/login/login.rb
features/step_definitions/login/login_step.rb
```

Também é possível informar caminhos relativos no nome do arquivo:

```bash
capivara generate -A admin/login
```

Nesse caso, o Capivara cria os arquivos dentro das subpastas correspondentes, mantendo o nome final como base do arquivo:

```text
features/specs/admin/login/login.feature
features/page_objects/pages/admin/login/login.rb
features/step_definitions/admin/login/login_step.rb
```

Se algum arquivo já existir, o Capivara exibirá um warning e perguntará se o arquivo deve ser substituído.

---

## Contribuindo

Siga as diretrizes de versionamento da ferramenta:
- Utilize versionamento semântico.
- Novas funcionalidades devem ser criadas em branches seguindo o padrão: `feat/<versao>` (Ex: `feat/2.1.0`).
- Documente seu código.
