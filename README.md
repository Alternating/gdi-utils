Compatibility Lists (looking for saved presets to add to this archive) 
Start here - https://docs.google.com/spreadsheets/d/1-I8SkhBr5cNHcXZYPw9zsjQr0vKxePjvLsfvtgqzYf4/edit?gid=0#gid=0
Backup settings to test - https://docs.google.com/spreadsheets/d/1i4zpnJkf5mlEeypdcN-ve9Fm7euKOH7Lwerzq9_LdP8/edit?gid=1719450497#gid=1719450497

# Dreamcast GDI Image Batch Converter

A comprehensive solution for converting Dreamcast GDI images from redump.org format to General GDI format compatible with Optical Drive Emulators like GDEMU.

## Features

- Batch processing of multiple Dreamcast GDI images
- Intelligent detection of previously processed games
- Detailed logging of conversion process
- Automatic optimization of converted images
- Audio notifications for successful or failed operations

## Requirements

- Windows 10/11
- PowerShell 5.1 or higher
- Node.js installed and accessible from command line
- GDI-utils package properly installed and compiled

## Installation

1. Place all files in a single directory:
   - `BulkGDIConverter.ps1` (PowerShell script)
   - `RunGDIConverter.bat` (Batch launcher)
   - `gdiopt-v2.exe` (GDI optimizer utility)

2. Ensure GDI-utils is properly installed with the compiled index.js file accessible.

3. Update the default paths in `RunGDIConverter.bat` to match your environment:

```batch
set SOURCE_PATH=M:\Games2\Dreamcast
set DEST_PATH=M:\Games
set GDI_UTILS_PATH=C:\Users\YourUsername\Documents\gdi-utils\bin\bin-nodejs\index.js
```

## Usage

1. Double-click `RunGDIConverter.bat` to start the conversion process.
2. Accept the default paths or enter custom paths when prompted.
3. The script will:
   - Scan source directory for game folders
   - Skip already processed games
   - Convert new games to General GDI format
   - Run optimization on all processed games
   - Create a detailed log file in the destination directory
   - Play a sound notification based on the result

## Audio Notifications

- `chimes.wav` (C:\Windows\Media\chimes.wav) - Played when conversion completes successfully
- `chord.wav` (C:\Windows\Media\chord.wav) - Played when errors occur or no files are processed

## Log File

A log file named `conversion_log.txt` is created in the destination directory, containing:
- List of all folders processed and skipped
- Details of any errors encountered
- Summary statistics of the conversion process

## Workflow

1. **Initial Setup**: Configure paths in the batch file
2. **First Run**: Process all existing games
3. **Subsequent Runs**: Only new games will be processed, with existing ones skipped
4. **Verification**: Check the log file to confirm successful processing

## Troubleshooting

- Ensure Node.js is properly installed and accessible from command line
- Verify that GDI-utils is correctly compiled and the path to index.js is correct
- Check that source and destination paths exist and are accessible
- Examine the log file for detailed error information

## Directory Structure

Recommended structure for optimal operation:

```
C:\Users\YourUsername\Documents\gdi-utils\
├── BulkGDIConverter.ps1
├── RunGDIConverter.bat
├── gdiopt-v2.exe
└── bin\
    └── bin-nodejs\
        └── index.js (GDI-utils compiled output)
```

## Notes

- The source directory should contain folders with GDI images in redump.org format
- Each game folder should contain a .gdi file along with its associated track files
- The script creates temporary processing folders that are automatically cleaned up
- The GDI optimizer improves compatibility with various ODE devices

---

This tool significantly streamlines the process of preparing Dreamcast games for use with modern ODE solutions, saving time and ensuring consistent results across large game collections.

# GDI-Utils
A converter for converting GDI image in redump.org format to General GDI image format.

## Changelog
* 2017.Jul.23: Finished general gdi image format writer.

## Introduction
This converter convert Sega Dreamcast GDI image released in redump.org format to General GDI format.

## Technical Detail
### Terminology
* General GDI format represents gdi image set dumped with httpd-ack and used in Tosec and Trurip dumps. Pause data is striped.
* Redump.org GDI represent GDI image set dumped and released by redump.org. Pause and PreGap data are embedded in track file. That's 150 sectors(2 seconds) for audio track, 225 sectors(3 seconds) for the last split data track.

### Detail
Redump.org GDI and General GDI share with the same file extention name ".gdi". That's a file similiar but simpler than ".cue" file widely used in CD-ROM image to identify track filenames and track location in a whole disc layout.

But redump.org gdi image has several difference compare to the general gdi format.
* Indentation white space in ".gdi" file.
* Pause data is embedded in audio track file.
* For games with split data track(more than 4 tracks and last data track is after another audio track), the last data track contains 75 sectors(1 second) of PreGap Data which is stored in the tail of its previous audio track in general gdi format, and 150 sectors(2 seconds) of Pause Data just like audio tracks. 
* Different track start LBA values caused by the above 2 differences.
  
### Manual conversion guide
* For game with only 3 tracks(The Pattern I type in official document):

    Remove the heading 150 sectors from track 2 in low density area and add 150 to its track LBA value in ".gdi" file.
    
* For game with more than 3 tracks and the last track is an audio track(The Pattern II type in official document):

    Remove the heading 150 sectors from all audio track and add 150 of its track LBA value in ".gdi" file.
    
* For game with more than 3 tracks and the last track is a data track(The Pattern III type in official document):

    * Remove the heading 150 sectors from all audio track and add 150 to its track LBA value in ".gdi" file.
    * Copy the heading 75 sectors from the last data track and append them to the last audio track.
    * Remove the heading 225 sectors from the last data track.
    * Add 225 to the LBA value of last data track in ".gdi" file.
    
### Tools based conversion guide
* Check the Usage section in this ReadMe file. 

## Usage
1. Install Node.js runtime environment for your OS([https://nodejs.org](https://nodejs.org), 6.x LTS version is enough).
2. Open terminal or console with node.js envrionment initialized and do the following steps.
3. Update NPM(`sudo npm update -g npm`).
4. Install Typescript compiler in your OS(`npm install -g typescript`).
5. Open terminal and git clone this project(`git clone https://github.com/SONIC3D/gdi-utils.git`).
6. Change working directory to project root(`cd gdi-utils`). 
7. Run `npm install` to install all required components for compiling.
8. Run `npm run build` to build this project.
9. Run `node bin/bin-nodejs/index.js` to see the help 
10. Run `node bin/bin-nodejs/index.js <your_gdiimage_dir>/input.gdi 0 <output_dir>` to do conversion.

## Testing target
I have tested this tool with games list below.
After the conversion, games can be boot with ODE like GDEmu.
* Fushigi no Dungeon - Furai no Shiren Gaiden - Jokenji Asuka Kenzan! (Japan)
* King of Fighters, The - Dream Match 1999 (Japan) (En,Ja,Es,Pt)
