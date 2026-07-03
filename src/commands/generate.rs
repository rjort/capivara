use colored::Colorize;
use serde::Deserialize;
use std::fs;
use std::io::{self, Write};
use std::path::{Component, Path, PathBuf};

const CONFIG_FILE: &str = "capivara.json";

/// Representa os dados do `capivara.json` necessários para gerar arquivos.
#[derive(Deserialize)]
struct CapivaraConfig {
    project_name: String,
    paths: CapivaraPaths,
}

/// Paths usados pelo `generate --all` para salvar cada tipo de arquivo.
#[derive(Deserialize)]
struct CapivaraPaths {
    gherkin: String,
    pages: String,
    steps: String,
}

/// Arquivo que será criado ou substituído durante a geração.
struct GeneratedFile {
    path: PathBuf,
    content: String,
}

/// Executa o comando `generate --all`, criando gherkin, page object e step definition.
pub fn all(file_name: &str) {
    if let Err(e) = validate_file_name(file_name) {
        println!("{} {}", "Nome inválido para geração:".red(), e);
        return;
    }

    let config = match read_config() {
        Ok(config) => config,
        Err(e) => {
            println!("{} {}", "Erro ao ler capivara.json:".red(), e);
            return;
        }
    };

    let generated_files = build_all_files(&config, file_name);

    for file in generated_files {
        if let Err(e) = write_generated_file(&file) {
            println!("{} {}", "Erro ao gerar arquivo:".red(), e);
            return;
        }
    }
}

/// Valida o nome solicitado para impedir geração fora do projeto atual.
fn validate_file_name(file_name: &str) -> Result<(), String> {
    let path = Path::new(file_name);

    if file_name.trim().is_empty() {
        return Err("informe um nome de arquivo.".to_string());
    }

    if path.is_absolute() {
        return Err("use um caminho relativo, por exemplo: login ou admin/login.".to_string());
    }

    if path
        .components()
        .any(|component| matches!(component, Component::CurDir | Component::ParentDir))
    {
        return Err("o caminho não pode conter '.' ou '..'.".to_string());
    }

    Ok(())
}

/// Lê e valida o arquivo de configuração do projeto atual.
fn read_config() -> Result<CapivaraConfig, String> {
    let path = Path::new(CONFIG_FILE);

    if !path.exists() {
        return Err(
            "arquivo não encontrado. Execute 'capivara config --init' primeiro.".to_string(),
        );
    }

    let content = fs::read_to_string(path)
        .map_err(|e| format!("não foi possível abrir '{}': {}", CONFIG_FILE, e))?;

    if content.trim().is_empty() {
        return Err(
            "arquivo está vazio. Execute 'capivara config --init' para recriá-lo.".to_string(),
        );
    }

    serde_json::from_str(&content).map_err(|e| {
        format!(
            "JSON inválido ou incompleto. Verifique project_name e paths.gherkin/pages/steps: {}",
            e
        )
    })
}

/// Monta a lista de arquivos que representam a geração completa do padrão Capybara.
fn build_all_files(config: &CapivaraConfig, file_name: &str) -> Vec<GeneratedFile> {
    let base_name = file_base_name(file_name);
    let title = humanize_name(&base_name);

    vec![
        GeneratedFile {
            path: Path::new(&config.paths.gherkin)
                .join(file_name)
                .join(format!("{}.feature", base_name)),
            content: gherkin_content(&title),
        },
        GeneratedFile {
            path: Path::new(&config.paths.pages)
                .join(file_name)
                .join(format!("{}.rb", base_name)),
            content: page_content(&config.project_name, &base_name),
        },
        GeneratedFile {
            path: Path::new(&config.paths.steps)
                .join(file_name)
                .join(format!("{}_step.rb", base_name)),
            content: step_content(),
        },
    ]
}

/// Cria ou substitui um arquivo gerado, pedindo confirmação quando necessário.
fn write_generated_file(file: &GeneratedFile) -> Result<(), String> {
    let action = if file.path.exists() {
        if !confirm_replace(&file.path) {
            println!("{}  {}", "skip".yellow(), file.path.display());
            return Ok(());
        }
        "replace"
    } else {
        "create"
    };

    if let Some(parent) = file.path.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| format!("não foi possível criar '{}': {}", parent.display(), e))?;
    }

    fs::write(&file.path, &file.content)
        .map_err(|e| format!("não foi possível escrever '{}': {}", file.path.display(), e))?;

    println!("{}  {}", action.green(), file.path.display());

    Ok(())
}

/// Solicita confirmação antes de substituir um arquivo existente.
fn confirm_replace(path: &Path) -> bool {
    println!(
        "{}",
        format!("Aviso: o arquivo '{}' já existe.", path.display()).yellow()
    );
    print!("Deseja substituí-lo? (y/n): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    input.trim().eq_ignore_ascii_case("y")
}

/// Retorna o último segmento do caminho informado para nomear o arquivo final.
fn file_base_name(file_name: &str) -> String {
    Path::new(file_name)
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(file_name)
        .to_string()
}

/// Converte nomes técnicos em texto simples para o título inicial do Gherkin.
fn humanize_name(name: &str) -> String {
    name.replace(['_', '-'], " ")
}

/// Converte nomes com separadores em CamelCase para módulos Ruby.
fn to_camel_case(name: &str) -> String {
    name.split(['_', '-', '/', '\\', ' '])
        .filter(|part| !part.is_empty())
        .map(|part| {
            let mut chars = part.chars();
            match chars.next() {
                Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
                None => String::new(),
            }
        })
        .collect::<String>()
}

/// Conteúdo base para arquivos `.feature`.
fn gherkin_content(title: &str) -> String {
    format!("# language: pt\n\nFuncionalidade: {}\n", title)
}

/// Conteúdo base para page objects Capybara/SitePrism.
fn page_content(project_name: &str, file_name: &str) -> String {
    format!(
        "module {}\n  module Pages\n    module {}\n      class Home < SitePrism::Page\n        set_url '/'\n      end\n    end\n  end\nend\n",
        to_camel_case(project_name),
        to_camel_case(file_name)
    )
}

/// Conteúdo base para step definitions Ruby.
fn step_content() -> String {
    "# Dado\n# Quando\n# Então\n".to_string()
}
