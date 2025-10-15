# Profile-Based Styles for Alacritty Functions

This document describes the new profile-based styles system that allows each Alacritty profile to have its own set of styles.

## Overview

Previously, styles were globally scoped, meaning all profiles shared the same set of styles (lite, dark, pro). With the new system, each profile can have its own unique set of styles, allowing for more granular customization based on different use cases.

## JSON Structure

The `alacritty_styles.json` file now uses a nested structure where styles are organized under profile names:

```json
{
  "alacritty_styles": {
    "default": {
      "lite": {
        "theme": "solarized_light",
        "font_size": "10",
        "opacity": 0.99
      },
      "dark": {
        "theme": "ubuntu",
        "font_size": "9",
        "opacity": 0.8
      }
    },
    "work": {
      "lite": {
        "theme": "github_light",
        "font_size": "11",
        "opacity": 0.95
      },
      "focus": {
        "theme": "tomorrow_night",
        "font_size": "12",
        "opacity": 0.92
      }
    }
  }
}
```

## Functions

### Core Style Functions

- `critty_style <name>` - Switch to a style within the current profile
- `critty_styles` - List available styles for the current profile
- `critty_set_style <style> <theme> <font_size> <opacity>` - Create/modify a style for the current profile

### Profile Management Functions

- `critty_all_styles` - Show all styles across all profiles
- `critty_copy_styles <source_profile> <dest_profile>` - Copy styles from one profile to another
- `critty_migrate_styles` - Migrate from old global styles format to profile-based format

## Usage Examples

### Basic Usage

```bash
# Switch to or create a 'work' profile
critty work

# Then in the new work profile window, apply 'focus' style
critty_style focus

# Create a new style for the current profile
critty_set_style evening dracula 10 0.85

# View styles for current profile
critty_styles
```

### Profile Management

```bash
# View all styles across all profiles
critty_all_styles

# Copy styles from 'default' profile to 'presentation' profile
critty_copy_styles default presentation

# Create a new style for a specific profile
ALACRITTY_PROFILE_NAME=gaming critty_set_style stealth material_dark 8 0.7
```

### Working with Different Profiles

```bash
# Start alacritty with 'work' profile
critty work
# Then in the work profile window, switch to lite style
crittylite

# Start with gaming profile  
critty gaming
# Then in the gaming profile window, apply dark style
critty_style dark
```

## Migration from Old Format

If you have an existing `alacritty_styles.json` file with the old global format, use the migration function:

```bash
critty_migrate_styles
```

This will:
1. Create a backup of your current configuration
2. Move all existing styles under the 'default' profile
3. Preserve all your existing style configurations

## Profile Context

The current profile is determined by the `ALACRITTY_PROFILE_NAME` environment variable. If not set, it defaults to 'default'. All style operations work within the context of the current profile.

### Understanding critty() Function

The `critty()` function creates or switches to a profile by:
1. Creating a new Alacritty window with the specified profile
2. Setting the `ALACRITTY_PROFILE_NAME` environment variable for that window
3. Loading the profile's configuration file (`alacritty-<profile_name>.toml`)

```bash
# This creates a new window with 'work' profile
critty work

# Within that window, ALACRITTY_PROFILE_NAME=work
# So style functions will use 'work' profile's styles
critty_style lite  # Uses work profile's lite style
```

### Setting Profile Context Manually

You can also set the profile context manually for style operations:

```bash
# Set profile context for current session
export ALACRITTY_PROFILE_NAME=work

# Or for a single command
ALACRITTY_PROFILE_NAME=gaming critty_style dark
```

## Best Practices

1. **Organize by Use Case**: Create profiles for different contexts (work, gaming, presentation)
2. **Consistent Naming**: Use consistent style names across profiles where appropriate
3. **Profile-Specific Styles**: Create styles that make sense for each profile's context
4. **Backup Before Migration**: Always backup your configuration before migrating

## Example Scenarios

### Developer Setup
```bash
# Create and switch to default profile, then set up coding style
critty default
# In the default profile window:
critty_set_style code solarized_dark 11 0.9

# Create and switch to work profile for professional environment
critty work
# In the work profile window:
critty_set_style code github_light 12 0.95
critty_set_style meeting tomorrow_night 14 1.0
```

### Gaming Setup
```bash
# Create and switch to gaming profile with minimal distraction
critty gaming
# In the gaming profile window:
critty_set_style stealth material_dark 8 0.7
critty_set_style overlay cyberpunk 9 0.6
```

### Presentation Setup
```bash
# Create and switch to presentation profile with large, high-contrast styles
critty presentation
# In the presentation profile window:
critty_set_style demo solarized_light 16 1.0
critty_set_style code_demo github_light 14 1.0
```

## Troubleshooting

- **Style not found**: Make sure the style exists for the current profile using `critty_styles`
- **Profile not found**: Check available profiles with `critty_all_styles`
- **Migration issues**: Check the backup file created during migration

## File Locations

- Styles configuration: `~/.config/alacritty/alacritty_styles.json`
- Profile configurations: `~/.config/alacritty/alacritty-<profile_name>.toml`
- Backup files: `~/.config/alacritty/alacritty_styles.json.pre-migration.bak`
