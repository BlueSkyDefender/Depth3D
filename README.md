### **Post-Process shaders for ReShade**
### Highlighted Shaders for ReShade
**SuperDepth3D**<br />
This shader allows for depth map-based 3D, similar to what NVIDIA offers with Compatibility Mode 3D and what TriDef does with Power 3D. SuperDepth3D provides much more control and support for different devices.

Output formats include Side by Side, Top and Bottom, Line Interlaced, Column Interlaced, Checkerboard, Quad Lightfield, Anaglyph, TriOviz Inficolor emulation, and 2D+Depth. There is a Virtual Reality mode for OpenXR headsets and a Theater mode for phone VR and AR glasses.

[Shader Adjustments - the full option reference](https://github.com/BlueSkyDefender/Depth3D/wiki/Shader-Adjustments)<br />
[Basic Install](https://github.com/BlueSkyDefender/Depth3D/wiki/Basic-Install)

### Shader Assistant
**Overwatch.fxh**<br />
Overwatch is a companion tool designed to enhance your experience with SuperDepth3D by automatically setting depth and 3D configurations in many games. It simplifies setup so you can spend less time tweaking and more time enjoying immersive gameplay.

It now carries profiles for well over nine hundred titles, plus emulator profiles for PCSX2, CEMU, Yuzu, Ryujinx, Project64, Xenia and N64 Recompiled. When a profile loads, the shader tells you so at the top of its menu and sets depth, convergence, boundary detection and weapon-hand handling for you - so leave the ZPD and Depth Map options alone and just play.

Honestly, this is where your donations make a real difference. They help me improve and expand Overwatch, making it smarter and compatible with more titles. Less hassle, more fun for everyone.

### Easy Install
**GPU Selector**<br />

GPU Selector deploys ReShade, Depth3D and the Depth3D add-ons for you, so you do not have to run the ReShade setup wizard by hand for every game. Pick a ReShade version, set the Build Type to Full Add-on Support, deploy the Depth3D card, and you are done - Overwatch.fxh comes with it, so games with a profile are already configured.

It also handles the step people most often get wrong: **when the Enhanced Generic Depth add-on is deployed to a game, GPU Selector automatically disables the built-in Generic Depth in ReShade.ini**, so the two never fight over the depth buffer.

Its Inject Mode is a real alternative where a normal ReShade install cannot work at all - UWP and Microsoft Store games, titles with file integrity checks, EAC-protected games, and Wine/Linux. It can also force a game onto a specific GPU, which on hybrid laptops and dual-GPU desktops is often what makes the depth buffer show up in the first place.

Download: https://github.com/BlueSkyDefender/GPUSelector/releases<br />
Documentation: https://blueskydefender.github.io/GPUSelector/<br />
[GPU Selector - deploying Depth3D](https://github.com/BlueSkyDefender/Depth3D/wiki/GPU-Selector)

### Generic Depth Mod
**GDM Add-on**<br />

Enhanced automatic depth buffer detection, built on ReShade's own depth detection add-on.

Some engines do not hand ReShade a clean depth buffer. Unreal pads the depth allocation and renders the scene into a sub-rect of it; upscalers like DLSS, FSR and XeSS move that sub-rect around every time you change a quality setting. Without help, SuperDepth3D has to work out where the picture actually is by looking at it. GDM tells it exactly, every frame.

It can also supply a **separate weapon-hand depth buffer**, which removes the per-game CutOff Point tuning that first-person games normally need.

Requires ReShade with add-on support. Two preprocessor switches in the shader control it - `GDM_DEPTH_AUTOFIT` (on by default, and harmless without the add-on) and `GDM_WEAPON_DEPTH`.

Get it from the Discord, or deploy it from the Depth3D card in GPU Selector, which also turns off ReShade's built-in Generic Depth for you. There is no public download page for it.<br />
[Generic Depth Mod - setup and options](https://github.com/BlueSkyDefender/Depth3D/wiki/Generic-Depth-Mod)

### Game Compatibility
**Game Compatibility Information**

https://www.pcgamingwiki.com/wiki/ReShade#Compatibility_list
At this link look for Depth Map Compatibility.
This should work for Both AMD/Nividia GPUs.

If a game has no Overwatch profile the shader will say so. There is a video walkthrough, [Depth3D Profile Guide Basic](https://www.youtube.com/playlist?list=PLwNAyizu5NBtbpTzs6BoV4SoJNFfEQpI-), which builds a normal profile from start to finish in five parts. The [Shader Adjustments](https://github.com/BlueSkyDefender/Depth3D/wiki/Shader-Adjustments) page covers the same ground in writing. Profiles are welcome - turn on `Profiler_Mode` in the shader and send them my way.

### Licensing

**For hardware makers**<br />

Depth3D is free for personal use, but it is not open source and it is not free to ship inside a product. If you build a display, glasses, a handheld or a headset and want Depth3D on it, contact me directly. There is no reseller or agency for this.

[Licensing](https://blueskydefender.github.io/Depth3D/licensing.html)

I am also open to receiving hardware to work against. Getting 3D right on a device is far easier with the device in hand.

### Contact & Donation Links

**Want to leave me a message?:** BlueSkyDefender<br />
Also my steam page https://steamcommunity.com/id/BlueSkyDefender<br />

**Want to leave me a message or talk to me?:** BlueSkyDefender<br />
Discord Server https://discord.gg/W2f7YhX<br />

**About the developer:** [BlueSkyDefender](https://blueskydefender.github.io/Depth3D/about.html)

**Want to donate?:**
If you enjoyed these shaders and like to donate you can do so at https://www.buymeacoffee.com/BlueSkyDefender
