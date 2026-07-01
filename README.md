# Capivara (v2.0.0)

Capivara é um projeto open-source que visa ajudar QAs e DEVs a criarem templates rápidos para automações de testes, tanto para FRONTEND quanto para BACKEND. 

Nesta versão (v2.0.0), a ferramenta está sendo reconstruída em **Rust**, adotando uma abordagem híbrida (TUI + CLI) para oferecer maior extensibilidade de frameworks (Capybara, Playwright, Cypress) e uma experiência superior.

## Dependências

- [Rust / Cargo](https://www.rust-lang.org/tools/install)

## Instalação (Desenvolvimento)

Faça o clone do projeto e recompile via Cargo:

```bash
git clone https://github.com/seu-usuario/capivara_rust.git
cd capivara_rust
cargo build --release
```

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

---

## Contribuindo

Siga as diretrizes de versionamento da ferramenta:
- Utilize versionamento semântico.
- Novas funcionalidades devem ser criadas em branches seguindo o padrão: `feat/<versao>` (Ex: `feat/2.1.0`).
- Documente seu código.
