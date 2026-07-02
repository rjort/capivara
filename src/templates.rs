use std::env;
use std::fs;
use std::path::{Path, PathBuf};

const INTERNAL_TEMPLATES: [(&str, &str); 2] = [
    (
        "default_front",
        include_str!("../templates/default_front.yml"),
    ),
    (
        "default_back",
        include_str!("../templates/default_back.yml"),
    ),
];

/// Representa um template carregado, seja interno ou salvo pelo usuário.
pub struct LoadedTemplate {
    pub name: String,
    pub content: String,
}

/// Retorna o diretório global onde os templates do usuário são armazenados.
pub fn user_templates_dir() -> Result<PathBuf, String> {
    let home = env::var_os("HOME")
        .map(PathBuf::from)
        .ok_or_else(|| "Não foi possível identificar a variável HOME.".to_string())?;

    Ok(home.join(".capivara").join("templates"))
}

/// Copia um template YAML para `$HOME/.capivara/templates`.
pub fn save_user_template(template_path: &str) -> Result<PathBuf, String> {
    let source = resolve_local_template_path(template_path)
        .ok_or_else(|| format!("Template '{}' não encontrado.", template_path))?;

    validate_yaml_extension(&source)?;

    let file_name = source
        .file_name()
        .ok_or_else(|| "O caminho informado não possui nome de arquivo válido.".to_string())?;
    let destination_dir = user_templates_dir()?;
    fs::create_dir_all(&destination_dir)
        .map_err(|e| format!("Erro ao criar pasta de templates: {}", e))?;

    let destination = destination_dir.join(file_name);
    fs::copy(&source, &destination)
        .map_err(|e| format!("Erro ao salvar template do usuário: {}", e))?;

    Ok(destination)
}

/// Lista os nomes dos templates internos e dos templates salvos pelo usuário.
pub fn list_templates() -> Result<(Vec<String>, Vec<String>), String> {
    let internal = INTERNAL_TEMPLATES
        .iter()
        .map(|(name, _)| name.to_string())
        .collect();

    let user_dir = user_templates_dir()?;
    let mut user = Vec::new();

    if user_dir.exists() {
        let entries = fs::read_dir(&user_dir)
            .map_err(|e| format!("Erro ao listar templates do usuário: {}", e))?;

        for entry in entries {
            let entry = entry.map_err(|e| format!("Erro ao ler template do usuário: {}", e))?;
            let path = entry.path();

            if is_yaml_file(&path) {
                if let Some(name) = path.file_stem().and_then(|name| name.to_str()) {
                    user.push(name.to_string());
                }
            }
        }
    }

    user.sort();

    Ok((internal, user))
}

/// Carrega um template pelo nome, caminho local ou pelo padrão `default_front`.
pub fn load_template(template_name: Option<&str>) -> Result<LoadedTemplate, String> {
    let name = template_name.unwrap_or("default_front");

    if let Some(path) = resolve_local_template_path(name) {
        validate_yaml_extension(&path)?;
        return read_template_file(&path);
    }

    if let Some(path) = resolve_user_template_path(name)? {
        return read_template_file(&path);
    }

    if let Some((internal_name, content)) = INTERNAL_TEMPLATES
        .iter()
        .find(|(internal_name, _)| template_matches(name, internal_name))
    {
        return Ok(LoadedTemplate {
            name: internal_name.to_string(),
            content: content.to_string(),
        });
    }

    Err(format!("Template '{}' não encontrado.", name))
}

fn resolve_user_template_path(template_name: &str) -> Result<Option<PathBuf>, String> {
    let user_dir = user_templates_dir()?;

    for candidate in template_candidates(&user_dir.join(template_name)) {
        if candidate.exists() {
            validate_yaml_extension(&candidate)?;
            return Ok(Some(candidate));
        }
    }

    Ok(None)
}

fn resolve_local_template_path(template_path: &str) -> Option<PathBuf> {
    template_candidates(Path::new(template_path))
        .into_iter()
        .find(|path| path.exists())
}

fn template_candidates(path: &Path) -> Vec<PathBuf> {
    if path.extension().is_some() {
        return vec![path.to_path_buf()];
    }

    vec![
        path.to_path_buf(),
        PathBuf::from(format!("{}.yml", path.display())),
        PathBuf::from(format!("{}.yaml", path.display())),
    ]
}

fn read_template_file(path: &Path) -> Result<LoadedTemplate, String> {
    let content = fs::read_to_string(path)
        .map_err(|e| format!("Erro ao ler template '{}': {}", path.display(), e))?;
    let name = path
        .file_stem()
        .and_then(|name| name.to_str())
        .unwrap_or("template")
        .to_string();

    Ok(LoadedTemplate { name, content })
}

fn template_matches(input: &str, template_name: &str) -> bool {
    input == template_name
        || input == format!("{}.yml", template_name)
        || input == format!("{}.yaml", template_name)
}

fn validate_yaml_extension(path: &Path) -> Result<(), String> {
    if is_yaml_file(path) {
        return Ok(());
    }

    Err(format!(
        "Template '{}' deve possuir extensão .yml ou .yaml.",
        path.display()
    ))
}

fn is_yaml_file(path: &Path) -> bool {
    path.extension()
        .and_then(|extension| extension.to_str())
        .map(|extension| matches!(extension.to_lowercase().as_str(), "yml" | "yaml"))
        .unwrap_or(false)
}
