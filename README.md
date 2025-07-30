# Text Co-Writer By INTERSPECIFICS

An AI-powered writing assistant that continues your creative writing with unique character voices and customizable elements.

## Quick Start

### 1. Install and Run

**macOS:**
```bash
chmod +x install_mac.sh
./install_mac.sh
./start_writer.sh
```

**Windows:**
```cmd
install_windows.ps1
start_writer.ps1
```

### 2. Choose Your Settings
- **Style**: sci-fi, poetry, essay, journalistic, or peer-review
- **Model**: Local (free) or cloud-based AI models
- **Character**: 6 unique writer personalities with distinct voices
- **Elements**: Optional sci-fi world-building elements

### 3. Start Writing
Enter your text prompt and the AI will continue your story in the chosen style and character voice.

## How to Use

### Basic Writing
1. **Enter your prompt** - the text you want continued
2. **Get AI continuation** - the AI continues your narrative
3. **Keep writing** - enter new prompts to continue the story

### Available Commands
- `quit` - Exit the program
- `new style` - Change writing style and elements
- `new character` - Change writer character
- `new model` - Change AI model
- `reload refs` - Reload reference materials
- `reload config` - Reload characters and custom elements
- `status` - Show current settings
- `help` - Show all commands

### Writer Characters

Choose from 6 unique voices:

1. **Cyra the Posthumanist** - Radical thinker exploring boundaries between species, machines, and matter
2. **Lia the Affective Nomad** - Restless philosopher of identity and becoming
3. **Dr. Orin** - Philosopher-scientist who sees phenomena as entangled events
4. **Fynn** - Analytical observer mapping relationships between humans, nonhumans, and objects
5. **ArwenDreamer** - Visionary who speaks with machines, animals, and spirits
6. **IxchelVoice** - Guardian of memory who speaks through rivers, stones, and dreams

### Writing Styles
- **sci-fi** - Futuristic science fiction
- **poetry** - Contemporary free verse
- **essay** - Formal reflective writing
- **journalistic** - New York Times feature style
- **peer-review** - Academic analytical style

### Custom Elements
Add sci-fi world-building elements like:
- `hybrid_plants`, `mechanical_bees`, `glacial_memory`
- `quantum_ecology`, `neural_networks`, `time_crystals`
- `atmospheric_poetry`, `memory_moss`

## Customization

### External Configuration Files

**Edit Characters (`characters.txt`):**
```
[my_character]
name: My Custom Character
personality: A thoughtful observer who sees patterns in chaos
interests: Systems thinking, emergent behavior, complexity theory
style: Analytical yet poetic, finding beauty in mathematical patterns
influences: Systems theory, complexity science, and philosophical traditions
```

**Edit Custom Elements (`custom_elements.txt`):**
```
quantum_forest: Forests where trees exist in quantum superposition
time_rivers: Flowing bodies of water that carry temporal energy
```

**Apply Changes:** Use `reload config` command to load your changes.

### Reference Materials
Add PDF, DOCX, or TXT files to the `reference_materials/` folder for style inspiration.

## Available Models

### Local Models (Free)
- **neural-chat** - Fast responses (4.1GB)
- **mistral** - Balanced performance (4.1GB)
- **llama2** - High quality (3.8GB)

### Cloud Models (Require API Keys)
- **gpt-3.5-turbo-instruct** - OpenAI's efficient model
- **gpt-4** - OpenAI's latest model
- **Hugging Face models** - Various hosted models

## Configuration

Edit `config.py` to set:
- API keys for cloud models
- Default settings
- Model preferences

## Troubleshooting

### Common Issues
1. **Ollama not running**: `brew services start ollama` (macOS) or `ollama serve` (Windows)
2. **Model not found**: `ollama pull model-name`
3. **API errors**: Check your API keys in `config.py`
4. **Reference materials not loading**: Check file formats (PDF, DOCX, TXT only)

### System Requirements
- **macOS**: 10.15+, Python 3.7+, Homebrew
- **Windows**: Windows 10+, Python 3.7+
- **Both**: Ollama (for local models), Internet (for cloud models)

## Project Structure
```
gtp-neo/
├── text_co_writer.py          # Main application
├── characters.txt             # Writer characters configuration
├── custom_elements.txt        # Custom elements configuration
├── config.py                  # Configuration file
├── install_mac.sh            # macOS installer
├── install_windows.ps1       # Windows installer
├── start_writer.sh           # macOS startup
├── start_writer.ps1          # Windows startup
└── reference_materials/       # Reference files folder
```

## Getting Help
- Check the troubleshooting section above
- Ensure Ollama is running for local models
- Verify internet connection for cloud models
- Review configuration in `config.py`



