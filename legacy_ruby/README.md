# Capivara

Uma mini ferramenta de geracao de arquivos para auxiliar desenvolmento de automacoes.

## Comandos

### CONFIG

- Inicia uma nova configuracao para um projeto ja existente.

`$ capivara config --init`

---

### CREATE

- Inicia um novo projeto com base no template `lib/templates`

> _Por default usa o template de frontend_

`$ capivara create --new automation_frontend`

`$ capivara -T default_back c --new automation_backend`

---

### GENERATE

- Gera um novo arquivo (ou todos) de acordo com o tipo de arquivo

#### ALL

- Gera os 3 principais arquivos para os cenarios: Page, Gherkin, Step.

`$ capivara g --all new_scenario`

#### GHERKIN

- Gera um novo arquivo de Gherkin (.feature)

`$ capivara g -G new_gherkin`

#### PAGE

- Gera um novo arquivo de Page (.rb)

`$ capivara generate --page new_page`

#### STEP

- Gera um novo arquivo de Step (\_step.rb)

`$ capivara g -s new_step`

#### SECTION

- Gera um novo arquivo de Section (.rb)

`$ capivara g -S new_section`
