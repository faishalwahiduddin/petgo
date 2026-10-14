import json
import os
import re

# load keys.json
with open('keys.json', 'r') as f:
    id_strings = json.load(f)

# define translations based on id_strings
# I will use a simple function to map some common ones, and provide a dict for the rest.
