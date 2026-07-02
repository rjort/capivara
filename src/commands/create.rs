use colored::Colorize;
use serde_yaml::{Mapping, Value};
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};

use crate::templates;

/// Executa o comando `create --new`, criando um projeto a partir de um template YAML.
pub fn run(project_name: &str, template_name: Option<&str>) {
    let project_path = Path::new(project_name);
    let template_project_name = project_path
        .file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(project_name)
        .to_lowercase();

    if project_path.exists() && !confirm_project_replace(project_path) {
        println!("Operação cancelada.");
        return;
    }

    let template = match templates::load_template(template_name) {
        Ok(template) => template,
        Err(e) => {
            println!("{} {}", "Erro ao carregar template:".red(), e);
            return;
        }
    };

    let template_data: Value = match serde_yaml::from_str(&template.content) {
        Ok(value) => value,
        Err(e) => {
            println!("{} {}", "Erro ao interpretar template YAML:".red(), e);
            return;
        }
    };

    if project_path.exists() {
        if let Err(e) = remove_existing_path(project_path) {
            println!("{} {}", "Erro ao substituir projeto existente:".red(), e);
            return;
        }
    }

    if let Err(e) = fs::create_dir_all(project_path) {
        println!("{} {}", "Erro ao criar projeto:".red(), e);
        return;
    }

    println!("{}  {}", "create".green(), project_path.display());

    match template_data {
        Value::Mapping(mapping) => {
            if let Err(e) = create_from_mapping(project_path, &mapping, &template_project_name) {
                println!("{} {}", "Erro ao criar estrutura do projeto:".red(), e);
                return;
            }
        }
        _ => {
            println!(
                "{}",
                "Template inválido: a raiz do YAML deve ser um objeto.".red()
            );
            return;
        }
    }

    println!(
        "{}",
        format!(
            "Projeto '{}' criado com sucesso usando o template '{}'.",
            project_name, template.name
        )
        .green()
    );
}

fn confirm_project_replace(project_path: &Path) -> bool {
    println!(
        "{}",
        format!(
            "Aviso: já existe um projeto chamado '{}'.",
            project_path.display()
        )
        .yellow()
    );
    println!(
        "{}",
        "Se continuar, todos os arquivos desse projeto serão perdidos.".yellow()
    );
    print!("Deseja substituir o projeto? (y/n): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    input.trim().eq_ignore_ascii_case("y")
}

fn remove_existing_path(path: &Path) -> io::Result<()> {
    if path.is_dir() {
        fs::remove_dir_all(path)
    } else {
        fs::remove_file(path)
    }
}

fn create_from_mapping(
    base_path: &Path,
    mapping: &Mapping,
    project_name: &str,
) -> Result<(), String> {
    for (key, value) in mapping {
        let key = key
            .as_str()
            .ok_or_else(|| "Todas as chaves do template devem ser texto.".to_string())?;
        let path = base_path.join(render_template_name(key, project_name));

        match value {
            Value::Mapping(child_mapping) => {
                create_dir(&path)?;
                create_from_mapping(&path, child_mapping, project_name)?;
            }
            Value::Null => create_file(&path, None)?,
            Value::String(content) => create_file(&path, Some(content))?,
            Value::Bool(_) | Value::Number(_) => {
                create_file(&path, Some(&value_to_string(value)?))?
            }
            _ => {
                return Err(format!(
                    "Tipo não suportado para '{}'. Use objeto, texto ou null.",
                    path.display()
                ));
            }
        }
    }

    Ok(())
}

fn create_dir(path: &Path) -> Result<(), String> {
    fs::create_dir_all(path)
        .map_err(|e| format!("Erro ao criar diretório '{}': {}", path.display(), e))?;
    println!("{}  {}", "create".green(), path.display());
    Ok(())
}

fn create_file(path: &Path, content: Option<&str>) -> Result<(), String> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| format!("Erro ao criar diretório '{}': {}", parent.display(), e))?;
    }

    fs::write(path, content.unwrap_or_default())
        .map_err(|e| format!("Erro ao criar arquivo '{}': {}", path.display(), e))?;
    println!("{}  {}", "create".green(), path.display());

    Ok(())
}

fn render_template_name(name: &str, project_name: &str) -> PathBuf {
    PathBuf::from(name.replace("project_name", project_name))
}

fn value_to_string(value: &Value) -> Result<String, String> {
    serde_yaml::to_string(value)
        .map(|content| content.trim_end().to_string())
        .map_err(|e| format!("Erro ao converter valor do template: {}", e))
}
