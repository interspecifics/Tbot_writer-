# Configuration file for GPT Neo-Style Text Co-Writer
# You can modify these settings as needed

# API Keys (add your keys here)
OPENAI_API_KEY = ""  # Get from https://platform.openai.com/api-keys
HUGGINGFACE_API_KEY = "your-huggingface-api-key-here"  # Get from https://huggingface.co/settings/tokens

# Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"

# Default settings
DEFAULT_MODEL = "neural-chat"  # Options: neural-chat, mistral, llama2, gpt-3.5-turbo-instruct
DEFAULT_STYLE = "sci-fi"
DEFAULT_CHARACTER = "cyra"

# Model preferences (uncomment to set defaults)
# PREFERRED_MODELS = ["neural-chat", "mistral", "llama2"]  # Order of preference for local models
