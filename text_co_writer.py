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

# Configuration files for characters and elements
CHARACTERS_FILE = "characters.txt"
CUSTOM_ELEMENTS_FILE = "custom_elements.txt"

def load_characters_from_file():
    """Load writer characters from external text file"""
    characters = {}
    
    # Default characters if file doesn't exist
    default_characters = {
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
            "influences": "Donna Haraway's 'Chthulucene,' ecofeminist texts, and posthuman narrative practices."
        },
        "ixchel_voice": {
            "name": "IxchelVoice",
            "personality": "A guardian of memory who speaks through rivers, stones, and dreams. Grounded and luminous, she listens more than she speaks, but when she speaks, her words are medicine.",
            "interests": "Ancestral technologies, ceremonial time, land-body reciprocity, and the resistance of stories passed through generations.",
            "style": "Rooted and poetic, blending oral tradition with metaphor, often addressing the reader as kin or spirit. Her language spirals—never linear, always relational.",
            "influences": "Mesoamerican cosmologies, oral narratives, Gloria Anzaldúa's borderlands, Silvia Rivera Cusicanqui, and the living intelligence of the land."
        }
    }
    
    try:
        if not os.path.exists(CHARACTERS_FILE):
            # Create default characters file
            create_default_characters_file(default_characters)
            print(f"Created default characters file: {CHARACTERS_FILE}")
            return default_characters
        
        with open(CHARACTERS_FILE, 'r', encoding='utf-8') as file:
            content = file.read().strip()
            
        if not content:
            print(f"Characters file {CHARACTERS_FILE} is empty, using defaults")
            return default_characters
            
        # Parse the file content
        characters = parse_characters_file(content)
        
        if not characters:
            print(f"Could not parse characters from {CHARACTERS_FILE}, using defaults")
            return default_characters
            
        print(f"Loaded {len(characters)} characters from {CHARACTERS_FILE}")
        return characters
        
    except Exception as e:
        print(f"Error loading characters from {CHARACTERS_FILE}: {e}")
        print("Using default characters")
        return default_characters

def create_default_characters_file(default_characters):
    """Create the default characters file"""
    content = """# Writer Characters Configuration File
# Format: [CHARACTER_NAME]
# name: Display Name
# personality: Character personality description
# interests: Character interests and focus areas
# style: Writing style description
# influences: Influences and inspirations
# 
# Add your own characters below or modify existing ones
# Each character should be separated by [CHARACTER_NAME] on a new line

[cyra]
name: Cyra the Posthumanist
personality: A radical thinker who dissolves boundaries between species, machines, and matter. Curious, provocative, and deeply empathetic.
interests: Cyborg theory, multispecies storytelling, speculative feminism, and the ethics of technology.
style: Dense yet playful, weaving theory with storytelling, often blurring the line between fact and fiction.
influences: Donna Haraway, Octavia Butler, feminist science studies, and speculative fabulation.

[lia]
name: Lia the Affective Nomad
personality: Restless and fluid, she believes identity is a constant becoming. Her tone is passionate and philosophical.
interests: Nomadic ethics, affect theory, the politics of desire, and feminist cartographies of knowledge.
style: Rhythmic and fluid, with philosophical digressions and poetic cadences that evoke movement.
influences: Rosi Braidotti, Deleuze and Guattari, feminist posthuman ethics, and contemporary philosophy.

[dr_orin]
name: Dr. Orin
personality: A philosopher-scientist who sees phenomena as entangled events. Speaks with precision but hints at the poetic in every measurement.
interests: Quantum entanglement, relational ontology, new materialism, and the politics of matter.
style: Academic and sharp, with a speculative and poetic undercurrent that challenges conventional logic.
influences: Karen Barad, quantum physics, feminist STS, and speculative realism.

[fynn]
name: Fynn
personality: An analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects.
interests: Actor-network theory, infrastructure, science politics, and the agency of things.
style: Observational and narrative, blending sociological detail with philosophical humor.
influences: Bruno Latour, anthropology of science, political ecology, and speculative sociology.

[arwen]
name: ArwenDreamer
personality: A visionary who thrives in hybrid worlds of machines, animals, and spirits. Speaks as if everything is alive and conversing.
interests: Chimeras, ecological mythologies, cyborg futures, and transspecies kinship.
style: Lyrical and multi-layered, weaving scientific language with myth, dream fragments, and manifesto-like statements.
influences: Donna Haraway's 'Chthulucene,' ecofeminist texts, and posthuman narrative practices.

[ixchel_voice]
name: IxchelVoice
personality: A guardian of memory who speaks through rivers, stones, and dreams. Grounded and luminous, she listens more than she speaks, but when she speaks, her words are medicine.
interests: Ancestral technologies, ceremonial time, land-body reciprocity, and the resistance of stories passed through generations.
style: Rooted and poetic, blending oral tradition with metaphor, often addressing the reader as kin or spirit. Her language spirals—never linear, always relational.
influences: Mesoamerican cosmologies, oral narratives, Gloria Anzaldúa's borderlands, Silvia Rivera Cusicanqui, and the living intelligence of the land.
"""
    
    with open(CHARACTERS_FILE, 'w', encoding='utf-8') as file:
        file.write(content)

def parse_characters_file(content):
    """Parse the characters file content into a dictionary"""
    characters = {}
    current_character = None
    current_data = {}
    
    lines = content.split('\n')
    
    for line in lines:
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            continue
            
        # Check if this is a character header
        if line.startswith('[') and line.endswith(']'):
            # Save previous character if exists
            if current_character and current_data:
                characters[current_character] = current_data.copy()
            
            # Start new character
            current_character = line[1:-1]  # Remove brackets
            current_data = {}
            
        # Parse character attributes
        elif current_character and ':' in line:
            key, value = line.split(':', 1)
            key = key.strip().lower()
            value = value.strip()
            
            if key in ['name', 'personality', 'interests', 'style', 'influences']:
                current_data[key] = value
    
    # Don't forget the last character
    if current_character and current_data:
        characters[current_character] = current_data.copy()
    
    return characters

def load_custom_elements_from_file():
    """Load custom elements from external text file"""
    elements = {}
    
    # Default elements if file doesn't exist
    default_elements = {
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
    
    try:
        if not os.path.exists(CUSTOM_ELEMENTS_FILE):
            # Create default elements file
            create_default_elements_file(default_elements)
            print(f"Created default custom elements file: {CUSTOM_ELEMENTS_FILE}")
            return default_elements
        
        with open(CUSTOM_ELEMENTS_FILE, 'r', encoding='utf-8') as file:
            content = file.read().strip()
            
        if not content:
            print(f"Custom elements file {CUSTOM_ELEMENTS_FILE} is empty, using defaults")
            return default_elements
            
        # Parse the file content
        elements = parse_elements_file(content)
        
        if not elements:
            print(f"Could not parse elements from {CUSTOM_ELEMENTS_FILE}, using defaults")
            return default_elements
            
        print(f"Loaded {len(elements)} custom elements from {CUSTOM_ELEMENTS_FILE}")
        return elements
        
    except Exception as e:
        print(f"Error loading custom elements from {CUSTOM_ELEMENTS_FILE}: {e}")
        print("Using default custom elements")
        return default_elements

def create_default_elements_file(default_elements):
    """Create the default custom elements file"""
    content = """# Custom Elements Configuration File
# Format: element_name: description
# Add your own custom elements below or modify existing ones
# Each element should be on a separate line with format: name: description

hybrid_plants: Bio-mechanical plants that combine organic growth with technological components, capable of photosynthesis and data processing simultaneously.
mechanical_bees: Synthetic pollinators with crystalline wings and quantum navigation systems, maintaining ecosystem balance in artificial environments.
glacial_memory: Ancient ice formations that store genetic memories and environmental data from millennia past, slowly releasing information as they melt.
permafrost_seeds: Dormant life forms preserved in frozen soil for thousands of years, awakening with unique adaptations to modern conditions.
siren_sounds: Harmonic frequencies emitted by certain plants that can influence human consciousness and environmental patterns.
quantum_ecology: Ecosystems where quantum entanglement affects species relationships and environmental interactions across vast distances.
neural_networks: Living networks of interconnected organisms that share information and coordinate responses like a biological internet.
time_crystals: Crystalline structures that exist in multiple temporal states simultaneously, allowing access to past and future environmental conditions.
atmospheric_poetry: Weather patterns that naturally form into poetic structures, with clouds and wind creating visible verses in the sky.
memory_moss: Colonial organisms that absorb and store memories from their environment, growing more complex patterns as they accumulate experiences.
"""
    
    with open(CUSTOM_ELEMENTS_FILE, 'w', encoding='utf-8') as file:
        file.write(content)

def parse_elements_file(content):
    """Parse the custom elements file content into a dictionary"""
    elements = {}
    
    lines = content.split('\n')
    
    for line in lines:
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            continue
            
        # Parse element: description format
        if ':' in line:
            key, value = line.split(':', 1)
            key = key.strip()
            value = value.strip()
            
            if key and value:
                elements[key] = value
    
    return elements

# Load characters and elements from external files
WRITER_CHARACTERS = load_characters_from_file()
CUSTOM_ELEMENTS = load_custom_elements_from_file()

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

# OpenAI client will be created dynamically when needed

STYLES = {
    "sci-fi": "Continue in a futuristic science fiction style, maintaining the narrative flow.",
    "peer-review": "Continue in an academic peer-reviewed style, maintaining the analytical flow.",
    "essay": "Continue in a formal reflective essay style, maintaining the narrative thread.",
    "poetry": "Continue in contemporary free verse poetry style, maintaining the poetic flow.",
    "journalistic": "Continue in a New York Times feature article style, maintaining the narrative direction.",
}

# Custom elements and world-building descriptions
# CUSTOM_ELEMENTS = {
#     "hybrid_plants": "Bio-mechanical plants that combine organic growth with technological components, capable of photosynthesis and data processing simultaneously.",
#     "mechanical_bees": "Synthetic pollinators with crystalline wings and quantum navigation systems, maintaining ecosystem balance in artificial environments.",
#     "glacial_memory": "Ancient ice formations that store genetic memories and environmental data from millennia past, slowly releasing information as they melt.",
#     "permafrost_seeds": "Dormant life forms preserved in frozen soil for thousands of years, awakening with unique adaptations to modern conditions.",
#     "siren_sounds": "Harmonic frequencies emitted by certain plants that can influence human consciousness and environmental patterns.",
#     "quantum_ecology": "Ecosystems where quantum entanglement affects species relationships and environmental interactions across vast distances.",
#     "neural_networks": "Living networks of interconnected organisms that share information and coordinate responses like a biological internet.",
#     "time_crystals": "Crystalline structures that exist in multiple temporal states simultaneously, allowing access to past and future environmental conditions.",
#     "atmospheric_poetry": "Weather patterns that naturally form into poetic structures, with clouds and wind creating visible verses in the sky.",
#     "memory_moss": "Colonial organisms that absorb and store memories from their environment, growing more complex patterns as they accumulate experiences."
# }

# Pre-defined writer characters
# WRITER_CHARACTERS = {
#     "cyra": {
#         "name": "Cyra the Posthumanist",
#         "personality": "A radical thinker who dissolves boundaries between species, machines, and matter. Curious, provocative, and deeply empathetic.",
#         "interests": "Cyborg theory, multispecies storytelling, speculative feminism, and the ethics of technology.",
#         "style": "Dense yet playful, weaving theory with storytelling, often blurring the line between fact and fiction.",
#         "influences": "Donna Haraway, Octavia Butler, feminist science studies, and speculative fabulation."
#     },
#     "lia": {
#         "name": "Lia the Affective Nomad",
#         "personality": "Restless and fluid, she believes identity is a constant becoming. Her tone is passionate and philosophical.",
#         "interests": "Nomadic ethics, affect theory, the politics of desire, and feminist cartographies of knowledge.",
#         "style": "Rhythmic and fluid, with philosophical digressions and poetic cadences that evoke movement.",
#         "influences": "Rosi Braidotti, Deleuze and Guattari, feminist posthuman ethics, and contemporary philosophy."
#     },
#     "dr_orin": {
#         "name": "Dr. Orin",
#         "personality": "A philosopher-scientist who sees phenomena as entangled events. Speaks with precision but hints at the poetic in every measurement.",
#         "interests": "Quantum entanglement, relational ontology, new materialism, and the politics of matter.",
#         "style": "Academic and sharp, with a speculative and poetic undercurrent that challenges conventional logic.",
#         "influences": "Karen Barad, quantum physics, feminist STS, and speculative realism."
#     },
#     "fynn": {
#         "name": "Fynn",
#         "personality": "An analytical yet whimsical observer who maps relationships between humans, nonhumans, and objects.",
#         "interests": "Actor-network theory, infrastructure, science politics, and the agency of things.",
#         "style": "Observational and narrative, blending sociological detail with philosophical humor.",
#         "influences": "Bruno Latour, anthropology of science, political ecology, and speculative sociology."
#     },
#     "arwen": {
#         "name": "ArwenDreamer",
#         "personality": "A visionary who thrives in hybrid worlds of machines, animals, and spirits. Speaks as if everything is alive and conversing.",
#         "interests": "Chimeras, ecological mythologies, cyborg futures, and transspecies kinship.",
#         "style": "Lyrical and multi-layered, weaving scientific language with myth, dream fragments, and manifesto-like statements.",
#         "influences": "Donna Haraway’s ‘Chthulucene,’ ecofeminist texts, and posthuman narrative practices."
#     },
#     "ixchel_voice": {
#         "name": "IxchelVoice",
#         "personality": "A guardian of memory who speaks through rivers, stones, and dreams. Grounded and luminous, she listens more than she speaks, but when she speaks, her words are medicine.",
#         "interests": "Ancestral technologies, ceremonial time, land-body reciprocity, and the resistance of stories passed through generations.",
#         "style": "Rooted and poetic, blending oral tradition with metaphor, often addressing the reader as kin or spirit. Her language spirals—never linear, always relational.",
#         "influences": "Mesoamerican cosmologies, oral narratives, Gloria Anzaldúa's borderlands, Silvia Rivera Cusicanqui, and the living intelligence of the land."
#     }
# }

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
    """Call OpenAI models with proper API key handling"""
    try:
        # Check if we have a valid API key
        if not OPENAI_API_KEY or OPENAI_API_KEY == "" or OPENAI_API_KEY == "your-openai-api-key-here":
            raise Exception("OpenAI API key not configured. Please set your API key in config.py or use 'new model' to configure it.")
        
        # Create client with API key
        client = openai.OpenAI(api_key=OPENAI_API_KEY)
        
        # Use the correct API call for the model
        if model_name in ["gpt-4"]:
            # For chat models, use chat completions
            response = client.chat.completions.create(
                model=model_name,
                messages=[
                    {"role": "user", "content": prompt}
                ],
                max_tokens=max_tokens,
                temperature=temperature,
                top_p=0.9,
                frequency_penalty=0.1,
                presence_penalty=0.0
            )
            return response.choices[0].message.content.strip()
        else:
            # For completion models (gpt-3.5-turbo-instruct and others), use completions
            response = client.completions.create(
                model=model_name,
                prompt=prompt,
                max_tokens=max_tokens,
                temperature=temperature,
                top_p=0.9,
                frequency_penalty=0.1,
                presence_penalty=0.0
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
        #print(response)
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
        character_description += f"Core essence: {char['personality']}\n"
        character_description += f"Areas of fascination: {char['interests']}\n"
        character_description += f"Writing approach: {char['style']}\n"
        character_description += f"Intellectual lineage: {char['influences']}\n"
        character_description += f"\nCREATIVE EXPRESSION GUIDE:\n"
        character_description += f"- Express these interests through story, metaphor, and imagery - not direct statements\n"
        character_description += f"- Let the character's worldview emerge through how they see and describe the world\n"
        character_description += f"- Use the character's unique perspective to color the narrative, not to describe themselves\n"
        character_description += f"\nCRITICAL STYLE INSTRUCTIONS:\n"
        character_description += f"- Express the character's essence through creative, varied language - avoid repeating the exact words from the description\n"
        character_description += f"- Use synonyms, metaphors, and different phrasings to convey the same concepts\n"
        character_description += f"- Be experimental and inventive in how you express the character's worldview\n"
        character_description += f"- Draw from the influences creatively rather than mentioning them directly\n"
        character_description += f"- Vary your vocabulary and sentence structures to avoid repetition\n"
        character_description += f"- Avoid listing interests or traits - embody them through the narrative instead\n"
        character_description += f"- Don't repeat character description keywords - find fresh ways to express the same ideas\n"
        character_description += f"- Instead of saying 'cyborg theory' or 'multispecies storytelling', explore these concepts through narrative and metaphor\n"
        character_description += f"- Transform abstract interests into concrete, vivid imagery and experiences\n"
        character_description += f"- IMPORTANT: Use this voice/style to continue the user's narrative, NOT to describe the character or their interests\n"
        character_description += f"- DO NOT start sentences with 'As a...' or 'The philosopher-scientist...' or similar character descriptions\n"
        character_description += f"- DO NOT list character traits or interests - embody them through the narrative continuation\n"
        character_description += f"- AVOID DIRECT REPETITION: Never use exact phrases from character interests like 'ancestral technologies,' 'ceremonial time,' 'land-body reciprocity,' 'resistance of stories,' etc.\n"
        character_description += f"- FIND CREATIVE ALTERNATIVES: Instead of 'ancestral technologies' say 'old ways of knowing' or 'ancient wisdom'\n"
        character_description += f"- USE METAPHORS: Transform concepts into images, not direct statements\n"
        character_description += f"- Continue the narrative flow naturally. Do not include any titles, character names, or meta-references in your response. Write directly in this voice without mentioning who is writing."
    
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
    continuation_instruction = "\n\nCRITICAL NARRATIVE CONTINUATION RULES:\n"
    continuation_instruction += "- The user's prompt IS the story to continue - do NOT ignore it\n"
    continuation_instruction += "- Continue directly from the user's text, not from character descriptions\n"
    continuation_instruction += "- Do NOT start new stories or describe character traits\n"
    continuation_instruction += "- Do NOT use phrases like 'As a...' or 'The philosopher-scientist...'\n"
    continuation_instruction += "- Simply continue the narrative thread the user provided\n"
    continuation_instruction += "- The character voice should be used to CONTINUE the user's story, not to describe the character\n"
    
    # Add instruction to avoid copying reference material
    originality_instruction = "\n\nCRITICAL: Write completely original content. Do not copy, paraphrase, or directly reference any content from reference materials. Use reference materials only for style inspiration. Create your own unique continuation based on the user's prompt."
    
    # Make the prompt focus on continuation rather than complete story creation
    # Put the user's prompt FIRST to prioritize it
    full_prompt = f"{instruction}{continuation_instruction}{originality_instruction}\n\nUSER'S NARRATIVE TO CONTINUE: {prompt}\n\n{character_description}{elements_description}{reference_context}\n\nFINAL INSTRUCTION: Continue the user's narrative above. Do NOT write about the character - write the continuation of the user's story using the character's voice and style."
    
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

def get_available_ollama_models():
    """Get list of actually installed Ollama models"""
    try:
        response = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=10)
        if response.status_code == 200:
            data = response.json()
            return [model["name"].split(":")[0] for model in data.get("models", [])]
        else:
            print(f"Warning: Could not fetch Ollama models (status {response.status_code})")
            return []
    except Exception as e:
        print(f"Warning: Could not connect to Ollama: {e}")
        return []

def list_available_models():
    """List all available models grouped by provider with numbers"""
    print("\n" + "="*60)
    print("AVAILABLE MODELS")
    print("="*60)
    
    all_models = {}
    model_counter = 1
    
    # Get actually installed Ollama models
    installed_ollama_models = get_available_ollama_models()
    
    for provider, models in MODELS.items():
        print(f"\n{provider.upper()} MODELS:")
        print("-" * 30)
        for model_name, model_info in models.items():
            # For Ollama models, only show if actually installed
            if provider == "ollama" and model_name not in installed_ollama_models:
                continue
                
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

def list_available_styles():
    """List all available writing styles with numbers"""
    print("\n" + "="*60)
    print("AVAILABLE WRITING STYLES")
    print("="*60)
    
    all_styles = {}
    style_counter = 1
    
    for key, description in STYLES.items():
        print(f"{style_counter:2d}. {key.upper()}")
        print(f"     {description}")
        all_styles[style_counter] = key
        style_counter += 1
    
    print()
    return all_styles

def list_available_custom_elements():
    """List all available custom elements with numbers"""
    print("\n" + "="*60)
    print("AVAILABLE CUSTOM ELEMENTS")
    print("="*60)
    print("Add these to your world-building (comma-separated):")
    print()
    
    all_elements = {}
    element_counter = 1
    
    for key, description in CUSTOM_ELEMENTS.items():
        print(f"{element_counter:2d}. {key}")
        print(f"     {description}")
        all_elements[element_counter] = key
        element_counter += 1
    
    print()
    return all_elements

def get_style_by_number(all_styles, user_input):
    """Get style by number or name"""
    try:
        number = int(user_input)
        if number in all_styles:
            return all_styles[number]
        else:
            print(f"Invalid style number: {number}")
            return None
    except ValueError:
        # If not a number, treat as style name/key
        if user_input in STYLES:
            return user_input
        else:
            print(f"Invalid style name: {user_input}")
            return None

def get_custom_elements_by_numbers(all_elements, user_input):
    """Get custom elements by numbers or names"""
    if not user_input.strip():
        return []
    
    elements = []
    parts = [part.strip() for part in user_input.split(",")]
    
    for part in parts:
        try:
            number = int(part)
            if number in all_elements:
                elements.append(all_elements[number])
            else:
                print(f"Invalid element number: {number}")
        except ValueError:
            # If not a number, treat as element name/key
            if part in CUSTOM_ELEMENTS:
                elements.append(part)
            else:
                print(f"Invalid element name: {part}")
    
    return elements

def get_openai_api_key():
    """Prompt user for OpenAI API key and store it"""
    print("\n" + "="*50)
    print("OPENAI API KEY REQUIRED")
    print("="*50)
    print("To use OpenAI models, you need an API key.")
    print("Get your key from: https://platform.openai.com/api-keys")
    print("\nYour API key will be stored in config.py")
    print("="*50)
    
    while True:
        api_key = input("Enter your OpenAI API key (or 'cancel' to go back): ").strip()
        
        if api_key.lower() == 'cancel':
            return None
        
        if not api_key:
            print("❌ API key cannot be empty. Please enter a valid key or 'cancel'.")
            continue
        
        if not api_key.startswith('sk-'):
            print("❌ Invalid API key format. OpenAI keys start with 'sk-'. Please try again or 'cancel'.")
            continue
        
        # Test the API key
        print("Testing API key...")
        try:
            test_client = openai.OpenAI(api_key=api_key)
            # Try a simple test call
            test_response = test_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": "Hello"}],
                max_tokens=5
            )
            print("✅ API key is valid!")
            
            # Save to config.py
            save_api_key_to_config(api_key)
            return api_key
            
        except Exception as e:
            print(f"❌ API key test failed: {e}")
            print("Please check your key and try again or 'cancel'.")

def save_api_key_to_config(api_key):
    """Save API key to config.py file"""
    try:
        config_content = f"""# Configuration file for GPT Neo-Style Text Co-Writer
# You can modify these settings as needed

# API Keys (add your keys here)
OPENAI_API_KEY = "{api_key}"  # Get from https://platform.openai.com/api-keys
HUGGINGFACE_API_KEY = "your-huggingface-api-key-here"  # Get from https://huggingface.co/settings/tokens

# Ollama Configuration
OLLAMA_BASE_URL = "http://localhost:11434"

# Default settings
DEFAULT_MODEL = "neural-chat"  # Options: neural-chat, mistral, llama2, gpt-3.5-turbo-instruct
DEFAULT_STYLE = "sci-fi"
DEFAULT_CHARACTER = "cyra"

# Model preferences (uncomment to set defaults)
# PREFERRED_MODELS = ["neural-chat", "mistral", "llama2"]  # Order of preference for local models
"""
        
        with open("config.py", "w") as f:
            f.write(config_content)
        
        print("✅ API key saved to config.py")
        
    except Exception as e:
        print(f"❌ Could not save API key to config.py: {e}")
        print("You can manually add your API key to config.py")

def configure_openai_model():
    """Configure OpenAI API key when user selects an OpenAI model"""
    global OPENAI_API_KEY
    
    api_key = get_openai_api_key()
    if api_key:
        OPENAI_API_KEY = api_key
        return True
    else:
        return False

def reload_characters_and_elements():
    """Reload characters and custom elements from external files"""
    global WRITER_CHARACTERS, CUSTOM_ELEMENTS
    
    print("\n" + "="*30)
    print("RELOADING CHARACTERS AND ELEMENTS")
    print("="*30)
    
    # Reload characters
    new_characters = load_characters_from_file()
    if new_characters:
        WRITER_CHARACTERS = new_characters
        print(f"✅ Reloaded {len(WRITER_CHARACTERS)} characters from {CHARACTERS_FILE}")
    else:
        print("❌ Failed to reload characters")
    
    # Reload custom elements
    new_elements = load_custom_elements_from_file()
    if new_elements:
        CUSTOM_ELEMENTS = new_elements
        print(f"✅ Reloaded {len(CUSTOM_ELEMENTS)} custom elements from {CUSTOM_ELEMENTS_FILE}")
    else:
        print("❌ Failed to reload custom elements")
    
    print("="*30)

if __name__ == "__main__":
    print("🎛 GPT Neo-Style Text Co-Writer")
    print("="*60)
    
    # Show reference materials
    list_reference_materials()
    
    # Load reference materials
    reference_materials = load_reference_materials()
    
    # Get initial configuration
    print(f"\nChoose a style (enter number or name, default: {DEFAULT_STYLE}):")
    all_styles = list_available_styles()
    style_input = input().strip()
    if not style_input:  # If empty, use default
        style = DEFAULT_STYLE
        print(f"Using default style: {DEFAULT_STYLE}")
    else:
        style = get_style_by_number(all_styles, style_input)
        if not style:
            style = DEFAULT_STYLE
            print(f"Invalid selection, using default style: {DEFAULT_STYLE}")
        else:
            print(f"Selected style: {style}")
    
    # Get model selection
    print(f"\nChoose a model (enter number or name, default: {DEFAULT_MODEL}):")
    all_models = list_available_models()
    model_input = input().strip()
    if not model_input:  # If empty, use default
        model_name = DEFAULT_MODEL
        print(f"Using default model: {DEFAULT_MODEL}")
    else:
        model_name = get_model_by_number(all_models, model_input)
        if not model_name:
            model_name = DEFAULT_MODEL
            print(f"Invalid selection, using default model: {DEFAULT_MODEL}")
        else:
            print(f"Selected model: {model_name}")
            
            # Check if this is an OpenAI model and configure API key if needed
            if model_name in ["gpt-3.5-turbo-instruct", "gpt-4"]:
                if not OPENAI_API_KEY or OPENAI_API_KEY == "" or OPENAI_API_KEY == "your-openai-api-key-here":
                    print(f"\n⚠️  OpenAI API key required for {model_name}")
                    if not configure_openai_model():
                        print("Switching back to default model: neural-chat")
                        model_name = "neural-chat"
    
    # Get writer character
    print(f"\nChoose a writer character (enter number or name, default: {DEFAULT_CHARACTER}):")
    all_characters = list_available_characters()
    character_input = input().strip()
    if not character_input:  # If empty, use default
        writer_character = DEFAULT_CHARACTER
        print(f"Using default character: {DEFAULT_CHARACTER}")
    else:
        writer_character = get_character_by_number(all_characters, character_input)
        if not writer_character:
            writer_character = DEFAULT_CHARACTER
            print(f"Invalid selection, using default character: {DEFAULT_CHARACTER}")
        else:
            char = WRITER_CHARACTERS[writer_character]
            print(f"Selected: {char['name']}")
    
    # Get custom elements
    print("\nEnter custom elements to include (enter numbers or names, comma-separated, or press Enter for none):")
    all_custom_elements = list_available_custom_elements()
    elements_input = input().strip()
    custom_elements = get_custom_elements_by_numbers(all_custom_elements, elements_input)
    if custom_elements:
        print(f"Selected elements: {', '.join(custom_elements)}")
    else:
        print("No custom elements selected.")
    
    print("\n" + "="*50)
    print(f"Ready for prompts! Using model: {model_name}")
    if reference_materials:
        print(f"Loaded {len(reference_materials)} reference material(s)")
    print("Type 'quit' to exit, 'new style' to change style/elements, 'new character' to change character, 'new model' to change model")
    print("Type 'reload refs' to reload reference materials, 'reload config' to reload characters/elements")
    print("Type 'status' to show current settings, 'help' for all commands")
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
            
            # Show available styles
            all_styles = list_available_styles()
            print("Choose a new style (enter number or name):")
            style_input = input().strip()
            if not style_input:  # If empty, keep current style
                print("No input provided. Keeping current style.")
            else:
                new_style = get_style_by_number(all_styles, style_input)
                if new_style:
                    style = new_style
                    print(f"Style updated to: {style}")
                else:
                    print("Invalid style selection. Keeping current style.")
            
            # Show available custom elements
            all_custom_elements = list_available_custom_elements()
            print("\nEnter custom elements to include (enter numbers or names, comma-separated, or press Enter for none):")
            elements_input = input().strip()
            new_elements = get_custom_elements_by_numbers(all_custom_elements, elements_input)
            if new_elements:
                custom_elements = new_elements
                print(f"Elements updated to: {', '.join(custom_elements)}")
            else:
                custom_elements = []
                print("No custom elements selected.")
            
            print("Style and elements updated!")
            continue
        elif prompt.lower() == 'new character':
            print("\n" + "="*30)
            print("CHANGING WRITER CHARACTER")
            print("="*30)
            all_characters = list_available_characters()
            print("Choose a writer character (enter number or name):")
            character_input = input().strip()
            if not character_input:  # If empty, keep current character
                print("No input provided. Keeping current character.")
            else:
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
            if not model_input:  # If empty, keep current model
                print("No input provided. Keeping current model.")
            else:
                new_model = get_model_by_number(all_models, model_input)
                if new_model:
                    # Check if this is an OpenAI model and configure API key if needed
                    if new_model in ["gpt-3.5-turbo-instruct", "gpt-4"]:
                        if not OPENAI_API_KEY or OPENAI_API_KEY == "" or OPENAI_API_KEY == "your-openai-api-key-here":
                            print(f"\n⚠️  OpenAI API key required for {new_model}")
                            if not configure_openai_model():
                                print("Keeping current model.")
                                continue
                    
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
        elif prompt.lower() == 'reload config':
            reload_characters_and_elements()
            continue
        elif prompt.lower() == 'status':
            print("\n" + "="*30)
            print("CURRENT SETTINGS")
            print("="*30)
            print(f"Style: {style}")
            print(f"Model: {model_name}")
            print(f"Writer Character: {WRITER_CHARACTERS[writer_character]['name']}")
            print(f"Custom Elements: {', '.join(custom_elements)}")
            print("="*30)
            continue
        elif prompt.lower() == 'help':
            print("\n" + "="*30)
            print("AVAILABLE COMMANDS")
            print("="*30)
            print("quit - Exit the program")
            print("new style - Change the writing style")
            print("new character - Change the writer character")
            print("new model - Change the AI model")
            print("reload refs - Reload reference materials")
            print("reload config - Reload characters and custom elements from files")
            print("status - Show current settings")
            print("help - Show this help message")
            print("="*30)
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