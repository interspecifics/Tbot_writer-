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
