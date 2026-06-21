import os

proj = 'project.godot'
with open(proj, 'r', encoding='utf-8') as f:
    content = f.read()

# New V4 autoloads to add
new_autoloads = [
    'CampaignDirector="*res://scripts/campaign/campaign_director.gd"',
    'CraftingManager="*res://scripts/crafting/crafting_manager.gd"',
    'FactionManager="*res://scripts/factions/faction_manager.gd"',
    'LocalizationManager="*res://scripts/localization/localization_manager.gd"',
    'AccessibilityManager="*res://scripts/accessibility/accessibility_manager.gd"',
]

# Find the [autoload] section and add new entries before [input]
lines = content.split('\n')
new_lines = []
in_autoload = False
added = False

for line in lines:
    if line.strip() == '[autoload]':
        in_autoload = True
    elif line.strip().startswith('[') and in_autoload:
        # We've reached the next section after [autoload]
        if not added:
            for al in new_autoloads:
                new_lines.append(al)
            new_lines.append('')
            added = True
        in_autoload = False
    
    # Check if this autoload already exists
    if in_autoload and any(al.split('=')[0] in line for al in new_autoloads):
        continue  # Skip duplicate
    
    new_lines.append(line)

with open(proj, 'w', encoding='utf-8', newline='\n') as f:
    f.write('\n'.join(new_lines))

print('V4 autoloads added successfully!')
print('New autoloads:')
for al in new_autoloads:
    print(f'  {al}')
