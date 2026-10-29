"""Adapt an engine API dump for the optional rbxmk 0.9.1 local scene writer."""
import argparse
import json
from pathlib import Path

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('input', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    data = json.loads(args.input.read_text(encoding='utf-8'))
    for cls in data['Classes']:
        # The older tool cannot decode newer union function signatures. It only
        # needs class Service tags and property metadata when writing this place.
        cls['Members'] = [m for m in cls['Members'] if m['MemberType'] == 'Property' and isinstance(m.get('ValueType'), dict)]
    args.output.write_text(json.dumps(data), encoding='utf-8')
