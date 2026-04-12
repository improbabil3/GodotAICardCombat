import os
import sys

def fix_json_file(path):
    with open(path, "r") as f:
        content = f.read()
    
    # Simple brackets counter to find first valid JSON object
    json_str = ""
    brackets = 0
    in_string = False
    escape = False
    
    for i, char in enumerate(content):
        json_str += char
        if char == "\"" and not escape:
            in_string = not in_string
        if not in_string:
            if char == "{":
                brackets += 1
            elif char == "}":
                brackets -= 1
        
        if char == "\\":
            escape = True
        else:
            escape = False
            
        if brackets == 0 and json_str.strip() and not in_string:
            break
            
    with open(path, "w") as f:
        f.write(json_str)
    print(f"Fixed {path}")

files = ["deck_omega_pilot_specific.json", "deck_phoenix_guardian_specific.json", "deck_apex_striker_specific.json", "deck_void_walker_specific.json", "deck_cyber_mystic_specific.json"]
for f in files:
    fix_json_file(os.path.join("data", f))
