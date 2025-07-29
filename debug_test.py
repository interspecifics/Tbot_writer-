#!/usr/bin/env python3

# Test script to debug the model detection issue

# Copy the MODELS dictionary and detection logic from text_co_writer.py
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

def test_model_detection(model_name):
    print(f"Testing model detection for: '{model_name}'")
    
    # Find the model provider
    model_provider = None
    for provider, models in MODELS.items():
        print(f"  Checking provider: {provider}")
        print(f"  Available models in {provider}: {list(models.keys())}")
        if model_name in models:
            model_provider = models[model_name]["provider"]
            print(f"  ✓ Found model '{model_name}' in provider '{provider}'")
            break
        else:
            print(f"  ✗ Model '{model_name}' not found in provider '{provider}'")
    
    if not model_provider:
        print(f"❌ Model {model_name} not found in any provider")
        return None
    else:
        print(f"✅ Model provider: {model_provider}")
        return model_provider

# Test with the default model
print("=== Testing with default model 'neural-chat' ===")
test_model_detection("neural-chat")

print("\n=== Testing with other models ===")
test_model_detection("mistral")
test_model_detection("llama2")
test_model_detection("gpt-3.5-turbo-instruct") 