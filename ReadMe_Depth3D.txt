#SuperDepth3D
Depth Map Based 3D post-process shader v1.9.8 for Reshade 3.0 WIP

This Shader allows for Depth Map Based 3D like What Nvidia does with Compatibility Mode 3D and Kind of what TriDef Does with Power 3D. 

http://reshade.me/compatibility
At this link look for Depth Map Compatibility.

Game Depth Map list and settings.
https://github.com/BlueSkyDefender/Depth3D/blob/master/Game_Settings.txt

PLEASE SET YOUR RESOLUTION FIRST. Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted

#Polynomial Barrel Distortion 
Polynomial Barrel Distortion v1.2 Is an barrel distortion for HMD type Displays For SuperDepth3D.
Shader order is important when using PBD shader with SuperDepth3D. Make sure this is last.
Ex.
Cross_Cursor
Depth3D
Polynomial_Barrel_Distortion_M

### In-shader Settings
======================================================================================================================================
// Determines The resolution of the Depth Map. For 4k Use 1.75 or 1.5. For 1440p Use 1.5 or 1.25. For 1080p use 1. Too low of a resolution will remove too much.
#define Depth_Map_Division 1.0

// Determines The Max Depth amount. The larger the amount harder it will hit on FPS will be.
#define Depth_Max 50

// Enable this to fix the problem when there is a full screen Game Map Poping out of the screen. AKA Full Black Depth Map Fix. I have this off by default. Zero is off, One is On.
#define FBDMF 0

// BOTW Fix WIP
#define AADM 0

### In-game Menu Settings
======================================================================================================================================

Shift + f2 for Reshade 3.0 menu

## Basic 3D Settings Section

* Alternate Depth Map 	      [Depth Map 0 ▼]         [0-40] Alternate Depth Map for Games. 
* Depth                      -[◄0▪▪▪▪▪▪▪50►]+         Depth Default is 15. "Drag to Adjust Depth." You can enter what ever you want.
* Perspective                -[◄-100▪▪▪100►]+         [-100:100] Perspective Default is 0. "Drag to Adjust Perspective."
* Disocclusion Type           [Disocclusion Mask ▼]   Pick the type of disocclusion you want. Options are [Off ▼] [Normal ▼] [Radial ▼]

## Depth Map Adjust Section
* Depth Map View              [Off ▼]                 Depth Map View. To see The Depth map.
* Depth Map Flip              [Off ▼]                 Depth Flip if Upside Down.
* Custom Depth Map            [Custom Off  ▼]         Added, the ablity to make your own Depth Map.
* Near Far                   -[◄▪▪N▪▪►]+ -[◄▪▪F▪▪►]+  Adjustment for Near and Far Depth Map Precision. For [Custom Number ▼]

## Weapon Depth Map Section
* Weapon Depth Map            [Weapon Depth Map Off ▼]Weapon depth map for games. [Custom Weapon Depth Map One - Four ▼] & [WDM 1-23 ▼]
* Weapon_Adjust              -[◄▪▪▪▪0▪▪▪▪►]+          Adjust weapon depth map.For [Custom Weapon Depth Map Number ▼]
                             -[◄▪▪▪0.25▪▪►]+
                             -[◄▪▪1.001▪▪►]+ 
* Weapon_Percentage          -[◄▪▪▪0.5▪▪▪►]+          Adjust weapon percentage. Default is 5.0 For [Custom Weapon Depth Map Number ▼]
* Weapon Distance Correction -[◄▪▪▪▪0▪▪▪▪►]+          For adjusting the distance of the weapon in the depth map.

## 3D Display Mode Ouput Section
* 3D Display Mode             [Side by Side ▼]        [Side by Side ▼][Top & Bottom ▼][Line Interlaced ▼][Checkerboard ▼][Anaglyph ▼]
* Downscaling Support         [Native ▼]              [Native ▼][Option One ▼][Option Two ▼]
* Anaglyph Colors             [Red/Cyan ▼]            [Red/Cyan ▼][Dubois Red/Cyan ▼][Green/Magenta ▼][Dubois Green/Magenta ▼]
* Anaglyph Desaturation      -[◄▪▪▪▪▪▪1.0►]+          Adjust anaglyph desaturation, Zero is Black & White, One is full color.
* Custom Sidebars             [Black Edges ▼]         Select [Mirrored Edges ▼] [Black Edges ▼] or [Stretched Edges ▼]. 
* Eye Swap                    [Off ▼]                 Left Right Eye Swap.

User Guides: 

Guide by [SkySolstice] "https://forums.geforce.com/default/topic/961597/oculus/play-3d-games-in-sbs-on-the-virtual-screen-using-bigscreen/"

Play 3D games in SBS on the virtual screen using BigScreen

1. Install Superdepth.fx to the program exe folder and the corresponding reshade 3 exe to link the dll.
2. Press Shift F2 to run the tutorial and setup for either SBS or Top Bottom.
3. Alt tab to Bigscreen and select the corresponding output you chose.
4. Alt tab back into game.
