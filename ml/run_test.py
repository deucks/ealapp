from unsloth import FastLanguageModel
from transformers import TextStreamer
import torch

# === Load model ===
max_seq_length = 2048
dtype = None
load_in_4bit = True

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="lora_model",  # Path to your fine-tuned model
    max_seq_length=max_seq_length,
    dtype=dtype,
    load_in_4bit=load_in_4bit,
)

FastLanguageModel.for_inference(model)  # Enables faster inference

# === Prompt template ===
alpaca_prompt = """Below is an instruction that describes a task, paired with an input that provides further context. Write a response that appropriately completes the request.

### Instruction:
{}

### Input:
{}

### Response:
{}"""

# === Interactive loop ===
text_streamer = TextStreamer(tokenizer)

print("🧠 EAL Tutor is ready! Type your question (or type 'exit' to quit).")
while True:
    user_input = input("\n❓ Your question: ")
    if user_input.strip().lower() in ["exit", "quit", "q"]:
        print("👋 Goodbye!")
        break

    # Tokenize prompt
    input_prompt = alpaca_prompt.format("Your task:\n- Continue the scenario.\n- Provide grammar help.\n- Adjust difficulty.\n\nRespond in JSON format.", 
                                        "Scenario: Talking about lunchtime \nLevel: B2\nConversation history:\nStudent: \"\" \nAssistant: \"\"\nFeedback: \"Good reflection.\"\n\nCurrent student input: \"" + user_input.strip() + "\" \n\nYour task:\n- Respond.\n- Grammar feedback.\n- Difficulty.\n\nRespond in JSON format.", 
                                        "")
    inputs = tokenizer([input_prompt], return_tensors="pt").to("cuda")

    # Generate and stream output
    _ = model.generate(**inputs, streamer=text_streamer, max_new_tokens=128)
