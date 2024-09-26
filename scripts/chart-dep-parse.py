#!/usr/bin/env python3

import yaml
import subprocess
import sys

chart = yaml.safe_load(open('Chart.yaml'))

for dep in chart['dependencies']:
    name = dep['name']
    repo = dep['repository']
    condition = dep.get('condition', True)
    print(f"Adding {name} from {repo}")
    subprocess.run(['helm', 'repo', 'add', name, repo], check=True)
    latest_version = subprocess.run(['helm', 'search', 'repo', name, '--versions'], capture_output=True, text=True, check=True).stdout.splitlines()[1].split()[-1]
    print(f"Updating {name} to version {latest_version}")
    dep['version'] = latest_version

with open('Chart.yaml', 'w') as f:
    yaml.dump(chart, f)

