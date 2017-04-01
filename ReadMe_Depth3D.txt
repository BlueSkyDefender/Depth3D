#SuperDepth3D
Depth Map Based 3D post-process shader v1.9.5 for Reshade 3.0 WIP

This Shader allows for Depth Map Based 3D like What Nvidia does with Compatibility Mode 3D and Kind of what TriDef Does with Power 3D. 

http://reshade.me/compatibility
At this link look for Depth Map Compatibility.

Game Depth Map list and settings.
https://github.com/BlueSkyDefender/Depth3D/blob/master/Game_Settings.txt

PLEASE SET YOUR RESOLUTION FIRST. Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted.

In-game Menu Settings
======================================================================================================================================

Shift + f2 for Reshade 3.0 menu

* Alternate Depth Map	[Depth Map 0 ▼]			  [0|1|2|3|4|5|6|7|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35] Alternate Depth Map for Games. 
* Depth		           -[◄0▪▪▪▪▪▪▪30►]+			  Depth Default is 15. "Drag to Adjust Depth." You can enter what ever you want.
* Perspective	       -[◄▪▪▪▪0▪▪▪▪▪►]+			  [-100:100] Perspective Default is 0. "Drag to Adjust Perspective."
* Disocclusion Type		[Disocclusion Mask ▼]	Pick the type of disocclusion you want. Options are [Off ▼] [Normal ▼] [Radial ▼]
* Depth Map View 		  [Off ▼]               Depth Map View. To see The Depth map. Use This to Work on your Own Depth Map for your game.
* Depth Map Flip 		  [Off ▼]               Depth Flip if Upside Down.
* Custom Depth Map		[Custom Off  ▼]       Added, the ablity to make your own Depth Map.
* Near Far		       -[◄▪▪N▪▪►]+ -[◄▪▪F▪▪►]+Adjustment for Near and Far Depth Map Precision. For [Custom Number ▼]  
* 3D Display Mode		  [Side by Side ▼]      Side by Side/Top and Bottom/Line Interlaced/Checkerboard 3D displays output. 
* Custom Sidebars		  [Black Edges ▼]       Select the Edges of the screen. Options are [Mirrored Edges ▼] [Black Edges ▼] [Stretched Edges ▼] 
* Eye Swap				    [Off ▼]               Left Right Eye Swap.
* Ambient Occlusion   [AO x8 ▼]             Ambient Occlusion settings AO x8 is On. Default is On. Options are [Off ▼] and [AO x8 ▼]
* SSAO Power         -[◄▪▪▪▪0.5▪▪▪▪►]+      Power AO on Depth Map from 0.375 to 0.625 lower is stronger. Default is 0.500
* Spread             -[◄▪▪▪▪1.5▪▪▪▪►]+      Spread is AO Falloff. Default is 1.5

Depth_Map_Division Determines The size of the Depth Map. For 4k Use 2 or 2.5. For 1440p Use 1.5 or 2. For 1080p use 1.
To edit this open up the shader and change this number

#define Depth_Map_Division 2.0

User Guides: 

Guide by [SkySolstice] "https://forums.geforce.com/default/topic/961597/oculus/play-3d-games-in-sbs-on-the-virtual-screen-using-bigscreen/"

Play 3D games in SBS on the virtual screen using BigScreen

1. Install Superdepth.fx to the program exe folder and the corresponding reshade 3 exe to link the dll.
2. Press Shift F2 to run the tutorial and setup for either SBS or Top Bottom.
3. Alt tab to Bigscreen and select the corresponding output you chose.
4. Alt tab back into game.
