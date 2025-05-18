# app.py
from flask import Flask, request, jsonify
from threading import Lock
from unsloth import FastLanguageModel
from transformers import TextStreamer, TextIteratorStreamer  # noqa: F401 (streamers kept if you log tokens)
import torch, json, re, json, ast


max_seq_length = 2048
dtype           = None
load_in_4bit    = True

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name      = "lora_model",      # ← path or HF repo of your fine‑tuned LoRA
    max_seq_length  = max_seq_length,
    dtype           = dtype,
    load_in_4bit    = load_in_4bit,
)

FastLanguageModel.for_inference(model)   # speed tweaks
model.eval()
model_lock = Lock()                      # simple thread‑safety for Flask


app = Flask(__name__)

# ALPACA_PROMPT = """Below is an instruction that describes a task, paired with an input that provides further context.
# Write a response that appropriately completes the request. (Respond with **nothing except** a valid JSON object. Dont use apostrophes. only use double apostrophes for keys.)

# ### Instruction:
# {instruction}

# ### Input:
# {input}

# ### Response:
# """

ALPACA_PROMPT = """Below is an instruction that describes a task, paired with an input that provides further context.
Write a response that appropriately completes the request. (Respond with **only** valid JSON. Use "double quotes" for all keys and string values. Escape any double quote appearing inside a value (\"), never use single quotes. Never use the character -)

### Instruction:
{instruction}

### Input:
{input}

### Response:
"""

def build_prompt(user_text: str, scenario:str, conversation_history:str) -> str:
    return ALPACA_PROMPT.format(
        instruction="Your task:\n- Continue the scenario. Always keep the conversation flowing with new ideas. Provide 10 possible responses.\n- Provide sentence structure feedback. \n- Decide whether to adjust difficulty.\n\nKeys = reply, feedback, adjust_difficulty, possible_correct_responses",
        input=f"Scenario: {scenario}\nLevel: B2\nConversation history:\n{conversation_history}\n\nCurrent student input: \"{user_text}\"",
    )

def safe_json_parse(raw_text: str):
    print(raw_text)
    data = ast.literal_eval(raw_text)

    # Step 2:  json.dumps → canonical JSON string
    json_str = json.dumps(data, ensure_ascii=False, indent=2)
    print(json_str)

    return json_str


@app.post("/generate")
def generate():
    data = request.get_json(force=True)
    user_text       = data.get("text", "").strip()
    max_new_tokens  = int(data.get("max_new_tokens", 428))
    scenario       = data.get("scenario", "").strip()
    history       = data.get("history", "").strip()

    if not user_text:
        return jsonify({"error": "Field 'text' is required"}), 400

    prompt = build_prompt(user_text, scenario, history)
    print(prompt)
    input_ids = tokenizer([prompt], return_tensors="pt").to(model.device)

    with torch.no_grad(), model_lock:
        output_ids = model.generate(
            **input_ids,
            max_new_tokens=max_new_tokens,
            do_sample=True,
            temperature=1.0,  
            top_p=0.9,
            repetition_penalty=1.1,
        )

    generated = tokenizer.decode(
        output_ids[0][input_ids["input_ids"].shape[-1]:],
        skip_special_tokens=True,
    )

    parsed = safe_json_parse(generated)

    return parsed

    # if parsed is not None:
    #     return parsed           # success – already a dict
    # else:
    #     # fall back: return raw text plus error description
    #     return jsonify({"raw_response": generated}), 502

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, threaded=False)  # single worker keeps model_lock simple
