# Text Co-Writer By INTERSPECIFICS

AI text co-writing tool that helps you continue and expand your creative writing with multiple AI models, unique writer personalities, and customizable elements. This tool is designed for writers who want to collaborate with AI while maintaining their creative voice and narrative direction. 

## What is GPT Neo-Style Text Co-Writer?

This is an intelligent writing assistant that:
- **Continues your story** in the same direction and style you've established
- **Offers multiple AI models** (local and cloud-based) for different writing needs
- **Features unique writer characters** with distinct personalities and writing styles
- **Supports reference materials** for style inspiration (without copying content)
- **Provides continuous operation** so you can keep writing without restarting
- **Includes sci-fi world-building elements** for creative enhancement
- **Smart model detection** - only shows models you actually have installed
- **Automatic API key configuration** for cloud-based models

## Key Features

### Multiple AI Models
- **Local Models (Free)**: neural-chat, mistral, llama2 - run entirely on your computer
- **Cloud Models**: OpenAI GPT-3.5/4, Hugging Face models - require API keys
- **Smart Detection**: Only shows models you have installed locally
- **Easy Switching**: Change models during your writing session
- **API Key Management**: Automatic prompting and validation for cloud models

### Writer Characters
Five pre-defined fictional writer personalities, each with unique voices:

1. **Cyra the Posthumanist**: Radical thinker who dissolves boundaries between species, machines, and matter
2. **Lia the Affective Nomad**: Restless and fluid, believes identity is a constant becoming  
3. **Dr. Orin**: Philosopher-scientist who sees phenomena as entangled events
4. **Fynn**: Analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects
5. **ArwenDreamer**: Visionary who thrives in hybrid worlds of machines, animals, and spirits

### Writing Styles
- **Sci-fi**: Futuristic science fiction with technological elements
- **Peer-review**: Academic, analytical writing style
- **Essay**: Formal reflective essay style
- **Poetry**: Contemporary free verse poetry
- **Journalistic**: New York Times feature article style

### Custom Elements
Include sci-fi world-building elements like:
- `hybrid_plants`, `mechanical_bees`, `glacial_memory`
- `permafrost_seeds`, `siren_sounds`, `quantum_ecology`
- `neural_networks`, `time_crystals`, `atmospheric_poetry`

### Reference Materials
- Support for **PDF**, **DOCX**, and **TXT** files
- Used for **style inspiration only** - AI won't copy content
- Helps maintain consistent writing tone and approach

### Interactive Commands
- `quit` - Exit the program
- `new style` - Change writing style and custom elements
- `new character` - Change writer character
- `new model` - Change AI model (with API key configuration)
- `reload refs` - Reload reference materials
- `status` - Show current settings
- `help` - Show all available commands

## Installation

### macOS Installation

1. **Download the project** and navigate to the directory:
   ```bash
   cd /path/to/Tbot_writer-
   ```

2. **Make the installation script executable**:
   ```bash
   chmod +x install_mac.sh
   ```

3. **Run the installation script**:
   ```bash
   ./install_mac.sh
   ```

The script will automatically:
- Install Homebrew (if needed)
- Install Python and pip
- Create a virtual environment
- Install required Python packages
- Install and configure Ollama
- Download AI models (neural-chat, mistral, llama2)
- Create configuration files
- Set up reference materials folder

### Windows Installation

1. **Download the project** and navigate to the directory:
   ```cmd
   cd C:\path\to\Tbot_writer-
   ```

2. **Run the installation script** as Administrator:

   **For PowerShell (recommended):**
   ```powershell
   .\install_windows.ps1
   ```

   **For Command Prompt:**
   ```cmd
   install_windows_fixed.bat
   ```

The script will automatically:
- **Install Python** (if not found) via winget or direct download
- Install required Python packages
- Download and install Ollama
- Download AI models
- Create configuration files
- Set up reference materials folder

## Quick Start

### macOS
1. **Start Ollama** (if not already running):
   ```bash
   brew services start ollama
   ```

2. **Run the writer**:
   ```bash
   ./start_writer.sh
   ```

### Windows
1. **Start Ollama** (if not already running):
   ```cmd
   ollama serve
   ```

2. **Run the writer**:
   ```powershell
   .\start_writer.ps1
   ```
   or:
   ```cmd
   start_writer.bat
   ```
   or manually:
   ```cmd
   python text_co_writer.py
   ```

## How to Use

1. **Choose your settings** when prompted:
   - Writing style (sci-fi, academic, poetry, etc.)
   - AI model (numbered selection available)
   - Writer character (numbered selection available)
   - Custom elements (optional)

2. **Enter your prompt** - the text you want the AI to continue from

3. **Get AI continuation** - the AI will continue your narrative in the same direction

4. **Use commands** during your session:
   - `quit`: Exit the program
   - `new style`: Change writing style and elements
   - `new character`: Change writer character
   - `new model`: Switch to different AI model (with API key configuration)
   - `reload refs`: Reload reference materials
   - `status`: Show current settings
   - `help`: Show all available commands

## Available Models

### Local Models (Free, No API Key Required)
- **neural-chat**: Fast, good for quick responses (4.1GB)
- **mistral**: Balanced performance and quality (4.1GB)
- **llama2**: High quality, larger model (3.8GB)
- **codellama**: Code-optimized Llama model (if installed)

### Cloud Models (Require API Keys)
- **gpt-3.5-turbo-instruct**: OpenAI's efficient model
- **gpt-4**: OpenAI's latest high-quality model
- **meta-llama/Llama-2-7b-chat-hf**: Hugging Face hosted Llama
- **microsoft/DialoGPT-medium**: Microsoft's conversational model

## Configuration

Edit `config.py` to customize your settings:

```python
# API Keys (add your keys here)
OPENAI_API_KEY = ""  # Get from https://platform.openai.com/api-keys
HUGGINGFACE_API_KEY = ""  # Get from https://huggingface.co/settings/tokens

# Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"

# Default settings
DEFAULT_MODEL = "neural-chat"
DEFAULT_STYLE = "sci-fi"
DEFAULT_CHARACTER = "cyra"
```

**Note**: The program will automatically prompt you for API keys when you select cloud-based models.

## Smart Model Detection

The program automatically detects which models you have installed locally and only shows those as available options. This prevents errors when trying to use models that aren't installed.

- **Local models**: Only shows models you have pulled with `ollama pull`
- **Cloud models**: Always available (require API keys)
- **Automatic validation**: Tests API keys before saving them

## Reference Materials

Add your own reference materials to the `reference_materials/` folder:
- **PDF files** (.pdf) - Research papers, books, articles
- **Word documents** (.docx, .doc) - Manuscripts, notes
- **Text files** (.txt) - Any plain text content

The AI will use these as **style inspiration only** - it won't copy content but will adopt the writing style and approach.

## Troubleshooting

### Common Issues

1. **Ollama not running**:
   - macOS: `brew services start ollama`
   - Windows: `ollama serve`

2. **Model not found**:
   ```bash
   ollama pull model-name
   ```

3. **API errors**:
   - Check your API keys in `config.py`
   - Ensure you have internet connection for cloud models
   - The program will prompt you for API keys when needed

4. **Virtual environment issues** (macOS):
   ```bash
   source venv/bin/activate
   ```

5. **Reference materials not loading**:
   - Check file formats (PDF, DOCX, TXT only)
   - Ensure files are in the `reference_materials/` folder

6. **AI copying reference content**:
   - Reference materials are for style inspiration only
   - The AI is instructed not to copy content

### Windows-Specific Issues

- **Python not found**: Installer now attempts automatic Python installation via winget or direct download
- **Permission errors**: Run installer as Administrator
- **VS Code terminal issues**: Use Command Prompt instead of PowerShell
- **Package installation fails**: Try updating pip first: `python -m pip install --upgrade pip`

### System Requirements

- **macOS**: 10.15 or later, Python 3.7+, Homebrew
- **Windows**: Windows 10 or later, Python 3.7+
- **Both**: Ollama (for local models), Internet connection (for cloud models)

## Dependencies

- **openai**: OpenAI API client
- **requests**: HTTP library for API calls
- **PyPDF2**: PDF text extraction
- **python-docx**: Word document text extraction

## Virtual Environment (macOS)

This project uses a virtual environment to avoid conflicts with system Python packages:
- Created in the `venv/` directory
- Activated automatically by `start_writer.sh`
- Manual activation: `source venv/bin/activate`

## Getting Help

If you encounter issues:
1. Check the troubleshooting section above
2. Ensure all dependencies are installed
3. Verify Ollama is running
4. Check your internet connection for cloud models
5. Review the configuration in `config.py`

## License

This project is open source and available under the MIT License.



