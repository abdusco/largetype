# LargeType

A macOS command-line utility that displays text in the largest possible font size on a fullscreen overlay.

<video src="https://github.com/user-attachments/assets/c964a11f-f3de-496c-b9d8-8208d6cb5c2c" controls></video>

## Features

- Displays text as large as possible while fitting on screen without wrapping
- Fullscreen overlay that appears over all other windows
- Customizable font type (sans-serif or monospace)
- Customizable text and background colors
- Click anywhere or press Escape (even when the app is not focused) to dismiss

## Usage

```bash
# Basic usage
largetype "Hello World"

# With custom font
largetype "Code Example" --font-family monospace

# With custom colors
largetype "Alert!" --color ff0000 --background-color 000000ff

# All options
largetype "Custom Text" --font-family sans-serif --font-size 72 --font-weight bold --color ffffff --background-color 00000080 --text-align center --padding 60px --hide-after 5
```

## Command Line Options

- `--font-family <sans-serif|monospace|system|CustomFontName>`: Font type (default: sans-serif)
- `--font-size <number>`: Font size in points (default: 72)
- `--font-weight <ultralight|thin|light|regular|medium|semibold|bold|heavy|black>`: Font weight (default: regular)
- `--background-color <rrggbbaa>`: Background color in hex RGBA format (default: 00000080 - 50% black)
- `--color <rrggbb>`: Text color in hex RGB format (default: ffffff - white)
- `--text-align <left|center|right>`: Text alignment (default: center)
- `--padding <number[px|%]>`: Padding around text (default: 5%)
- `--hide-after <seconds>`: Hide overlay after N seconds
- `--help`: Show help message
- `--version`: Show version

## Color Format

- Text color: 6-digit hex RGB (e.g., `ffffff` for white, `ff0000` for red)
- Background color: 8-digit hex RGBA (e.g., `00000080` for 50% black, `ff000040` for 25% red)

## Installation

```bash
# Install to /usr/local/bin (requires sudo)
make install

# Or copy manually
cp largetype /usr/local/bin/
```

## Examples

```bash
# Display white text on semi-transparent black background
largetype "Meeting in 5 minutes"

# Display green monospace text on solid black background
largetype "#!/bin/bash" --font-family monospace --color 00ff00 --background-color 000000ff

# Display red text on blue background
largetype "ERROR" --color ff0000 --background-color 0000ffaa

# Display bold text, left aligned, with percent padding
largetype "Big" --font-size 120 --font-weight bold --text-align left --padding 10%

# Display text and auto-hide after 3 seconds
largetype "Timed" --hide-after 3
```

