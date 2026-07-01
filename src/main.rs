mod cli;
mod commands;

use clap::Parser;
use cli::{Cli, Commands};

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Config { init, remove }) => {
            if *init {
                commands::config::init();
            } else if *remove {
                commands::config::remove();
            } else {
                println!("Por favor, forneça uma flag para o comando config. Ex: --init ou --remove");
                println!("Use 'capivara config --help' para mais informações.");
            }
        }
        Some(Commands::Configs) => {
            commands::config::show_configs();
        }
        None => {
            // Em uma versão futura (Épico 2), aqui será chamado o TUI
            // Por enquanto, apenas exibimos o help padrão da CLI
            use clap::CommandFactory;
            let mut cmd = Cli::command();
            cmd.print_help().unwrap();
        }
    }
}
