mod cli;
mod commands;
mod templates;

use clap::Parser;
use cli::{Cli, Commands};

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Config {
            init,
            remove,
            template_save,
            list_template,
        }) => {
            if *init {
                commands::config::init();
            } else if *remove {
                commands::config::remove();
            } else if let Some(template_path) = template_save {
                commands::config::save_template(template_path);
            } else if *list_template {
                commands::config::list_templates();
            } else {
                println!(
                    "Por favor, forneça uma flag para o comando config. Ex: --init, --remove, --template-save ou --list-template"
                );
                println!("Use 'capivara config --help' para mais informações.");
            }
        }
        Some(Commands::Create { new, template }) => {
            commands::create::run(new, template.as_deref());
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
