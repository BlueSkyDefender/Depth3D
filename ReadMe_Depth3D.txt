#SuperDepth3D
Depth Map Based 3D post-process shader v2.3.2+ for Reshade 3.0+

This Shader allows for Depth Map Based 3D like What Nvidia does with Compatibility Mode 3D and TriDef's Power 3D. But, with better control than 
the unleashed modification. Along with profiles for many games so you don't have to work to hard. Now with more compatibility then any other application.

http://reshade.me/compatibility 
Look at this link for Basic Depth Map Compatibility. There are way more mods and games that work now then what's on this list. So Test the game to see if it works.

Depth 3D Settings and Game Help for stuborn games.
https://github.com/BlueSkyDefender/Depth3D/blob/master/Shaders/Game_Help.txt

Depth3D VR Companion App 
Free software that lets you play the games you already own in your VR HMD.

### In-game Menu Settings
======================================================================================================================================
Shift + f2 for ReShade 3.0 menu and the HOME key for ReShade 4.0+

## Divergence & Convergence
* Divergence                 -[◄10▪▪▪▪▪▪▪▪50►]+       Divergence increases differences between the L & R images. Increasing this allows you to experience more depth.
* Zero Parallax Distance     -[◄0▪▪▪▪▪▪▪0.25►]+       ZPD controls the focus distance for the screen Pop-out effect also known as Convergence.
* ZPD Auto-Balance           -[◄0▪▪▪▪▪▪▪▪▪▪5►]+       Automatically Balance between ZPD Depth and Scene Depth.    
* ZPD Boundary Detection      [Off ▼]                 This treats your screen as a virtual wall & scales ZPD down when detected. [Off ▼] [Normal ▼] [Third Person ▼] [FPS Full ▼] [FPS Narrow ▼]
* ZPD Boundary & Fade Time   -[◄▪▪0.5►]+ -[◄▪0.25▪►]+ This selection menu gives extra boundary conditions to scale ZPD & lets you adjust Fade time of this effect.

## Occlusion Masking
* Edge Handling               [Black Edges ▼]         Edges selection for your screen output. Select Between [Mirrored Edges ▼] [Black Edges ▼] or [Stretched Edges ▼].
* Edge Mask                  -[◄-0.125▪▪▪1.5►]+       Use this to adjust for artifacts from a lower resolution depth buffer.
* Performance Mode            [ ]                     Performance Mode Lowers Occlusion Quality Processing so that there is a small boost to FPS.

## Depth Map
* Depth Map Selection         [DM0 Normal ▼]          This sets zBuffer linearization. [DM0 Normal ▼] [DM1 Reversed ▼]
* Depth Map Adjustment       -[◄▪7.5▪▪▪▪▪▪▪►]+        This allows for you to adjust the zBuffer precision on the fly.
* Depth Map Offset           -[◄0.0▪▪▪▪▪▪▪▪►]+        Depth Map Offset is for non conforming ZBuffer. Most of the time leave this alone.
* Auto Depth Adjust          -[◄▪0.100▪▪▪▪▪►]+        Automatically scales depth so it fights out of game menu pop out.
* Depth Detection             [Off ▼]                 Use this to disable/enable in game Depth Buffer Detection.[Off ▼] [Detection +Sky ▼] [Detection -Sky ▼] [ReShade's Detection ▼]
* Depth Map View              [Off ▼]                 Use this for debugging depth related issues.
* Depth Map Flip              [ ]                     Flip the depth map if it is upside down.

## Weapon Hand Adjust
* Weapon Profiles             [WP Off ▼]              Pick Weapon Profile for your game or make your own. [Custom WP ▼] & [WP 0-75 ▼]
* Weapon Hand Adjust         -[◄▪0▪►][◄▪0▪►][◄▪0▪►]+  Adjust Weapon depth map for your games. [X CutOff Point] [Y Precision] [Z Tuning]
* Weapon ZPD and Near Depth  -[◄▪0.3▪►][◄▪0.0▪►]+     X Controls the focus distance for the screen Pop-out effect also known as Convergence for the weapon hand. Y is used for Tuning this without precision.
* FPS Focus Depth             [Off ▼]                 This lets the shader handle real time depth reduction for aiming down your sights. [Off ▼] [Press ▼] [Hold ▼] 
* Weapon Boundary Detection  -[◄0.0▪▪▪▪▪▪▪▪►]+        This selection menu gives extra boundary conditions to WZPD. It fights Weapon Pop out.

## Stereoscopic Options
* 3D Display Mode             [Side by Side ▼]        Stereoscopic 3D display output selection. [Side by Side ▼][Top & Bottom ▼][Line Interlaced ▼][Checkerboard ▼][Anaglyph ▼]
* Interlace & Anaglyph       -[◄▪0.5▪►][◄▪1.0▪►]+     Interlace Optimization is used to reduce aliasing in a Line or Column interlaced image. Anaglyph Desaturation allows for removing color from an anaglyph 3D image.
* Downscaling Support         [SR Native ▼]           Dynamic Super Resolution scaling support for. [SR 2160p A ▼] [SR 2160p B ▼] [SR 1080p A ▼] [SR 1080p B ▼] [SR 1050p A ▼] [SR 1050p B ▼] [SR 720p A ▼] [SR 720p B ▼]
* Perspective                -[◄▪▪▪▪▪0▪▪▪▪▪►]+        Determines the perspective point of the two images this shader produces. [-100:100]
* Eye Swap                    [ ]                     Left Right Eye Swap.

## Cursor Adjustments
* Cursor Selection            [Off ▼]                 Choose the cursor type you like to use for game type. [FPS ▼] [ALL ▼] [RTS ▼]
* Cursor Adjustments         -[◄0▪▪▪▪▪▪▪▪▪10►]+       This controlls the X Size & Y Color.
* Cursor Lock                 [ ]                     Screen Cursor to Screen Crosshair Lock. Once this is on you can use Mouse 4 to toggle it.

### Alternative Options
## Divergence & Convergence
* ZPD Balance                -[◄0▪▪▪▪▪▪▪▪1.0►]+       Balances between ZPD Depth and Scene Depth manually.  
    
## Reposition Depth
* Z Horizontal & Vertical    -[◄▪▪▪▪▪1.0▪▪▪▪►]+       Adjust Horizontal and Vertical Resize.     
* Z Position                 -[◄▪▪▪▪▪▪0▪▪▪▪▪►]+       Adjust the Image Position if it's off by a bit.     
* Alinement View              [ ]                     A Guide to help aline the Depth Buffer to the Image.

## Heads-Up Display
* HUD Mode                   -[◄▪0.0▪►][◄▪0.5▪►]+     Adjust HUD for your games. [X CutOff Point] [Y ZPD]

## Distortion Corrections
Distortion Options            [On ▼]                  Use this to Turn Off, Turn On, & to use the BD Alinement Guide.
Barrel Distortion K1 K2 K3   -[◄▪0▪►][◄▪0▪►][◄▪0▪►]+  Adjust Distortions K1, K2, & K3
Barrel Distortion Zoom       -[◄-0.5▪▪▪0.5►]+         Adjust Barrel Distortion Zoom
Toggle Barrel Distortion      [ ]                     Use this if you modded the game to remove Barrel Distortion.

### In-shader Settings
======================================================================================================================================
//This enables the older SuperDepth3D method of producing an 3D image. This is better for older systems that have an hard time running the new mode.
//Also use this if you like the look of the old mode.
#define Legacy_Mode 0 //Zero is off and One is On.

// Zero Parallax Distance Balance Mode allows you to switch control from manual to automatic and vice versa.
#define Balance_Mode 0 //Default 0 is Automatic. One is Manual.

// RE Fix is used to fix the issue with Resident Evil's 2 Remake 1-Shot cutscenes.
#define RE_Fix 0 //Default 0 is Off. One is On.

// Change the Cancel Depth Key. Determines the Cancel Depth Toggle Key using keycode info
// The Key Code for Decimal Point is Number 110. Ex. for Numpad Decimal "." Cancel_Depth_Key 110
#define Cancel_Depth_Key 0 // You can use http://keycode.info/ to figure out what key is what.

// Rare Games like Among the Sleep Need this to be turned on.
#define Invert_Depth 0 //Default 0 is Off. One is On.

// Barrel Distortion Correction For SuperDepth3D for non conforming BackBuffer.
#define BD_Correction 0 //Default 0 is Off. One is On.

// Horizontal & Vertical Depth Buffer Resize for non conforming DepthBuffer.
// Also used to enable Image Position Adjust is used to move the Z-Buffer around.
#define DB_Size_Postion 0 //Default 0 is Off. One is On.

// Auto Letter Box Correction
#define LB_Correction 0 //Default 0 is Off. One is On.

// HUD Mode is for Extra UI MASK and Basic HUD Adjustments. This is useful for UI elements that are drawn in the Depth Buffer.
// Such as the game Naruto Shippuden: Ultimate Ninja, TitanFall 2, and or Unreal Gold 277. That have this issue. This also allows for more advance users
// Too Make there Own UI MASK if need be.
// You need to turn this on to use UI Masking options Below.
#define HUD_MODE 0 // Set this to 1 if basic HUD items are drawn in the depth buffer to be adjustable.

// -=UI Mask Texture Mask Interceptor=- This is used to set Two UI Masks for any game. Keep this in mind when you enable UI_MASK.
// You Will have to create Three PNG Textures named DM_Mask_A.png & DM_Mask_B.png with transparency for this option.
// They will also need to be the same resolution as what you have set for the game and the color black where the UI is.
// This is needed for games like RTS since the UI will be set in depth. This corrects this issue.
#if ((exists "DM_Mask_A.png") || (exists "DM_Mask_B.png"))
	#define UI_MASK 1
#else
	#define UI_MASK 0
#endif
// To cycle through the textures set a Key. The Key Code for "n" is Key Code Number 78.
#define Set_Key_Code_Here 0 // You can use http://keycode.info/ to figure out what key is what.
// Texture EX. Before |::::::::::| After |**********|
//                    |:::       |       |***       |
//                    |:::_______|       |***_______|
// So :::: are UI Elements in game. The *** is what the Mask needs to cover up.
// The game part needs to be transparent and the UI part needs to be black.

// The Key Code for the mouse is 0-4 key 1 is right mouse button.
#define Cursor_Lock_Key 4 // Set default on mouse 4
#define Fade_Key 1 // Set default on mouse 1
#define Fade_Time_Adjust 0.5625 // From 0 to 1 is the Fade Time adjust for this mode. Default is 0.5625;

// Delay Frame for instances the depth bufferis 1 frame behind useful for games that need "Copy Depth Buffer
// Before Clear Operation," Is checked in the API Depth Buffer tab in ReShade.
#define D_Frame 0 //This should be set to 0 most of the times this will cause latency by one frame.

//Text Information Key Default F11
#define Text_Info_Key 122

-=:[Mouse Pointer]:=-
---------------------------------------------------------------------------------------------------------------------------------
I can alter the size of your Mouse Pointer by going here.
http://www.rw-designer.com/cursor-set/smalldot

More info: First, you would need to enable the CrossCursor in Depth3D

Now from here the only thing I can think about is using a program called YoloMouse and Modifying/Adding a custom tiny little cursor.
You Can Get it here.
pandateemo.github.io/YoloMouse/
You have to make a Tiny Little Mouse Cursor So It's Not Distracting. You can even make multiple for different units. 
Like a Little X, a little Dot, or a little crosshair.
You can make it with www.rw-designer.com/online-cursor-editor
image 1
https://cdn.discordapp.com/attachments/458063532567691284/574848158731862020/unknown.png
Once you make it, rename it to one of the built-in cur files for Yolo Mouse. ex: "1.cur"
image 2
https://cdn.discordapp.com/attachments/458063532567691284/574849534945919007/unknown.png
This will NOT solve your problem 100%, But it will mitigate it.

I hope this helps.
_________________________________________________________________________________________________________________________________