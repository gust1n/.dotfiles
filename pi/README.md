# pi config

Settings for [pi](https://pi.dev), the coding agent.

## Files

| File | Tracked | Description |
|------|---------|-------------|
| `settings.json` | ✅ | Shared settings: packages, thinking level, UI prefs |
| `settings.local.json` | ❌ gitignored | Machine-specific overrides: provider, model |

## Setup on a new machine

1. Create `pi/settings.local.json` (not committed) with the provider for this machine:

   ```json
   {
     "defaultProvider": "openrouter",
     "defaultModel": "anthropic/claude-sonnet-4-5"
   }
   ```

   For Amazon Bedrock:
   ```json
   {
     "defaultProvider": "amazon-bedrock",
     "defaultModel": "eu.anthropic.claude-sonnet-4-6",
     "enabledModels": ["eu.anthropic.claude-*"]
   }
   ```

2. Run the sync (also runs automatically during `install.sh`):

   ```bash
   bin/pi-settings-sync
   ```

This generates `~/.pi/agent/settings.json` by merging the tracked base with your
local overrides, preserving pi-managed fields (`lastChangelogVersion`, `theme`, etc.)
from any existing live file.

## Updating shared settings

Edit `pi/settings.json`, then run `bin/pi-settings-sync` to apply.
