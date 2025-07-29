#!/bin/bash

# GPT Neo-Style Text Co-Writer - macOS Installation Script
# This script automatically installs all dependencies for the text co-writer

set -e  # Exit on any error

echo "🎛 GPT Neo-Style Text Co-Writer - macOS Installation"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is for macOS only. Use install_windows.bat for Windows."
    exit 1
fi

# Check if Homebrew is installed
print_status "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    print_status "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_success "Homebrew installed successfully!"
else
    print_success "Homebrew already installed!"
fi

# Update Homebrew
print_status "Updating Homebrew..."
brew update

# Install Python if not already installed
print_status "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    print_status "Installing Python..."
    brew install python
    print_success "Python installed successfully!"
else
    print_success "Python already installed!"
fi

# Install pip if not already installed
print_status "Checking pip installation..."
if ! command -v pip3 &> /dev/null; then
    print_status "Installing pip..."
    python3 -m ensurepip --upgrade
    print_success "Pip installed successfully!"
else
    print_success "Pip already installed!"
fi

# Install pipx for managing Python applications
print_status "Installing pipx for Python package management..."
if ! command -v pipx &> /dev/null; then
    brew install pipx
    pipx ensurepath
    print_success "Pipx installed successfully!"
else
    print_success "Pipx already installed!"
fi

# Create a virtual environment for the project
print_status "Creating virtual environment for the project..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    print_success "Virtual environment created!"
else
    print_success "Virtual environment already exists!"
fi

# Activate virtual environment and install packages
print_status "Installing Python dependencies in virtual environment..."
source venv/bin/activate
pip install --upgrade pip
pip install openai requests PyPDF2 python-docx

print_success "Python dependencies installed in virtual environment!"

# Install Ollama
print_status "Installing Ollama..."
if ! command -v ollama &> /dev/null; then
    brew install ollama
    print_success "Ollama installed successfully!"
else
    print_success "Ollama already installed!"
fi

# Start Ollama service
print_status "Starting Ollama service..."
brew services start ollama

# Wait a moment for Ollama to start
sleep 3

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
    print_warning "Ollama service might not be running. Starting manually..."
    brew services restart ollama
    sleep 5
fi

# Pull some useful models
print_status "Downloading AI models (this may take a while)..."
echo ""

# Pull neural-chat (smaller, faster model)
print_status "Downloading neural-chat model (4.1GB)..."
ollama pull neural-chat

# Pull mistral (good balance of size and quality)
print_status "Downloading mistral model (4.1GB)..."
ollama pull mistral

# Pull llama2 (larger, higher quality model)
print_status "Downloading llama2 model (3.8GB)..."
ollama pull llama2

print_success "All models downloaded successfully!"

# Create reference materials folder
print_status "Creating reference materials folder..."
mkdir -p reference_materials
print_success "Reference materials folder created: reference_materials/"

# Create a sample reference file
print_status "Creating sample reference material..."
cat > reference_materials/sample_reference.txt << 'EOF'
Sample Reference Material: Ecological Science Fiction

This document serves as a reference for writing in the style of ecological science fiction, combining environmental themes with futuristic elements.

Key Themes:
- The intersection of nature and technology
- Climate change and adaptation
- Bio-mechanical systems
- Environmental consciousness in future societies

Writing Style:
- Descriptive language that emphasizes sensory details
- Scientific terminology mixed with poetic imagery
- Focus on environmental relationships and interconnectedness
- Contemplative tone that reflects on human-nature interactions

Example Passage:
The bio-luminescent forest pulsed with an otherworldly rhythm, each tree a node in a vast neural network that spanned the continent. The ancient mycelium networks, now enhanced with quantum computing capabilities, processed environmental data in ways that transcended human understanding.
EOF

print_success "Sample reference material created!"

# Create a configuration file
print_status "Creating configuration file..."
cat > config.py << 'EOF'
# Configuration file for GPT Neo-Style Text Co-Writer
# You can modify these settings as needed

# API Keys (add your keys here)
OPENAI_API_KEY = "your-openai-api-key-here"  # Get from https://platform.openai.com/api-keys
HUGGINGFACE_API_KEY = "your-huggingface-api-key-here"  # Get from https://huggingface.co/settings/tokens

# Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"

# Default settings
DEFAULT_MODEL = "neural-chat"  # Options: neural-chat, mistral, llama2, gpt-3.5-turbo-instruct
DEFAULT_STYLE = "sci-fi"
DEFAULT_CHARACTER = "cyra"

# Model preferences (uncomment to set defaults)
# PREFERRED_MODELS = ["neural-chat", "mistral", "llama2"]  # Order of preference for local models
EOF

print_success "Configuration file created: config.py"

# Create a quick start script that activates the virtual environment
print_status "Creating quick start script..."
cat > start_writer.sh << 'EOF'
#!/bin/bash
echo "🎛 Starting GPT Neo-Style Text Co-Writer..."
echo "Make sure Ollama is running: brew services start ollama"
echo ""

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "❌ Virtual environment not found. Please run the installation script first."
    exit 1
fi

# Activate virtual environment and run the writer
source venv/bin/activate
python text_co_writer.py
EOF

chmod +x start_writer.sh

# Create a README
print_status "Creating README file..."
cat > README.md << 'EOF'
# GPT Neo-Style Text Co-Writer

A powerful AI text co-writing tool with support for multiple models, writer characters, custom elements, and reference materials.

## Features

- **Multiple AI Models**: OpenAI, Ollama (local), and Hugging Face
- **Writer Characters**: 5 pre-defined fictional writer personalities
- **Custom Elements**: Sci-fi world-building elements
- **Writing Styles**: Sci-fi, academic, poetry, journalistic, and more
- **Reference Materials**: Support for PDF, DOCX, and TXT files (style inspiration only)
- **Narrative Continuation**: Continues your story in the same direction
- **Continuous Operation**: Keep writing without restarting
- **Numbered Selection**: Easy model and character selection by number

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

1. **Cyra the Posthumanist**: Radical thinker who dissolves boundaries between species, machines, and matter
2. **Lia the Affective Nomad**: Restless and fluid, believes identity is a constant becoming
3. **Dr. Orin**: Philosopher-scientist who sees phenomena as entangled events
4. **Fynn**: Analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects
5. **ArwenDreamer**: Visionary who thrives in hybrid worlds of machines, animals, and spirits

## Custom Elements

Include sci-fi elements like:
- hybrid_plants, mechanical_bees, glacial_memory
- permafrost_seeds, siren_sounds, quantum_ecology
- neural_networks, time_crystals, atmospheric_poetry

## Reference Materials

Add your own reference materials to the `reference_materials/` folder:
- **PDF files** (.pdf) - Research papers, books, articles
- **Word documents** (.docx, .doc) - Manuscripts, notes
- **Text files** (.txt) - Any plain text content

The AI will use these as **style inspiration only** - it won't copy content but will adopt the writing style and approach.

## Configuration

Edit `config.py` to set your API keys and preferences.

## Commands

- `quit`: Exit the program
- `new style`: Change writing style and elements
- `new character`: Change writer character (numbered selection available)
- `new model`: Switch to different AI model (numbered selection available)
- `reload refs`: Reload reference materials

## Troubleshooting

1. **Ollama not running**: `brew services start ollama`
2. **Model not found**: `ollama pull model-name`
3. **API errors**: Check your API keys in config.py
4. **Virtual environment issues**: Run `source venv/bin/activate` before running the script
5. **Reference materials not loading**: Check file formats (PDF, DOCX, TXT only)
6. **AI copying reference content**: Reference materials are for style inspiration only

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

## Dependencies

- **openai**: OpenAI API client
- **requests**: HTTP library
- **PyPDF2**: PDF text extraction
- **python-docx**: Word document text extraction
EOF

print_success "README.md created!"

# Final instructions
echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
print_success "Your GPT Neo-Style Text Co-Writer is ready to use!"
echo ""
echo "Next steps:"
echo "1. Edit config.py to add your API keys (optional)"
echo "2. Start Ollama: brew services start ollama"
echo "3. Run the writer: ./start_writer.sh"
echo "4. Add reference materials to the reference_materials/ folder"
echo ""
echo "Available models:"
ollama list
echo ""
print_success "Happy writing! 🚀"
echo ""
echo "Note: This project uses a virtual environment to avoid Python package conflicts."
echo "The start_writer.sh script will automatically activate it for you."
echo ""
echo "Reference materials folder created: reference_materials/"
echo "Add your PDF, DOCX, or TXT files there for style and content inspiration!" 