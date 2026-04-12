import json, os
files = ["deck_omega_pilot_specific.json", "deck_phoenix_guardian_specific.json", "deck_apex_striker_specific.json", "deck_void_walker_specific.json", "deck_cyber_mystic_specific.json"]
for f in files:
    path = os.path.join("data", f)
    if not os.path.exists(path):
        print(f"{f}: FILE NOT FOUND")
        continue
    with open(path) as fp:
        try:
            content = fp.read()
            # Split by "}" and keep only the first valid json block
            json_str = content.split("}")[0] + "}]}" # Attempting to fix the structure
            # Re-evaluating strategy: just read line by line until first closing }
            json_str = ""
            brackets = 0
            for char in content:
                json_str += char
                if char == "{": brackets += 1
                elif char == "}": brackets -= 1
                if brackets == 0 and json_str.strip():
                    break
            d = json.loads(json_str)
            cards = d["cards"]
            print(f"{f}: {len(cards)} cards")
            dominated = []
            for i, a in enumerate(cards):
                for j, b in enumerate(cards):
                    if i != j:
                        if (a["damage"] >= b["damage"] and a["shield"] >= b["shield"] and a["heal"] >= b["heal"] and a["energy"] <= b["energy"] and not (a["damage"] == b["damage"] and a["shield"] == b["shield"] and a["heal"] == b["heal"] and a["energy"] == b["energy"])):
                            dominated.append(b["name"])
            unique_dominated = sorted(list(set(dominated)))
            if unique_dominated:
                print(f"  WARNING dominated: {unique_dominated}")
            else:
                print(f"  OK: no dominated cards")
        except Exception as e:
            print(f"{f}: Error {e}")
