use colored::Colorize;
use serde_json::json;
use std::fs;
use std::io::{self, Write};
use std::path::Path;

const CONFIG_FILE: &str = "capivara.json";

/// Executa o comando `config --init`
pub fn init() {
    let path = Path::new(CONFIG_FILE);

    if path.exists() {
        println!("{}", "Aviso: O arquivo capivara.json já existe neste projeto!".yellow());
        print!("Deseja substituí-lo e perder as configurações atuais? (y/n): ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        let input = input.trim().to_lowercase();

        if input != "y" {
            println!("Operação cancelada.");
            return;
        }
    }

    let default_config = json!({
        "project_name": "automation_project",
        "framework": "capybara",
        "language": "ruby",
        "paths": {
            "features": "features",
            "pages": "features/page_objects/pages",
            "steps": "features/step_definitions"
        }
    });

    let json_string = serde_json::to_string_pretty(&default_config).unwrap();

    match fs::write(path, json_string) {
        Ok(_) => {
            println!("{}", "Arquivo capivara.json criado com sucesso!".green());
            println!("Por favor, configure o arquivo capivara.json com os dados do seu projeto.");
        }
        Err(e) => {
            println!("{} {}", "Erro ao criar o arquivo:".red(), e);
        }
    }
}

/// Executa o comando `config --remove`
pub fn remove() {
    let path = Path::new(CONFIG_FILE);

    if !path.exists() {
        println!("{} não encontrado no projeto.", CONFIG_FILE);
        return;
    }

    println!("{}", "ATENÇÃO: O arquivo capivara.json será removido e todas as configurações serão perdidas.".red());
    print!("Tem certeza que deseja continuar? (y/n): ");
    io::stdout().flush().unwrap();

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();
    let input = input.trim().to_lowercase();

    if input == "y" {
        match fs::remove_file(path) {
            Ok(_) => println!("{}", "Arquivo removido com sucesso.".green()),
            Err(e) => println!("{} {}", "Erro ao remover o arquivo:".red(), e),
        }
    } else if input == "n" {
        println!("Operação cancelada.");
    } else {
        println!("Comando não reconhecido. Operação cancelada.");
    }
}

/// Executa o comando `configs`
pub fn show_configs() {
    let path = Path::new(CONFIG_FILE);

    if !path.exists() {
        println!("{} não encontrado. Execute 'capivara config --init' para criar um.", CONFIG_FILE);
        return;
    }

    match fs::read_to_string(path) {
        Ok(content) => {
            println!("{}", "Configurações atuais (capivara.json):".cyan());
            println!("{}", content);
        }
        Err(e) => {
            println!("{} {}", "Erro ao ler o arquivo:".red(), e);
        }
    }
}
