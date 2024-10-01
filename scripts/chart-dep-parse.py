#!/usr/bin/env python3

import yaml
import subprocess
import sys
import os

chart = yaml.safe_load(open('Chart.yaml'))

debug_update = False
debug_default_vaules = False
debug_reg_add = False
run_all = False if debug_default_vaules or debug_reg_add or debug_update else True

for dep in chart['dependencies']:
    name = dep['name']
    repo = dep['repository']
    condition = dep.get('condition', True)
    
    if run_all or debug_reg_add:
        # ADD REG LOCAL
        print(f"Adding {name} from {repo}")
        try:
            subprocess.run(['helm', 'repo', 'add', name, repo], check=True)
        except subprocess.CalledProcessError as e:
            if 'repository name' in str(e):
                print(f"Skipping {name} as it already exists")
            else:
                continue

    if run_all or debug_reg_add:
        # UPDATE
        latest_version = subprocess.run(['helm', 'search', 'repo', f"{name}/{name}"], capture_output=True, text=True, check=True).stdout.splitlines()[1].split()[1]
        print(f"Updating {name} to version {latest_version}")
        dep['version'] = latest_version
        dep['condition'] = f"{name}.enabled"

    if run_all or debug_default_vaules:

        # VALUES
        folder = f"values/examples/defaults"
        if not os.path.exists(folder):
            os.makedirs(folder, exist_ok=True)
        reg_repo = "{}/{}".format(name, name)
        default_values = subprocess.run(['helm', 'show', 'values', reg_repo], capture_output=True, text=True, check=True).stdout
        with open(f"{folder}/{name}_default_values.yaml", 'w') as f:
            f.write(default_values)


with open('./Chart.yaml', 'w') as f:
    yaml.dump(chart, f)

