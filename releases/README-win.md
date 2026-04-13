# Galactic Clash — Windows build

This folder contains the recommended workflow and usage notes for Windows builds.

How to create a Windows build (quick):

1. Install Godot 4.7 editor and matching Export Templates.
   - In the Godot editor: Project -> Install Export Templates...

2. (Optional) Set `GODOT_EXE` environment variable to your Godot executable path.
   - PowerShell example:
     ```powershell
     $env:GODOT_EXE = 'C:\Program Files\Godot\Godot_v4.7-stable_win64.exe'
     ```

3. Run the included `build.bat` from the project root (requires PowerShell for zipping):
   ```powershell
   .\build.bat
   ```

What the script does:
- Calls Godot CLI to export the preset named "Windows Desktop" into `build\Windows\`.
- Creates `releases\GalacticClash-win64.zip` containing whatever is in `build\Windows` (.exe and .pck).

If the export produces an `.exe` plus a `.pck` file, both will be included in the ZIP — this is normal.

Troubleshooting:
- If export fails, open Godot, verify your Export Preset is named exactly "Windows Desktop" and that Export Templates are installed.
- To avoid SmartScreen warnings for collaborators, consider code-signing the executable (commercial certificate required).

Sharing with collaborators:
- Send `releases\GalacticClash-win64.zip`.
- Add a short note: "Unzip and run GalacticClash.exe on Windows x64."
