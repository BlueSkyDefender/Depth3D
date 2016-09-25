#SuperDepth3D
Depth Map Based 3D post-process shader v1.8.8 for Reshade 3.0

There are the Basic Depth maps you can use for your games listed and not listed. Look at this link for other game Compatibility.

This Mod alows for Depth Map Based 3D like What Nvidia does with Compatibility Mode 3D and Kind of what TriDef Does with Power 3D. 

http://reshade.me/compatibility
At this link look for Depth Map Compatibility.

Here is a quick and dirty game list of working Depth Maps. 

PLEASE SET YOUR RESOLUTION FIRST. Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted.

Game List updates for Reshade 3.0 Beta7
[Game List]				[Alternet Depth Map]	   [Depth Flip On][Read Below]	[Blur Recommendations]	[BSD Notes]
Alien Isolation				DM 0
Amnesia: The Dark Descent		DM 1
Among The Sleep				DM 2				DF On				
Assassin Creed Unity			DM 3							
Batman Arkham Knight			DM 4 or 6							0.01-0.050		
Batman Arkham Origins			DM 4							
Batman: Arkham City			DM 4							
BorderLands 2				DM 4						RB
Call of Duty: Advance Warfare		DM 5						RB		
Call of Duty: Black Ops 2		DM 5						RB		
Call of Duty: Ghost			DM 5						RB		
Casltevania: Lord of Shadows - UE	DM 6
Condemned: Criminal Origins		DM 7						RB		
Deadly Premonition:The Directors's Cut  DM 8						RB
Dragon Ball Xenoverse			DM 9											
Dragons Dogma: Dark Arisen		DM 8
DreamFall Chapters			DM 18		     		DF On
Dying Light				DM 11
Fallout 4				DM 0							
Firewatch				DM 0				DF On		RB				
GTA V					DM 12						RB		0.01-0.25	RB
Hard Reset				DM 4						RB
Lords of The Fallen			DM 4
Magicka 2				DM 13						RB
Metro 2033 Redux			DM 6						RB
Metro Last Light Redux			DM 6						RB
Middle-earth: Shadow of Mordor		DM 14						RB
Naruto Shippuden UNS3 Full Blurst	DM 15						RB
Quake 2 XP				DM 9							
Quake 4					DM 7
Rage64					DM 7						RB
Return To Castle Wolfenstine		DM 7						RB
Ryse: Son of Rome			DM 17
Shadow warrior(2013)			DM 16						RB
The Elder Scrolls V: Skyrim		DM 4							
Sleeping Dogs: DE			DM 18
Souls Games				DM 19
The Evil Within				DM 7						RB
Witcher 3				DM 20 or 14							0.00-0.10	RB
Zombi					DM 7
Warhammer: End Times - Vermintide	DM 10
Deus Ex: Mankind Divided		DM 21								0.050-0.1	RB
Dead Rising 3				DM 6								0.050-0.1
Soma					DM 2
Penumbra: Black Plague			DM 4						RB
NecroVision: Lost Company		DM 4
The Vanishing of Ethan Carter Redux	DM 3						RB
Cryostasis				DM 8
Silent Hill: Homecoming			DM 22
Monstrum DX11				DM 23				DF On		RB
Double Dragon Neon			DM 25
Zombie Army Trilogy			DM 8 or 4							0.0-0.050

Game List updates for Reshade 2.0
[Game List]				[Alternet Depth Map]	   [Depth Flip On][Read Below]	[Blur Recommendations]	[BSD Notes]
Serious Sam Revolution			DM 24


User Submitted Depth Map Settings

[Game List]				[Alternet Depth Map]	   [Depth Flip On]	[Blur Recommendations]
______________________________________________________________________________________________________________________________________

Homefront The Revolution 		DM 17
Mirror's Edge				DM 4
Need for Speed				DM 4

[zig11727] "https://forums.geforce.com/default/topic/959175/3d-vision/superdepth-3d/post/4963888/#4963888"
______________________________________________________________________________________________________________________________________

You can also try different depth maps for other games your self by changing AltDepthMap number From 0-20. 
You *may* want to disable AA in game. You can always enable SMAA in reshade for AA or play at 4k with no AA. 
Turn Off DOF in all games if possible. Unless you want to know how it feels to be neer sighted. Turn On SSAO or HABO They help a lot.

In-game Menu Settings
======================================================================================================================================

Shift + f2 for Reshade 3.0 menu

* Alternate Depth Map		[Depth Map 0 ▼]		[0|1|2|3|4|5|6|7|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23] Alternate Depth Map for different Games. 
* Depth		               -[◄0▪▪▪▪▪▪▪30►]+		[0:30] Depth Default is 10. "Drag to Adjust Perspective."
* Perspective	               -[◄▪▪▪▪0▪▪▪▪▪►]+		[-100:100] Perspective Default is 0. "Drag to Adjust Perspective."
* Blur		               -[◄▪0.05▪▪▪▪▪►]+		[0:25] Depth Map Blur Adjustment. Default is 0.050 zero is Off.
* Depth Flip	 		[Off ▼]			Depth Flip if Upside Down.
* Depth Map View 		[Off ▼]			Depth Map View. To see The Depth map. Use This to Work on your Own Depth Map for your game.
* Far		               -[◄▪▪▪▪▪▪▪▪▪▪►]+		Default is "0.05" Far Depth Map Adjustment. This works on  [Custom DM ▼] 
* Near		               -[◄▪▪▪▪▪▪▪▪▪▪►]+		Default is "1.25" Near Depth Map Adjustment. This works on [Custom DM ▼] 
* Custom Depth Map		[Custom Off  ▼]		Added, the ablity to make your own Depth Map.
* Barrel Distortion		[Off ▼]			Enables Barrel Distortion for HMD or if you want a sence of a little more depth.
* Horizontal Squish            -[◄0.5▪▪▪1▪▪▪▪2►]+	Squishes the screen horizontaly.
* Vertical Squish      	       -[◄0.5▪▪▪1▪▪▪▪2►]+	Vertical the screen horizontaly.
* 3D Display Mode		[Side by Side ▼]	Side by Side/Top and Bottom/Line Interlaced/Checkerboard 3D displays output.
* Polynomial Color Distortion	[R 255][G 255][B 255]	Red | Green | Blue distortion sliders.
* EyeSwap			[Off ▼]			Left Right Eye Swap.
* Cross Cusor Size             -[◄0▪▪▪▪▪▪100►]+		Pick your size of the cross cusor.
* Cross Cusor Color		[R 255][G 255][B 255]	Cross Cusor Color.

Toggle Key B for Cross Cusor On/Off

// Change the Cross Cusor Key

// Determines the Cusor Toggle Key useing keycode info

// You can use http://keycode.info/ to figure out what key is what.

// key B is Key Code 66, This is Default. Ex. Key 187 is the code for Equal Sign =.
//On line 30

#define Cross_Cusor_Key 66

______________________________________________________________________________________________________________________________________

Read Below Section
======================================================================================================================================

{BoarderLands 2}
Use a Controller for menus navigation or keyboard. 
Mouse and keyboard is good for gameplay. 


{Call of Duty: Advance Warfare}
Render Resolution Native.
Turn off AA.
Don't use in game Supersampling
FOV Sucks i know.

{Call of Duty: Ghost}
Set Image Quality to Extra.

{Call of Duty: Black Ops 2}
Turn off AA.

{Condemned: Criminal Origins}
Depth Buffer Drops time to time Also Dissable FSAA (FSAA OFF)

{Deadly Premonition}
Can Run with Higer Rez useing DPfix095.
To Use it with Reshade Just Start Up Reshade and Make a profile for it like any other game.

Then head to the folder and rename d3d9.dll to dxgi.dll. 
Now open the DPfix095.zip Directly from http://blog.metaclassofnil.com/wp-content/uploads/2013/12/DPfix095.zip or http://blog.metaclassofnil.com/?p=438.

Install the contents of that folder in to Deadly Premonition Folder where you changed Reshade's d3d9.dll to dxgi.dll. Edit the DPfix.ini too what ever REZ you want. Then start the game.

{Firewatch}
Issues in game with the shader Detoggling.

{GTA 5}
Rename the dxgi.dll too d3d11.dll for DX11 mode.
If the game is crashing in fullscreen. Switch over to Window or Borderless window mode.

{Hard Reset}
Must Enable FSAA for depth buffer access.

{Magicka 2} 
Rename the opengl.dll to dxgi.dll
Also Use a Controller for game play.

{Metro Last Light Redux}
Rename the d3d9.dll or dxgi.dll to d3d11.dll

{Metro 2033 Redux}
Rename the d3d9.dll or dxgi.dll to d3d11.dll

{Middle-earth: Shadow of Mordor}
3D only works if your game at 100% scaling and FullScreen mode. 
Borderless Full Screen will not work Window mode will not Work. 
So if you want to Play at a lower resolution, then set your windows resolution lower then run the game in full screen and set your scaling to 100%. 
Anything Lower or Higher then 100% will not work.

{Monstrum}
Start the game in DX11 mode.

{Naruto Shippuden UNS3 Full Blurst}
Ignore the warnings click play.

{Penumbra: Black Plague}
Go here
C:\Users\...\Documents\Penumbra\settings.cfg
Open the settings and set your res. 
<Screen Width="3840" Height="2160" FullScreen="true" Vsync="true" />

{Quake 4}
If some how you can click on the menu......... Good Luck.
Also if some how you get it working When the game Saves You have to recheck the 3D shader. 
This is where a Defaults.ini will come in handy.

{Rage}
Start the game with out Reshade Set your game resolution First Turn off AA. 
Exit, Then use reshade and set your setting you want then launch your game. You can not change your resolution once in game This sill remove the depth map.
Rage 64 was tested only.

{Return To Castle Wolfenstine}
Increase Depth to 25+ Do this by typing in your amount.
The game seems to run really slow with my shader at the start. 
This may be a problem with my old card.
But, Wait untill the frame rate stablizes. Then play the game.

Setting you want to change if you want to play at 4k.

Look in your config to see what you need to change. wolfconfig.cfg
Ex.
seta r_customaspect "1"

seta r_customheight "2160"

seta r_customwidth "3840"

seta r_fullscreen "1"

seta r_mode "-1"

{Skyrim V}
Antialiasing Must be set too 2 Samples or more in the Options.
Open your SkyrimPrefs.ini. Usually it should be found under %USERPROFILE%\Documents\My Games\Skyrim
Edit the indicated sections of the INI like so:

[Terrainmanager]
fBlockMaximumDistance=500000
fBlockLevel1Distance=140000
fBlockLevel0Distance=75000
fSplitDistanceMult=4.0

[MAIN]
fSkyCellRefFadeDistance=600000.0000

[Display]
bFloatPointRenderTarget=0
bDeferredShadows=0

{Shadow warrior(2013)}
Depth Buffer only in DX9 so launch it in Shadow Warrior XP and turn on FSAAX2 in game.

{The Evil With In}
Game too big for screen DPI scaling. 
To fix this go to where the program is installed and find the EXE

Steam\steamapps\common\TheEvilWithin
Right click the EvilWithin.exe
Go to Compatibility
Check Disable Display Scaling On High DPI Settings

This should fix it. For more look up this problem on google.

{The Vanishing of Ethan Carter Redux}

Instal Dll too D:\SteamLibrary\steamapps\common\The Vanishing of Ethan Carter Redux\EthanCarter\Binaries\Win64

______________________________________________________________________________________________________________________________________

User Guides: 

Guide by [SkySolstice] "https://forums.geforce.com/default/topic/961597/oculus/play-3d-games-in-sbs-on-the-virtual-screen-using-bigscreen/"

Play 3D games in SBS on the virtual screen using BigScreen

1. Install Superdepth.fx to the program exe folder and the corresponding reshade 3 exe to link the dll.
2. Press Shift F2 to run the tutorial and setup for either SBS or Top Bottom.
3. Alt tab to Bigscreen and select the corresponding output you chose.
4. Alt tab back into game.

--------------------------------------------------------------------------------------------------------------------------------------
-=BSD Notes=- Personal recommended settings and tips for some games.
______________________________________________________________________________________________________________________________________
*Witcher 3*
I noticed when playing this game that a blur setting of 0 is fine as long you can handle Depth setting from 0-30. If you want more
depth but you don't mind sacrificing detail then, override the depth limit and set it from for DM 20 30-40 and set your blur to 0.075-0.100.
That ever looks better too you. DM20 is not as strong as DM14. So the max I think for DM 14 is Depth 30.

*GTA V*
One of the few game where you can override the Depth Limit and run with a higher depth setting. I personaly run mine at 40 and a blur
setting of 0.025

*Deus Ex: Mankind Divided*
I know this game has a built in side by side. But, my head hurs when I use it.
The setting Use for this game for 4k are. Fullscreen not exclisive no Vsync. My preset is custom. Texture Quality Ultra you can set this
lower if you don't have that much GPU memory. Texture Filtering 16x and Shadow Qualty Medium. For AO I set it to ON If you have a good gpu 
set this to Very High. Contact Hard Shadows is set to off. Paralax also set to on. Dof off. Now Level of Detail I have this set too High...
any lower makes the game look bad you may want to set this Very High. Volumetic Lighting set too on. Screenspace Reflections set too on. 
Temporal AA check this ON even with out 3D this should be on. Motion Blur off. Sharpen I have it on I like it. Bloom This one good and bad.
Good as it gives the lighitng in game life but bad because it causes ghosting. I have it set to on I don't mind a little ghosting. 
Cloth Physics I have this set too off because my processor is weak. Subsurface Scattering I like the look it has on people. Tessellation on.
I use a blur of 0.075 and depth 30 or depth 25 and blur 0.050.


______________________________________________________________________________________________________________________________________

Games Not working in Reshade 3.0 Use Reshade 2.0
======================================================================================================================================
crosire's ReShade version '3.0.0.81' corsire is working on this game for the next update for 3.0

{Wolfenstine The New Order} - not working in Reshade 3.0
[Set Launch Options](+r_multisamples "0" +vt_maxaniso "16")
This game must be started at the lower Resoution 1600x1200 Then Switch to 1920x1080. Befor you exit switch it back to 1600x1200. 
Note if you want to 4k It the same process Start the game at 1600x1200 then switch it to 3840x2160.
Also note you can't switch back. So say you Start the game at 1600x1200 then switch to 4k then back too 1600x1200 it will not work. 
If you change it one last time to 4k It will not work. You must restart your game for eatch change of resolution.
You can always enable SMAA in reshade for AA or play at 4k with no AA.

In order to completely disable DOF:

“open up graphicsprofiles.json and find the postprocessdof line and change high and ultra to 0.” \SteamLibrary\steamapps\common\Wolfenstein.The.New.Order\base\graphicsprofiles.json

Should look like this;
Ex.
"r_postProcessDofMode" : 
	{ 
		"low" : 0,
		"mid" : 0,
		"high" : 0,
		"ultra" : 0
	},
______________________________________________________________________________________________________________________________________
Also Keep in mind if you don't like the depth map I made. You can alawys make your own.
