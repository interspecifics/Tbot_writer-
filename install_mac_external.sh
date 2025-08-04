#!/bin/bash

# Text Co-Writer External Drive Installation Script for macOS
# This script installs the program on an external hard drive

set -e  # Exit on any error

echo "🎛 Text Co-Writer External Drive Installation"
echo "=============================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Function to check if a drive is external
is_external_drive() {
    local drive_path="$1"
    local drive_info=$(diskutil info "$drive_path" 2>/dev/null | grep "Protocol:" | awk '{print $2}')
    [[ "$drive_info" == "USB" || "$drive_info" == "FireWire" || "$drive_info" == "Thunderbolt" ]]
}

# Function to get available external drives
get_external_drives() {
    local drives=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            drives+=("$line")
        fi
    done < <(ls /Volumes/ | grep -v "Macintosh HD" | grep -v "com.apple" | grep -v "Time Machine")
    echo "${drives[@]}"
}

# Function to check drive space
check_drive_space() {
    local drive_path="$1"
    local required_space=10000  # 10GB in MB
    local available_space=$(df "$drive_path" | awk 'NR==2 {print $4}')
    local available_gb=$((available_space / 1024))
    
    if [[ $available_gb -lt 10 ]]; then
        echo "❌ Not enough space on $drive_path. Need at least 10GB, available: ${available_gb}GB"
        return 1
    fi
    
    echo "✅ Available space: ${available_gb}GB"
    return 0
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "✅ Homebrew already installed"
    fi
}

# Function to install Python if not present
install_python() {
    if ! command -v python3 &> /dev/null; then
        echo "🐍 Installing Python..."
        brew install python
    else
        echo "✅ Python already installed"
    fi
}

# Function to install Ollama
install_ollama() {
    if ! command -v ollama &> /dev/null; then
        echo "🤖 Installing Ollama..."
        brew install ollama
    else
        echo "✅ Ollama already installed"
    fi
}

# Function to configure Ollama for external drive
configure_ollama_external() {
    local install_path="$1"
    local ollama_dir="$install_path/ollama"
    
    echo "🔧 Configuring Ollama for external drive..."
    
    # Create Ollama directory on external drive
    mkdir -p "$ollama_dir"
    
    # Set OLLAMA_MODELS environment variable
    echo "export OLLAMA_MODELS=$ollama_dir" >> ~/.zshrc
    echo "export OLLAMA_MODELS=$ollama_dir" >> ~/.bash_profile
    
    # Create a symlink to the external Ollama directory
    if [[ ! -L ~/.ollama ]]; then
        if [[ -d ~/.ollama ]]; then
            echo "⚠️  Moving existing Ollama data to external drive..."
            mv ~/.ollama/* "$ollama_dir/" 2>/dev/null || true
            rmdir ~/.ollama
        fi
        ln -s "$ollama_dir" ~/.ollama
    fi
    
    echo "✅ Ollama configured to use external drive: $ollama_dir"
}

# Function to create virtual environment on external drive
create_venv_external() {
    local install_path="$1"
    local venv_path="$install_path/venv"
    
    echo "🐍 Creating Python virtual environment on external drive..."
    
    if [[ -d "$venv_path" ]]; then
        echo "⚠️  Virtual environment already exists, removing..."
        rm -rf "$venv_path"
    fi
    
    python3 -m venv "$venv_path"
    
    # Activate virtual environment and install packages
    source "$venv_path/bin/activate"
    pip install --upgrade pip
    
    echo "📦 Installing Python packages..."
    pip install openai requests PyPDF2 python-docx
    
    echo "✅ Virtual environment created at: $venv_path"
}

# Function to download AI models
download_models() {
    echo "🤖 Downloading AI models to external drive..."
    
    # Start Ollama service
    brew services start ollama
    
    # Wait for Ollama to be ready
    echo "⏳ Waiting for Ollama to start..."
    sleep 5
    
    # Download models
    echo "📥 Downloading neural-chat model (4.1GB)..."
    ollama pull neural-chat
    
    echo "📥 Downloading mistral model (4.1GB)..."
    ollama pull mistral
    
    echo "📥 Downloading llama2 model (3.8GB)..."
    ollama pull llama2
    
    echo "✅ All models downloaded to external drive"
}

# Function to create configuration files
create_config_files() {
    local install_path="$1"
    
    echo "⚙️  Creating configuration files..."
    
    # Create config.py
    cat > "$install_path/config.py" << 'EOF'
# Configuration file for GPT Neo-Style Text Co-Writer
# You can modify these settings as needed

# API Keys (add your keys here)
OPENAI_API_KEY = ""  # Get from https://platform.openai.com/api-keys
HUGGINGFACE_API_KEY = ""  # Get from https://huggingface.co/settings/tokens

# Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"

# Default settings
DEFAULT_MODEL = "neural-chat"  # Options: neural-chat, mistral, llama2, gpt-3.5-turbo-instruct
DEFAULT_STYLE = "sci-fi"
DEFAULT_CHARACTER = "cyra"

# Model preferences (uncomment to set defaults)
# PREFERRED_MODELS = ["neural-chat", "mistral", "llama2"]  # Order of preference for local models
EOF

    # Create requirements.txt
    cat > "$install_path/requirements.txt" << 'EOF'
openai
requests
PyPDF2
python-docx
EOF

    echo "✅ Configuration files created"
}

# Function to create startup script for external drive
create_startup_script() {
    local install_path="$1"
    
    echo "🚀 Creating startup script..."
    
    cat > "$install_path/start_writer_external.sh" << EOF
#!/bin/bash

# Text Co-Writer Startup Script for External Drive Installation

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "\$SCRIPT_DIR"

# Check if external drive is mounted
if [[ ! -d "\$SCRIPT_DIR" ]]; then
    echo "❌ Error: External drive not found. Please ensure the drive is mounted."
    exit 1
fi

# Check if virtual environment exists
if [[ ! -d "\$SCRIPT_DIR/venv" ]]; then
    echo "❌ Error: Virtual environment not found. Please run the installation script again."
    exit 1
fi

# Activate virtual environment
echo "🐍 Activating virtual environment..."
source "\$SCRIPT_DIR/venv/bin/activate"

# Check if Ollama is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "🤖 Starting Ollama..."
    brew services start ollama
    sleep 3
fi

# Run the text co-writer
echo "🎛 Starting Text Co-Writer..."
python "\$SCRIPT_DIR/text_co_writer.py"
EOF

    chmod +x "$install_path/start_writer_external.sh"
    echo "✅ Startup script created: $install_path/start_writer_external.sh"
}

# Function to create desktop shortcut
create_desktop_shortcut() {
    local install_path="$1"
    
    echo "🖥️  Creating desktop shortcut..."
    
    cat > ~/Desktop/Text-Co-Writer.command << EOF
#!/bin/bash

# Text Co-Writer Desktop Shortcut

# Check if external drive is mounted
if [[ ! -d "$install_path" ]]; then
    echo "❌ External drive not found. Please ensure the drive is mounted."
    echo "Expected path: $install_path"
    echo ""
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

# Run the startup script
"$install_path/start_writer_external.sh"
EOF

    chmod +x ~/Desktop/Text-Co-Writer.command
    echo "✅ Desktop shortcut created: ~/Desktop/Text-Co-Writer.command"
}

# Main installation process
main() {
    echo "🔍 Detecting external drives..."
    
    # Get available external drives
    external_drives=($(get_external_drives))
    
    if [[ ${#external_drives[@]} -eq 0 ]]; then
        echo "❌ No external drives found. Please connect an external drive and try again."
        exit 1
    fi
    
    echo "📁 Available external drives:"
    for i in "${!external_drives[@]}"; do
        echo "  $((i+1)). /Volumes/${external_drives[$i]}"
    done
    
    echo ""
    read -p "Select drive number (1-${#external_drives[@]}): " drive_choice
    
    if [[ ! "$drive_choice" =~ ^[0-9]+$ ]] || [[ "$drive_choice" -lt 1 ]] || [[ "$drive_choice" -gt ${#external_drives[@]} ]]; then
        echo "❌ Invalid selection"
        exit 1
    fi
    
    selected_drive="${external_drives[$((drive_choice-1))]}"
    install_path="/Volumes/$selected_drive/text_co_writer"
    
    echo ""
    echo "🎯 Selected drive: /Volumes/$selected_drive"
    echo "📂 Installation path: $install_path"
    echo ""
    
    # Check drive space
    echo "💾 Checking available space..."
    if ! check_drive_space "/Volumes/$selected_drive"; then
        exit 1
    fi
    
    # Confirm installation
    echo ""
    read -p "Proceed with installation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Installation cancelled"
        exit 0
    fi
    
    echo ""
    echo "🚀 Starting installation..."
    echo ""
    
    # Create installation directory
    echo "📁 Creating installation directory..."
    mkdir -p "$install_path"
    
    # Install dependencies
    install_homebrew
    install_python
    install_ollama
    
    # Configure for external drive
    configure_ollama_external "$install_path"
    create_venv_external "$install_path"
    
    # Copy program files
    echo "📋 Copying program files..."
    cp text_co_writer.py "$install_path/"
    cp characters.txt "$install_path/"
    cp custom_elements.txt "$install_path/"
    cp requirements.txt "$install_path/"
    
    # Create reference materials directory
    mkdir -p "$install_path/reference_materials"
    if [[ -d "reference_materials" ]]; then
        cp -r reference_materials/* "$install_path/reference_materials/" 2>/dev/null || true
    fi
    
    # Create configuration files
    create_config_files "$install_path"
    
    # Download models
    download_models
    
    # Create startup script
    create_startup_script "$install_path"
    
    # Create desktop shortcut
    create_desktop_shortcut "$install_path"
    
    echo ""
    echo "🎉 Installation complete!"
    echo "=============================================="
    echo "📂 Installation location: $install_path"
    echo "🤖 Models location: $install_path/ollama"
    echo "🐍 Virtual environment: $install_path/venv"
    echo "🚀 Startup script: $install_path/start_writer_external.sh"
    echo "🖥️  Desktop shortcut: ~/Desktop/Text-Co-Writer.command"
    echo ""
    echo "📋 Next steps:"
    echo "1. Double-click the 'Text-Co-Writer' icon on your desktop"
    echo "2. Or run: $install_path/start_writer_external.sh"
    echo "3. Make sure the external drive is mounted before running"
    echo ""
    echo "⚠️  Important: Keep the external drive connected when using the program"
    echo "   All models and data are stored on the external drive"
}

# Run main function
main "$@" 