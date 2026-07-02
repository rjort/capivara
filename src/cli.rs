use clap::{Parser, Subcommand};

/// Capivara - Gerador de templates para automação de testes
#[derive(Parser)]
#[command(name = "capivara")]
#[command(version = "2.1.0", about = "CLI para gerar templates de automação", long_about = None)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Option<Commands>,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Gerencia configurações do projeto
    Config {
        /// Inicia um arquivo capivara.json
        #[arg(long)]
        init: bool,

        /// Remove o arquivo capivara.json
        #[arg(short, long)]
        remove: bool,

        /// Salva um template YAML na pasta global de templates do usuário
        #[arg(short = 'T', long = "template-save", value_name = "template_yml")]
        template_save: Option<String>,

        /// Lista os templates internos e salvos pelo usuário
        #[arg(short = 'L', long = "list-template")]
        list_template: bool,
    },
    /// Cria um novo projeto de automação a partir de um template
    #[command(alias = "c")]
    Create {
        /// Nome do projeto que será criado
        #[arg(long = "new", value_name = "nome_do_projeto", required = true)]
        new: String,

        /// Template usado para criar o projeto
        #[arg(short = 'T', long = "template", value_name = "template")]
        template: Option<String>,
    },
    /// Exibe o conteúdo do arquivo capivara.json
    Configs,
}
