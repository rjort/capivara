use clap::{Parser, Subcommand};

/// Capivara - Gerador de templates para automação de testes
#[derive(Parser)]
#[command(name = "capivara")]
#[command(version = "2.0.0", about = "CLI para gerar templates de automação", long_about = None)]
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
    },
    /// Exibe o conteúdo do arquivo capivara.json
    Configs,
}
