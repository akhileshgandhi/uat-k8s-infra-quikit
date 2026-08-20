## python .\keyconverter\x.py 


import re
import json
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

INPUT_FILE = BASE_DIR / "raw.txt"
OUTPUT_FILE = BASE_DIR / "result.json"


def convert_env_to_json(input_file, output_file):
    data = {}

    with open(input_file, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()

            if not line or line.startswith("#"):
                continue

            match = re.match(
                r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*["\']?(.*?)["\']?\s*$',
                line
            )

            if match:
                key = match.group(1)
                value = match.group(2)
                data[key] = value

    with open(output_file, "w", encoding="utf-8") as file:
        json.dump(data, file, indent=2)

    print(f"Converted successfully!")
    print(f"Input : {input_file}")
    print(f"Output: {output_file}")


if __name__ == "__main__":
    convert_env_to_json(INPUT_FILE, OUTPUT_FILE)