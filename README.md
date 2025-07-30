# Text Co-Writer By Interspecifics 

A technical explanation of the AI text co-writing system that helps you continue and expand your creative writing with multiple AI models, unique writer personalities, and customizable elements.

## System Architecture

The Text Co-Writer is built around a modular architecture that combines multiple AI providers, customizable writing styles, and intelligent prompt engineering to create a collaborative writing experience.

### Core Components

1. **Multi-Provider AI Integration**: Supports OpenAI, Ollama (local models), and Hugging Face APIs
2. **Dynamic Model Detection**: Automatically detects available local models and validates API keys
3. **Character-Driven Writing**: Six pre-defined writer personalities with distinct voices and styles
4. **Style System**: Five writing styles with specific instructions for narrative continuation
5. **Reference Material Processing**: Extracts and processes PDF, DOCX, and TXT files for style inspiration
6. **Interactive Command System**: Real-time switching between models, styles, and characters

## How the Co-Writing Process Works

### 1. Prompt Engineering Pipeline

The system constructs sophisticated prompts using multiple layers:

```python
# Core instruction based on writing style
instruction = STYLES.get(style.lower(), STYLES["essay"])

# Character personality and voice
character_description = f"Write with this voice and style:\n"
character_description += f"Personality: {char['personality']}\n"
character_description += f"Interests: {char['interests']}\n"
character_description += f"Style: {char['style']}\n"
character_description += f"Influences: {char['influences']}\n"

# Custom world-building elements
elements_description = "Incorporate these elements naturally:\n"
for element in custom_elements:
    elements_description += f"- {element}: {CUSTOM_ELEMENTS[element]}\n"

# Reference material context (style inspiration only)
reference_context = create_reference_context(reference_materials)

# Continuation-focused instruction
continuation_instruction = "Continue this narrative in the same direction and style. Flow naturally from where it left off."

# Originality protection
originality_instruction = "Write completely original content. Do not copy or paraphrase reference materials."
```

### 2. AI Model Selection and Routing

The system intelligently routes requests to the appropriate AI provider:

- **Local Models (Ollama)**: `neural-chat`, `mistral`, `llama2`, `codellama` - run entirely on your computer
- **Cloud Models (OpenAI)**: `gpt-3.5-turbo-instruct`, `gpt-4` - require API keys
- **Hugging Face Models**: Various models via Hugging Face API

Smart detection ensures only installed local models are shown as options.

### 3. Writer Character System

Six fictional writer personalities, each with unique characteristics:

#### Cyra the Posthumanist
- **Personality**: Radical thinker who dissolves boundaries between species, machines, and matter
- **Style**: Dense yet playful, weaving theory with storytelling
- **Influences**: Donna Haraway, Octavia Butler, feminist science studies

#### Lia the Affective Nomad
- **Personality**: Restless and fluid, believes identity is a constant becoming
- **Style**: Rhythmic and fluid, with philosophical digressions and poetic cadences
- **Influences**: Rosi Braidotti, Deleuze and Guattari, feminist posthuman ethics

#### Dr. Orin
- **Personality**: Philosopher-scientist who sees phenomena as entangled events
- **Style**: Academic and sharp, with speculative and poetic undercurrents
- **Influences**: Karen Barad, quantum physics, feminist STS

#### Fynn
- **Personality**: Analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects
- **Style**: Observational and narrative, blending sociological detail with philosophical humor
- **Influences**: Bruno Latour, anthropology of science, political ecology

#### ArwenDreamer
- **Personality**: Visionary who thrives in hybrid worlds of machines, animals, and spirits
- **Style**: Lyrical and multi-layered, weaving scientific language with myth and dream fragments
- **Influences**: Donna Haraway's 'Chthulucene,' ecofeminist texts

#### IxchelVoice
- **Personality**: Guardian of memory who speaks through rivers, stones, and dreams
- **Style**: Rooted and poetic, blending oral tradition with metaphor
- **Influences**: Mesoamerican cosmologies, Gloria Anzaldúa, Silvia Rivera Cusicanqui

### 4. Writing Style System

Five distinct writing styles with specific continuation instructions:

- **Sci-fi**: Futuristic science fiction with technological elements
- **Peer-review**: Academic, analytical writing style
- **Essay**: Formal reflective essay style
- **Poetry**: Contemporary free verse poetry
- **Journalistic**: New York Times feature article style

### 5. Custom Elements and World-Building

Ten sci-fi world-building elements that can be incorporated:

- `hybrid_plants`: Bio-mechanical plants combining organic growth with technological components
- `mechanical_bees`: Synthetic pollinators with crystalline wings and quantum navigation
- `glacial_memory`: Ancient ice formations storing genetic memories and environmental data
- `permafrost_seeds`: Dormant life forms preserved in frozen soil for thousands of years
- `siren_sounds`: Harmonic frequencies emitted by plants that influence consciousness
- `quantum_ecology`: Ecosystems where quantum entanglement affects species relationships
- `neural_networks`: Living networks of interconnected organisms sharing information
- `time_crystals`: Crystalline structures existing in multiple temporal states simultaneously
- `atmospheric_poetry`: Weather patterns naturally forming into poetic structures
- `memory_moss`: Colonial organisms that absorb and store memories from their environment

### 6. Reference Material Processing

The system processes reference materials for style inspiration only:

```python
def load_reference_materials():
    """Load all reference materials from the reference folder"""
    reference_texts = []
    
    for file_path in glob.glob(f"{REFERENCE_FOLDER}/*"):
        if any(file_path.lower().endswith(ext) for ext in SUPPORTED_FORMATS):
            text = extract_text_from_file(file_path)
            if text:
                reference_texts.append(text)
    
    return reference_texts
```

**Supported Formats**: PDF, DOCX, DOC, TXT
**Purpose**: Style inspiration only - AI is explicitly instructed not to copy content

### 7. Interactive Command System

Real-time commands for dynamic configuration:

- `quit`: Exit the program
- `new style`: Change writing style and custom elements
- `new character`: Change writer character
- `new model`: Change AI model (with API key configuration)
- `reload refs`: Reload reference materials
- `status`: Show current settings
- `help`: Show all available commands

## Technical Implementation Details

### API Integration

The system uses different API clients based on the selected model:

```python
def call_openai_model(prompt, model_name, max_tokens=300, temperature=0.3):
    client = openai.OpenAI(api_key=OPENAI_API_KEY)
    response = client.chat.completions.create(
        model=model_name,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=max_tokens,
        temperature=temperature
    )
    return response.choices[0].message.content

def call_ollama_model(prompt, model_name, max_tokens=300, temperature=0.3):
    response = requests.post(
        f"{OLLAMA_BASE_URL}/api/generate",
        json={
            "model": model_name,
            "prompt": prompt,
            "stream": False,
            "options": {
                "num_predict": max_tokens,
                "temperature": temperature
            }
        }
    )
    return response.json()["response"]
```

### Configuration Management

Dynamic configuration loading with fallback defaults:

```python
try:
    from config import *
    print("📁 Configuration loaded from config.py")
except ImportError:
    print("📁 No config.py found, using default settings")
    OPENAI_API_KEY = ""
    HUGGINGFACE_API_KEY = ""
    OLLAMA_BASE_URL = "http://localhost:11434"
    DEFAULT_MODEL = "neural-chat"
    DEFAULT_STYLE = "sci-fi"
    DEFAULT_CHARACTER = "cyra"
```

### Error Handling and Validation

- **API Key Validation**: Automatic prompting and validation for cloud models
- **Model Availability**: Smart detection of installed local models
- **File Processing**: Graceful handling of unsupported file formats
- **Network Issues**: Timeout handling and fallback options

## Key Design Principles

1. **Continuation-Focused**: Designed to continue existing narratives rather than start new ones
2. **Style Preservation**: Maintains the user's established writing direction and tone
3. **Originality Protection**: Explicit instructions prevent copying of reference materials
4. **Modular Architecture**: Easy to add new models, characters, or styles
5. **User Control**: Real-time switching between different configurations
6. **Privacy-First**: Local models available for completely private writing

## Performance Considerations

- **Token Limits**: Configurable max_tokens (default: 300) for response length
- **Temperature Control**: Adjustable creativity level (default: 0.3)
- **Streaming Support**: Ollama models support streaming responses
- **Caching**: Reference materials are loaded once and cached during session
- **Error Recovery**: Graceful fallbacks when models or APIs are unavailable

This architecture creates a sophisticated yet accessible co-writing system that balances AI assistance with human creative control, providing multiple pathways for collaborative storytelling and creative expression.




