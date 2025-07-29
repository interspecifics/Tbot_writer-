# GPT Neo-Style Text Co-Writer

A powerful AI text co-writing tool with support for multiple models and creative writing styles. By Interspecifics.

## Features

- **Multiple AI Models**: OpenAI, Ollama (local), and Hugging Face
- **Writer Characters**: 5 pre-defined fictional writer personalities
- **Custom Elements**: Sci-fi world-building elements
- **Writing Styles**: Sci-fi, academic, poetry, journalistic, and more
- **Continuous Operation**: Keep writing without restarting

## Quick Start

1. **Start the service** (if not already running):
   ```bash
   brew services start ollama
   ```

2. **Run the writer**:
   ```bash
   ./start_writer.sh
   ```
   or manually:
   ```bash
   source venv/bin/activate
   python text_co_writer.py
   ```

## Available Models

### Local Models (Free)
- **neural-chat**: Fast, good for quick responses
- **mistral**: Balanced performance and quality
- **llama2**: High quality, larger model

### Cloud Models (Require API Keys)
- **gpt-3.5-turbo-instruct**: OpenAI's model
- **gpt-4**: OpenAI's latest model

## Writer Characters

1. **Dr. Elara Quantum**: Eccentric quantum biologist
2. **Maya the Ecopoet**: Environmental activist poet
3. **Professor Chronos**: Time-obsessed historian
4. **Nova the Cyberpunk**: Tech-savvy urban explorer
5. **Sage the Mystic**: Spiritual seeker

## Custom Elements

Include sci-fi elements like:
- hybrid_plants, mechanical_bees, glacial_memory
- permafrost_seeds, siren_sounds, quantum_ecology
- neural_networks, time_crystals, atmospheric_poetry

## Configuration

Edit `config.py` to set your API keys and preferences.

## Commands

- `quit`: Exit the program
- `new style`: Change writing style and elements
- `new character`: Change writer character
- `new model`: Switch to different AI model

## Troubleshooting

1. **Ollama not running**: `brew services start ollama`
2. **Model not found**: `ollama pull model-name`
3. **API errors**: Check your API keys in config.py
4. **Virtual environment issues**: Run `source venv/bin/activate` before running the script

## Requirements

- macOS 10.15 or later
- Python 3.7+
- Homebrew
- Ollama (for local models)
- Internet connection (for cloud models)

## Installation

Run the installation script:
```bash
chmod +x install_mac.sh
./install_mac.sh
```

## Virtual Environment

This project uses a virtual environment to avoid conflicts with system Python packages.
- The virtual environment is created in the `venv/` directory
- Always activate it before running: `source venv/bin/activate`
- The `start_writer.sh` script handles this automatically
