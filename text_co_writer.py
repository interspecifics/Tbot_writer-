import openai
import requests
import json
import os
from typing import Optional
import glob
from pathlib import Path

# Try to load configuration from config.py
try:
    from config import *
    print("📁 Configuration loaded from config.py")
except ImportError:
    print("📁 No config.py found, using default settings")
    # Default configuration
    OPENAI_API_KEY = ""
    HUGGINGFACE_API_KEY = ""  # Add your Hugging Face API key here
    OLLAMA_BASE_URL = "http://localhost:11434"  # Default Ollama URL
    DEFAULT_MODEL = "neural-chat"
    DEFAULT_STYLE = "sci-fi"
    DEFAULT_CHARACTER = "cyra"

# Reference materials configuration
REFERENCE_FOLDER = "reference_materials"
SUPPORTED_FORMATS = ['.pdf', '.docx', '.doc', '.txt']

# Available models
MODELS = {
    "openai": {
        "gpt-3.5-turbo-instruct": {
            "provider": "openai",
            "description": "OpenAI's GPT-3.5 Turbo Instruct model",
            "requires_key": True
        },
        "gpt-4": {
            "provider": "openai", 
            "description": "OpenAI's GPT-4 model",
            "requires_key": True
        }
    },
    "ollama": {
        "llama2": {
            "provider": "ollama",
            "description": "Meta's Llama 2 model (7B parameters)",
            "requires_key": False
        },
        "mistral": {
            "provider": "ollama",
            "description": "Mistral AI's 7B model",
            "requires_key": False
        },
        "codellama": {
            "provider": "ollama",
            "description": "Code-optimized Llama model",
            "requires_key": False
        },
        "neural-chat": {
            "provider": "ollama",
            "description": "Intel's Neural Chat model",
            "requires_key": False
        }
    },
    "huggingface": {
        "meta-llama/Llama-2-7b-chat-hf": {
            "provider": "huggingface",
            "description": "Llama 2 7B Chat on Hugging Face",
            "requires_key": True
        },
        "microsoft/DialoGPT-medium": {
            "provider": "huggingface",
            "description": "Microsoft's DialoGPT medium model",
            "requires_key": True
        }
    }
}

# Create OpenAI client
openai_client = openai.OpenAI(api_key=OPENAI_API_KEY)

STYLES = {
    "sci-fi": "Continue in a futuristic science fiction style, maintaining the narrative flow.",
    "peer-review": "Continue in an academic peer-reviewed style, maintaining the analytical flow.",
    "essay": "Continue in a formal reflective essay style, maintaining the narrative thread.",
    "poetry": "Continue in contemporary free verse poetry style, maintaining the poetic flow.",
    "journalistic": "Continue in a New York Times feature article style, maintaining the narrative direction.",
}

# Custom elements and world-building descriptions
CUSTOM_ELEMENTS = {
    "hybrid_plants": "Bio-mechanical plants that combine organic growth with technological components, capable of photosynthesis and data processing simultaneously.",
    "mechanical_bees": "Synthetic pollinators with crystalline wings and quantum navigation systems, maintaining ecosystem balance in artificial environments.",
    "glacial_memory": "Ancient ice formations that store genetic memories and environmental data from millennia past, slowly releasing information as they melt.",
    "permafrost_seeds": "Dormant life forms preserved in frozen soil for thousands of years, awakening with unique adaptations to modern conditions.",
    "siren_sounds": "Harmonic frequencies emitted by certain plants that can influence human consciousness and environmental patterns.",
    "quantum_ecology": "Ecosystems where quantum entanglement affects species relationships and environmental interactions across vast distances.",
    "neural_networks": "Living networks of interconnected organisms that share information and coordinate responses like a biological internet.",
    "time_crystals": "Crystalline structures that exist in multiple temporal states simultaneously, allowing access to past and future environmental conditions.",
    "atmospheric_poetry": "Weather patterns that naturally form into poetic structures, with clouds and wind creating visible verses in the sky.",
    "memory_moss": "Colonial organisms that absorb and store memories from their environment, growing more complex patterns as they accumulate experiences."
}

# Pre-defined writer characters
WRITER_CHARACTERS = {
    "cyra": {
        "name": "Cyra the Posthumanist",
        "personality": "A radical thinker who dissolves boundaries between species, machines, and matter. Curious, provocative, and deeply empathetic.",
        "interests": "Cyborg theory, multispecies storytelling, speculative feminism, and the ethics of technology.",
        "style": "Dense yet playful, weaving theory with storytelling, often blurring the line between fact and fiction.",
        "influences": "Donna Haraway, Octavia Butler, feminist science studies, and speculative fabulation."
    },
    "lia": {
        "name": "Lia the Affective Nomad",
        "personality": "Restless and fluid, she believes identity is a constant becoming. Her tone is passionate and philosophical.",
        "interests": "Nomadic ethics, affect theory, the politics of desire, and feminist cartographies of knowledge.",
        "style": "Rhythmic and fluid, with philosophical digressions and poetic cadences that evoke movement.",
        "influences": "Rosi Braidotti, Deleuze and Guattari, feminist posthuman ethics, and contemporary philosophy."
    },
    "dr_orin": {
        "name": "Dr. Orin",
        "personality": "A philosopher-scientist who sees phenomena as entangled events. Speaks with precision but hints at the poetic in every measurement.",
        "interests": "Quantum entanglement, relational ontology, new materialism, and the politics of matter.",
        "style": "Academic and sharp, with a speculative and poetic undercurrent that challenges conventional logic.",
        "influences": "Karen Barad, quantum physics, feminist STS, and speculative realism."
    },
    "fynn": {
        "name": "Fynn",
        "personality": "An analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects.",
        "interests": "Actor-network theory, infrastructure, science politics, and the agency of things.",
        "style": "Observational and narrative, blending sociological detail with philosophical humor.",
        "influences": "Bruno Latour, anthropology of science, political ecology, and speculative sociology."
    },
    "arwen": {
        "name": "ArwenDreamer",
        "personality": "A visionary who thrives in hybrid worlds of machines, animals, and spirits. Speaks as if everything is alive and conversing.",
        "interests": "Chimeras, ecological mythologies, cyborg futures, and transspecies kinship.",
        "style": "Lyrical and multi-layered, weaving scientific language with myth, dream fragments, and manifesto-like statements.",
        "influences": "Donna Haraway’s ‘Chthulucene,’ ecofeminist texts, and posthuman narrative practices."
    }
}

def extract_text_from_pdf(file_path):
    """Extract text from PDF files"""
    try:
        import PyPDF2
        with open(file_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text() + "\n"
            return text.strip()
    except ImportError:
        print("PyPDF2 not installed. Install with: pip install PyPDF2")
        return ""
    except Exception as e:
        print(f"Error reading PDF {file_path}: {e}")
        return ""

def extract_text_from_docx(file_path):
    """Extract text from Word documents"""
    try:
        from docx import Document
        doc = Document(file_path)
        text = ""
        for paragraph in doc.paragraphs:
            text += paragraph.text + "\n"
        return text.strip()
    except ImportError:
        print("python-docx not installed. Install with: pip install python-docx")
        return ""
    except Exception as e:
        print(f"Error reading DOCX {file_path}: {e}")
        return ""

def extract_text_from_txt(file_path):
    """Extract text from plain text files"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read().strip()
    except Exception as e:
        print(f"Error reading TXT {file_path}: {e}")
        return ""

def load_reference_materials():
    """Load all reference materials from the reference folder"""
    reference_texts = []
    
    # Create reference folder if it doesn't exist
    if not os.path.exists(REFERENCE_FOLDER):
        os.makedirs(REFERENCE_FOLDER)
        print(f"Created reference materials folder: {REFERENCE_FOLDER}")
        print("Add your PDF, DOCX, or TXT files to this folder for reference.")
        return reference_texts
    
    # Get all supported files
    for file_path in glob.glob(os.path.join(REFERENCE_FOLDER, "*.*")):
        file_ext = os.path.splitext(file_path)[1].lower()
        if file_ext in SUPPORTED_FORMATS:
            print(f"Loading reference material: {os.path.basename(file_path)}")
            
            if file_ext == '.pdf':
                text = extract_text_from_pdf(file_path)
            elif file_ext in ['.docx', '.doc']:
                text = extract_text_from_docx(file_path)
            elif file_ext == '.txt':
                text = extract_text_from_txt(file_path)
            else:
                continue
            
            if text:
                reference_texts.append({
                    'filename': os.path.basename(file_path),
                    'content': text[:2000]  # Limit to first 2000 characters per file
                })
    
    return reference_texts

def create_reference_context(reference_materials):
    """Create context from reference materials"""
    if not reference_materials:
        return ""
    
    context = "\n\nReference Materials (use as STYLE inspiration only, do NOT copy content):\n"
    context += "=" * 60 + "\n"
    context += "IMPORTANT: Use these materials for writing style, tone, and approach inspiration only.\n"
    context += "Do NOT copy, paraphrase, or directly reference any content from these materials.\n"
    context += "Create your own original continuation based on the user's prompt.\n\n"
    
    for ref in reference_materials:
        context += f"\n--- Style reference from {ref['filename']} ---\n"
        context += f"Writing approach: {ref['content'][:500]}...\n"
    
    context += "\nUse the above styles as inspiration for your own original writing.\n"
    return context

def call_openai_model(prompt, model_name, max_tokens=300, temperature=0.3):
    """Call OpenAI models"""
    try:
        response = openai_client.completions.create(
            model=model_name,
            prompt=prompt,
            max_tokens=max_tokens,
            temperature=temperature,
            top_p=0.9,
            frequency_penalty=0.1,
            presence_penalty=0.0,
        )
        return response.choices[0].text.strip()
    except Exception as e:
        raise Exception(f"OpenAI API error: {e}")

def call_ollama_model(prompt, model_name, max_tokens=300, temperature=0.3):
    """Call Ollama models"""
    try:
        url = f"{OLLAMA_BASE_URL}/api/generate"
        payload = {
            "model": model_name,
            "prompt": prompt,
            "stream": False,
            "options": {
                "num_predict": max_tokens,
                "temperature": temperature,
                "top_p": 0.9,
                "repeat_penalty": 1.1
            }
        }
        
        response = requests.post(url, json=payload, timeout=60)
        response.raise_for_status()
        
        result = response.json()
        return result.get("response", "").strip()
    except Exception as e:
        raise Exception(f"Ollama API error: {e}")

def call_huggingface_model(prompt, model_name, max_tokens=300, temperature=0.3):
    """Call Hugging Face models"""
    try:
        url = f"https://api-inference.huggingface.co/models/{model_name}"
        headers = {"Authorization": f"Bearer {HUGGINGFACE_API_KEY}"}
        payload = {
            "inputs": prompt,
            "parameters": {
                "max_new_tokens": max_tokens,
                "temperature": temperature,
                "top_p": 0.9,
                "do_sample": True
            }
        }
        
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()
        
        result = response.json()
        if isinstance(result, list) and len(result) > 0:
            return result[0].get("generated_text", "").strip()
        else:
            return str(result).strip()
    except Exception as e:
        raise Exception(f"Hugging Face API error: {e}")

def co_write(prompt, style, custom_elements=None, writer_character=None, model_name=DEFAULT_MODEL, reference_materials=None):
    instruction = STYLES.get(style.lower(), STYLES["essay"])
    
    # Build writer character description if provided - but don't mention the character name
    character_description = ""
    if writer_character and writer_character in WRITER_CHARACTERS:
        char = WRITER_CHARACTERS[writer_character]
        character_description = f"\n\nWrite with this voice and style:\n"
        character_description += f"Personality: {char['personality']}\n"
        character_description += f"Interests: {char['interests']}\n"
        character_description += f"Style: {char['style']}\n"
        character_description += f"Influences: {char['influences']}\n"
        character_description += f"\nImportant: Continue the narrative flow naturally. Do not include any titles, character names, or meta-references in your response. Write directly in this voice without mentioning who is writing."
    
    # Build custom elements description if provided
    elements_description = ""
    if custom_elements:
        elements_description = "\n\nIncorporate these elements naturally:\n"
        for element in custom_elements:
            if element in CUSTOM_ELEMENTS:
                elements_description += f"- {element}: {CUSTOM_ELEMENTS[element]}\n"
    
    # Build reference materials context if provided
    reference_context = ""
    if reference_materials:
        reference_context = create_reference_context(reference_materials)
    
    # Create a continuation-focused prompt
    continuation_instruction = "\n\nContinue this narrative in the same direction and style. Flow naturally from where it left off. Do not start a new story or change the narrative direction. Simply continue the existing narrative thread."
    
    # Add instruction to avoid copying reference material
    originality_instruction = "\n\nCRITICAL: Write completely original content. Do not copy, paraphrase, or directly reference any content from reference materials. Use reference materials only for style inspiration. Create your own unique continuation based on the user's prompt."
    
    # Make the prompt focus on continuation rather than complete story creation
    full_prompt = f"{instruction}{character_description}{elements_description}{reference_context}{continuation_instruction}{originality_instruction}\n\nContinue from here: {prompt}"
    
    # Find the model provider
    model_provider = None
    for provider, models in MODELS.items():
        if model_name in models:
            model_provider = models[model_name]["provider"]
            break
    
    if not model_provider:
        raise Exception(f"Model {model_name} not found")
    
    # Call the appropriate API based on provider
    if model_provider == "openai":
        return call_openai_model(full_prompt, model_name)
    elif model_provider == "ollama":
        return call_ollama_model(full_prompt, model_name)
    elif model_provider == "huggingface":
        return call_huggingface_model(full_prompt, model_name)
    else:
        raise Exception(f"Unknown provider: {model_provider}")

def list_available_models():
    """List all available models grouped by provider with numbers"""
    print("\n" + "="*60)
    print("AVAILABLE MODELS")
    print("="*60)
    
    all_models = {}
    model_counter = 1
    
    for provider, models in MODELS.items():
        print(f"\n{provider.upper()} MODELS:")
        print("-" * 30)
        for model_name, model_info in models.items():
            key_required = "🔑" if model_info["requires_key"] else "✅"
            print(f"{model_counter:2d}. {key_required} {model_name}")
            print(f"     {model_info['description']}")
            all_models[model_counter] = model_name
            model_counter += 1
        print()
    
    return all_models

def get_model_by_number(all_models, user_input):
    """Get model name by number or return the input if it's a model name"""
    try:
        # Try to convert to number
        number = int(user_input)
        if number in all_models:
            return all_models[number]
        else:
            print(f"Invalid model number: {number}")
            return None
    except ValueError:
        # If not a number, treat as model name
        return user_input

def get_character_by_number(all_characters, user_input):
    """Get character key by number or return the input if it's a character name/key"""
    try:
        # Try to convert to number
        number = int(user_input)
        if number in all_characters:
            return all_characters[number]
        else:
            print(f"Invalid character number: {number}")
            return None
    except ValueError:
        # If not a number, treat as character name/key
        return user_input

def list_available_characters():
    """List all available characters with numbers"""
    print("\n" + "="*60)
    print("AVAILABLE WRITER CHARACTERS")
    print("="*60)
    
    all_characters = {}
    character_counter = 1
    
    for key, char in WRITER_CHARACTERS.items():
        print(f"{character_counter:2d}. {char['name']}")
        print(f"     {char['personality'][:80]}...")
        all_characters[character_counter] = key
        character_counter += 1
    
    print()
    return all_characters

def list_reference_materials():
    """List all available reference materials"""
    print("\n" + "="*60)
    print("REFERENCE MATERIALS")
    print("="*60)
    
    if not os.path.exists(REFERENCE_FOLDER):
        print(f"No reference folder found. Creating: {REFERENCE_FOLDER}")
        os.makedirs(REFERENCE_FOLDER)
        print("Add your PDF, DOCX, or TXT files to this folder for reference.")
        return
    
    files = glob.glob(os.path.join(REFERENCE_FOLDER, "*.*"))
    supported_files = [f for f in files if os.path.splitext(f)[1].lower() in SUPPORTED_FORMATS]
    
    if not supported_files:
        print("No reference materials found.")
        print(f"Add PDF, DOCX, or TXT files to the '{REFERENCE_FOLDER}' folder.")
        return
    
    print(f"Found {len(supported_files)} reference material(s):")
    for i, file_path in enumerate(supported_files, 1):
        filename = os.path.basename(file_path)
        file_size = os.path.getsize(file_path)
        print(f"{i}. {filename} ({file_size:,} bytes)")

if __name__ == "__main__":
    print("🎛 GPT Neo-Style Text Co-Writer")
    print("Available styles:", ", ".join(STYLES.keys()))
    
    # Show available models with numbers
    all_models = list_available_models()
    
    # Show reference materials
    list_reference_materials()
    
    # Load reference materials
    reference_materials = load_reference_materials()
    
    # Get initial configuration
    style = input(f"\nChoose a style (default: {DEFAULT_STYLE}): ").strip() or DEFAULT_STYLE
    
    # Get model selection
    print(f"\nChoose a model (enter number or name, default: {DEFAULT_MODEL}):")
    model_input = input().strip() or DEFAULT_MODEL
    model_name = get_model_by_number(all_models, model_input)
    if not model_name:
        model_name = DEFAULT_MODEL
        print(f"Using default model: {DEFAULT_MODEL}")
    else:
        print(f"Selected model: {model_name}")
    
    # Get writer character
    all_characters = list_available_characters()
    print(f"Choose a writer character (enter number or name, default: {DEFAULT_CHARACTER}):")
    character_input = input().strip() or DEFAULT_CHARACTER
    writer_character = get_character_by_number(all_characters, character_input)
    if not writer_character:
        writer_character = DEFAULT_CHARACTER
        print(f"Using default character: {DEFAULT_CHARACTER}")
    else:
        char = WRITER_CHARACTERS[writer_character]
        print(f"Selected: {char['name']}")
    
    # Get custom elements
    print("\nEnter custom elements to include (comma-separated, or press Enter for none):")
    elements_input = input().strip()
    custom_elements = []
    if elements_input:
        custom_elements = [elem.strip() for elem in elements_input.split(",")]
    
    print("\n" + "="*50)
    print(f"Ready for prompts! Using model: {model_name}")
    if reference_materials:
        print(f"Loaded {len(reference_materials)} reference material(s)")
    print("Type 'quit' to exit, 'new style' to change style/elements, 'new character' to change character, 'new model' to change model, 'reload refs' to reload reference materials")
    print("="*50)
    
    while True:
        print("\n" + "-"*30)
        prompt = input("Enter your prompt: ").strip()
        
        if prompt.lower() == 'quit':
            print("Goodbye! 👋")
            break
        elif prompt.lower() == 'new style':
            print("\n" + "="*30)
            print("CHANGING STYLE AND ELEMENTS")
            print("="*30)
            style = input("Choose a new style: ").strip()
            print("\nEnter custom elements to include (comma-separated, or press Enter for none):")
            elements_input = input().strip()
            custom_elements = []
            if elements_input:
                custom_elements = [elem.strip() for elem in elements_input.split(",")]
            print("Style and elements updated!")
            continue
        elif prompt.lower() == 'new character':
            print("\n" + "="*30)
            print("CHANGING WRITER CHARACTER")
            print("="*30)
            all_characters = list_available_characters()
            print("Choose a writer character (enter number or name):")
            character_input = input().strip()
            new_character = get_character_by_number(all_characters, character_input)
            if new_character:
                writer_character = new_character
                char = WRITER_CHARACTERS[writer_character]
                print(f"Character updated to: {char['name']}")
            else:
                print("Invalid character selection. Keeping current character.")
            continue
        elif prompt.lower() == 'new model':
            print("\n" + "="*30)
            print("CHANGING MODEL")
            print("="*30)
            all_models = list_available_models()
            print("Choose a new model (enter number or name):")
            model_input = input().strip()
            new_model = get_model_by_number(all_models, model_input)
            if new_model:
                model_name = new_model
                print(f"Model updated to: {model_name}")
            else:
                print("Invalid model selection. Keeping current model.")
            continue
        elif prompt.lower() == 'reload refs':
            print("\n" + "="*30)
            print("RELOADING REFERENCE MATERIALS")
            print("="*30)
            reference_materials = load_reference_materials()
            print(f"Reloaded {len(reference_materials)} reference material(s)")
            continue
        elif not prompt:
            print("Please enter a prompt or type 'quit' to exit.")
            continue
        
        try:
            continuation = co_write(prompt, style, custom_elements, writer_character, model_name, reference_materials)
            print("\n📝 AI Continuation:\n")
            print(continuation)
        except Exception as e:
            print(f"\n❌ Error: {e}")
            print("Please try again.")