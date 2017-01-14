#SuperDepth3D
Depth Map Based 3D post-process shader v1.9.4 for Reshade 3.0

This Shader allows for Depth Map Based 3D like What Nvidia does with Compatibility Mode 3D and Kind of what TriDef Does with Power 3D. 

http://reshade.me/compatibility
At this link look for Depth Map Compatibility.

Game Depth Map list and settings.
https://github.com/BlueSkyDefender/Depth3D/blob/master/Game_Settings.txt

PLEASE SET YOUR RESOLUTION FIRST. Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted.

In-game Menu Settings
======================================================================================================================================

Shift + f2 for Reshade 3.0 menu

* Alternate Depth Map		[Depth Map 0 ▼]			[0|1|2|3|4|5|6|7|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26] Alternate Depth Map for Games. 
* Depth		               -[◄0▪▪▪▪▪▪▪30►]+			[0:30] Depth Default is 15. "Drag to Adjust Depth."
* Perspective	               -[◄▪▪▪▪0▪▪▪▪▪►]+			[-100:100] Perspective Default is 0. "Drag to Adjust Perspective."
* Depth_Limit	               -[◄▪▪▪▪1▪▪▪▪▪►]+			[0.750:1.0] Limits Depth Map Distance. "Drag to Adjust This limit."
* Blur Type			[Normal Blur ▼]			Pick the type of blur you want. Options are [Blur Off ▼] [Normal Blur ▼] [Radial Blur ▼]
* Blur		               -[◄▪0.05▪▪▪▪▪►]+			[0:25] Depth Map Blur Adjustment. Default is 0.050 zero is Off.
* Depth Map Enhancement		[Off ▼]				Enable Or Dissable Depth Map Enhancement.
* Adjust		       -[◄0.5▪▪1▪▪1.5►]+		Adjust DepthMap Enhancement, Dehancement occurs past one.
* Depth Map Clamp		[Off ▼]				Clamps Min and Max setting of Your Depth Map, you may want to turn this on if going pass 25 Depth.
* Depth Map View 		[Off ▼]				Depth Map View. To see The Depth map. Use This to Work on your Own Depth Map for your game.
* Depth Map Flip 		[Off ▼]				Depth Flip if Upside Down.
* Custom Depth Map		[Custom Off  ▼]			Added, the ablity to make your own Depth Map.
* Near Far		       -[◄▪▪N▪▪►]+ -[◄▪▪F▪▪►]+		Adjustment for Near and Far Depth Map Precision. For [Custom Number ▼]  
* 3D Display Mode		[Side by Side ▼]		Side by Side/Top and Bottom/Line Interlaced/Checkerboard 3D displays output. 
* Polynomial Barrel Distortion	[Off ▼]				Enables Barrel Distortion for HMD or if you want a sence of a little more depth.
* Polynomial Color Distortion	[R 255][G 255][B 255]		Adjust the Polynomial Distortion Red, Green, Blue.
* Horizontal Vertical Squish   -[◄0.5▪H▪2►]+ -[◄0.5▪V▪2►]+	Adjust Horizontal and Vertical squish cubic distortion value.
* Custom Sidebars		[Black Edges ▼]			Select the Edges of the screen. Options are [Mirrored Edges ▼] [Black Edges ▼] [Stretched Edges ▼] 
* Cross Cusor Size             -[◄0▪▪▪▪▪▪100►]+			Pick your size of the cross cusor.
* Cross Cusor Color		[R 255][G 255][B 255]		Cross Cusor Color.
* Eye Swap			[Off ▼]				Left Right Eye Swap.

Toggle Key B for Cross Cusor On/Off

// Change the Cross Cusor Key

// Determines the Cusor Toggle Key useing keycode info

// You can use http://keycode.info/ to figure out what key is what.

// key B is Key Code 66, This is Default. Ex. Key 187 is the code for Equal Sign =.
//On line 30

#define Cross_Cusor_Key 66

User Guides: 

Guide by [SkySolstice] "https://forums.geforce.com/default/topic/961597/oculus/play-3d-games-in-sbs-on-the-virtual-screen-using-bigscreen/"

Play 3D games in SBS on the virtual screen using BigScreen

1. Install Superdepth.fx to the program exe folder and the corresponding reshade 3 exe to link the dll.
2. Press Shift F2 to run the tutorial and setup for either SBS or Top Bottom.
3. Alt tab to Bigscreen and select the corresponding output you chose.
4. Alt tab back into game.