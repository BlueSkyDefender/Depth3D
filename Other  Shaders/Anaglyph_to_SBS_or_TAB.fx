/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Anaglyph_to_SBS_or_TAB.fx
 *
 * Based on and inspired by the RetroArch/libretro shader:
 *   anaglyph-to-sbs.glsl from the libretro/glsl-shaders collection.
 *   Upstream collection: https://github.com/libretro/glsl-shaders
 *
 * This file is distributed under the GNU GPL v3 (or later).
 * Include a copy of the GPL license text (e.g. LICENSE or COPYING) when distributing.
 *
 * ReShade port + modifications/rewrites and added features (SBS/TAB packing, aspect handling,
 * multiple anaglyph schemes, intensity blending, extra output modes) by: Effie Colton, 2026.
 */

#include "ReShade.fxh"

// -------------------- UI PARAMETERS --------------------

// IMPORTANT: ReShade combo ints are 0-based indices.
// We store 0..5, then do scheme = anaglyph_mode + 1 in shader logic.
uniform int anaglyph_mode <
    ui_label = "Anaglyph Mode";
    ui_type  = "combo";
    ui_items =
        "Red/Cyan\0"
        "Red/Green\0"
        "Red/Blue\0"
        "Green/Magenta\0"
        "Amber/Blue\0"
        "Magenta/Cyan\0";
    ui_min = 0; ui_max = 5;
> = 0;

uniform int force_layout <
    ui_label = "Force Layout";
    ui_type  = "combo";
    ui_items =
        "Composite (both eyes combined)\0"
        "Side-by-Side (Left|Right)\0"
        "Side-by-Side Swap (Right|Left)\0"
        "Top-and-Bottom (Top over Bottom)\0"
        "Top-and-Bottom Swap (Bottom over Top)\0";
    ui_min = 0; ui_max = 4;
> = 0;

uniform int force_aspect <
    ui_label = "Force Aspect";
    ui_type  = "combo";
    ui_items =
        "Full (normal)\0"
        "Top-and-Bottom only (treat output height as half)\0"
        "Side-by-Side only (treat output width as half)\0";
    ui_min = 0; ui_max = 2;
> = 0;

uniform float h_sep <
    ui_label = "Horizontal Separation";
    ui_type  = "slider";
    ui_min = -1.0; ui_max = 1.0;
    ui_step = 0.001;
> = 0.0;

uniform float v_sep <
    ui_label = "Vertical Separation";
    ui_type  = "slider";
    ui_min = -1.0; ui_max = 1.0;
    ui_step = 0.001;
> = 0.0;

// moved to sit directly above Zoom
uniform int zoom_center_mode <
    ui_label = "Zoom Center";
    ui_type  = "combo";
    ui_items =
        "Global (center of whole output)\0"
        "Per-view (center of each SBS/TAB pane)\0";
    ui_min = 0; ui_max = 1;
> = 0;

uniform float ana_zoom <
    ui_label = "Zoom";
    ui_type  = "slider";
    ui_min = 0.25; ui_max = 4.0;
    ui_step = 0.005;
> = 1.0;

uniform float WIDTH <
    ui_label = "Stretch X";
    ui_type  = "slider";
    ui_min = 0.25; ui_max = 4.0;
    ui_step = 0.005;
> = 1.0;

uniform float HEIGHT <
    ui_label = "Stretch Y";
    ui_type  = "slider";
    ui_min = 0.25; ui_max = 4.0;
    ui_step = 0.005;
> = 1.0;

uniform float intensity <
    ui_label = "Filter Intensity";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 1.0;
    ui_step = 0.01;
> = 1.0;

uniform int output_mode <
    ui_label = "Output";
    ui_type  = "combo";
    ui_items =
        "Lens (filtered colour)\0"
        "Mono (grayscale)\0"
        "Red (debug)\0"
        "Desat (partially desaturated)\0"
        "Luma (custom weights)\0";
    ui_min = 0; ui_max = 4;
> = 0;


// -------------------- ADVANCED: LUMA WEIGHTS --------------------
// Single collapsible section. You get Global (both eyes), Left, Right.

uniform float LumaW_R <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Global (both eyes) - Red weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.2126;

uniform float LumaW_G <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Global (both eyes) - Green weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.7152;

uniform float LumaW_B <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Global (both eyes) - Blue weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.0722;

uniform float LumaL_R <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Left eye - Red weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.2126;

uniform float LumaL_G <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Left eye - Green weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.7152;

uniform float LumaL_B <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Left eye - Blue weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.0722;

uniform float LumaR_R <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Right eye - Red weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.2126;

uniform float LumaR_G <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Right eye - Green weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.7152;

uniform float LumaR_B <
    ui_category = "Advanced: Luma Weights";
    ui_label = "Right eye - Blue weight";
    ui_type  = "slider";
    ui_min = 0.0; ui_max = 2.0;
    ui_step = 0.0001;
> = 0.0722;


// -------------------- BACKBUFFER --------------------

texture BackBufferTex : COLOR;
sampler BackBufferSampler { Texture = BackBufferTex; };


// -------------------- HELPERS --------------------

float snap_to_step(float x, float step) { return floor(x / step + 0.5) * step; }
float clamp01(float x) { return saturate(x); }

float3 normalize_weights(float3 w)
{
    float s = w.x + w.y + w.z;
    if (s <= 1e-6) return float3(0.2126, 0.7152, 0.0722);
    return w / s;
}

float3 get_luma_w(int whichEyeView) // 0=left view, 1=right view
{
    // Global base (used in composite path)
    float3 wg = normalize_weights(float3(LumaW_R, LumaW_G, LumaW_B));

    // Per-eye weights (used in packed SBS/TAB path)
    if (whichEyeView == 0) return normalize_weights(float3(LumaL_R, LumaL_G, LumaL_B));
    if (whichEyeView == 1) return normalize_weights(float3(LumaR_R, LumaR_G, LumaR_B));
    return wg;
}

float luma_of(float3 rgb, float3 w) { return dot(rgb, w); }

float4 sample_safe(float2 uv)
{
    if (uv.x <= 0.0 || uv.x >= 1.0 || uv.y <= 0.0 || uv.y >= 1.0)
        return 0.0.xxxx;
    return tex2D(BackBufferSampler, uv);
}

float2 fit_inside(float2 uv, float srcAsp, float dstAsp)
{
    float2 p = uv - 0.5;
    if (dstAsp > srcAsp) p.x *= (dstAsp / srcAsp);
    else                 p.y *= (srcAsp / dstAsp);
    return p + 0.5;
}

float2 apply_zoom_stretch(float2 uv, float z, float sx, float sy)
{
    uv = (uv - 0.5) * z + 0.5;
    uv = (uv - 0.5) * float2(sx, sy) + 0.5;
    return uv;
}

// Scheme-specific mono intensity (matches filter pairing) + luma fallback
float eye_intensity(float4 s, int scheme, int whichFilterEye, float3 w)
{
    if (scheme == 1) return (whichFilterEye == 0) ? s.r : (s.g + s.b) * 0.5;               // R/C
    if (scheme == 2) return (whichFilterEye == 0) ? s.r : s.g;                             // R/G
    if (scheme == 3) return (whichFilterEye == 0) ? s.r : s.b;                             // R/B
    if (scheme == 4) return (whichFilterEye == 0) ? s.g : (s.r + s.b) * 0.5;               // G/M
    if (scheme == 5) return (whichFilterEye == 0) ? (s.r + s.g) * 0.5 : s.b;               // Amber/B
    if (scheme == 6) return (whichFilterEye == 0) ? (s.r + s.b) * 0.5 : (s.g + s.b) * 0.5; // M/C
    return luma_of(s.rgb, w);
}

// “Lens” filtered RGB for the scheme (no intensity blending here)
float3 filter_view(float4 s, int scheme, int whichFilterEye, float3 w)
{
    if (scheme == 1) return (whichFilterEye == 0) ? float3(s.r,0,0)     : float3(0,s.g,s.b); // R/C
    if (scheme == 2) return (whichFilterEye == 0) ? float3(s.r,0,0)     : float3(0,s.g,0);   // R/G
    if (scheme == 3) return (whichFilterEye == 0) ? float3(s.r,0,0)     : float3(0,0,s.b);   // R/B
    if (scheme == 4) return (whichFilterEye == 0) ? float3(0,s.g,0)     : float3(s.r,0,s.b); // G/M
    if (scheme == 5) return (whichFilterEye == 0) ? float3(s.r,s.g,0)   : float3(0,0,s.b);   // Amber/B
    if (scheme == 6) return (whichFilterEye == 0) ? float3(s.r,0,s.b)   : float3(0,s.g,s.b); // M/C

    float m = eye_intensity(s, scheme, whichFilterEye, w);
    return m.xxx;
}

float3 desaturate(float3 rgb, float k, float3 w)
{
    float l = luma_of(rgb, w);
    return lerp(rgb, l.xxx, clamp01(k));
}


// -------------------- PIXEL SHADER --------------------

float4 PS_AnaglyphToSBSorTAB(float4 pos : SV_Position, float2 uv_in : TEXCOORD) : SV_Target
{
    float2 outSz = float2(BUFFER_WIDTH, BUFFER_HEIGHT);

    float srcAsp  = outSz.x / max(outSz.y, 1.0);
    float fullAsp = srcAsp;

    int fa = force_aspect;
    float dstAsp = fullAsp;
    if (fa == 1) dstAsp = fullAsp * 2.0;
    if (fa == 2) dstAsp = fullAsp * 0.5;

    float2 uv = fit_inside(uv_in, srcAsp, dstAsp);

    float z  = snap_to_step(ana_zoom, 0.005);
    float sx = snap_to_step(WIDTH,    0.005);
    float sy = snap_to_step(HEIGHT,   0.005);

    float pxX = 1.0 / max(outSz.x, 1.0);
    float pxY = 1.0 / max(outSz.y, 1.0);

    float h = snap_to_step(h_sep * 0.5, pxX);
    float v = snap_to_step(v_sep * 0.5, pxY);

    // scheme is 1..6, UI gives 0..5
    int scheme = clamp(anaglyph_mode + 1, 1, 6);

    int outm   = output_mode;
    int lay    = force_layout;

    bool wantSBS = (lay == 1 || lay == 2);
    bool wantTAB = (lay == 3 || lay == 4);

    // Both axes affect both eyes
    float2 dL = float2(-h, -v);
    float2 dR = float2( h,  v);

    float t = clamp01(intensity);

    // ----- packed layouts -----
    if (lay != 0)
    {
        int whichEyeView = 0; // 0=left view pane, 1=right view pane
        float2 localUV = uv;

        // decide pane & remap to 0..1 without wrapping/tiling
        if (wantSBS)
        {
            float x2 = localUV.x * 2.0;
            if (x2 <= 0.0 || x2 >= 2.0) return 0.0.xxxx;

            int pane = (x2 >= 1.0) ? 1 : 0;
            localUV.x = x2 - (float)pane;

            whichEyeView = pane;
            if (lay == 2) whichEyeView = 1 - whichEyeView;
        }
        else
        {
            float y2 = localUV.y * 2.0;
            if (y2 <= 0.0 || y2 >= 2.0) return 0.0.xxxx;

            int pane = (y2 >= 1.0) ? 1 : 0;
            localUV.y = y2 - (float)pane;

            whichEyeView = pane;
            if (lay == 4) whichEyeView = 1 - whichEyeView;
        }

        // zoom behavior
        if (zoom_center_mode == 0)
        {
            float2 uv_g = apply_zoom_stretch(uv, z, sx, sy);
            localUV = uv_g;

            // re-run pane mapping on zoomed UV
            if (wantSBS)
            {
                float x2 = localUV.x * 2.0;
                if (x2 <= 0.0 || x2 >= 2.0) return 0.0.xxxx;

                int pane = (x2 >= 1.0) ? 1 : 0;
                localUV.x = x2 - (float)pane;

                whichEyeView = pane;
                if (lay == 2) whichEyeView = 1 - whichEyeView;
            }
            else
            {
                float y2 = localUV.y * 2.0;
                if (y2 <= 0.0 || y2 >= 2.0) return 0.0.xxxx;

                int pane = (y2 >= 1.0) ? 1 : 0;
                localUV.y = y2 - (float)pane;

                whichEyeView = pane;
                if (lay == 4) whichEyeView = 1 - whichEyeView;
            }
        }
        else
        {
            localUV = apply_zoom_stretch(localUV, z, sx, sy);
        }

        // disparity samples
        float4 sL = sample_safe(localUV + dL);
        float4 sR = sample_safe(localUV + dR);

        float4 sView = (whichEyeView == 0) ? sL : sR;
        int    whichFilterEye = whichEyeView;

        float3 wE = get_luma_w(whichEyeView);

        float3 masked = filter_view(sView, scheme, whichFilterEye, wE);
        float3 lens   = lerp(sView.rgb, masked, t);

        if (outm == 0) return float4(lens, 1.0);
        if (outm == 3) return float4(desaturate(lens, 0.60, wE), 1.0);
        if (outm == 4) return float4(luma_of(lens, wE).xxx, 1.0);

        float mono_unf = luma_of(sView.rgb, wE);
        float mono_sch = eye_intensity(sView, scheme, whichFilterEye, wE);
        float mono     = lerp(mono_unf, mono_sch, t);

        if (outm == 2) return float4(mono, 0.0, 0.0, 1.0);
        return float4(mono.xxx, 1.0);
    }

    // ----- composite output -----
    uv = apply_zoom_stretch(uv, z, sx, sy);

    float4 sL = sample_safe(uv + dL);
    float4 sR = sample_safe(uv + dR);

    float3 wG = normalize_weights(float3(LumaW_R, LumaW_G, LumaW_B));

    float3 avg = (sL.rgb + sR.rgb) * 0.5;

    float3 maskedSum = filter_view(sL, scheme, 0, wG) + filter_view(sR, scheme, 1, wG);
    float3 lensSum   = lerp(avg, maskedSum, t);

    if (outm == 0) return float4(lensSum, 1.0);
    if (outm == 3) return float4(desaturate(lensSum, 0.60, wG), 1.0);
    if (outm == 4) return float4(luma_of(lensSum, wG).xxx, 1.0);

    float mono_unf = luma_of(avg, wG);
    float mono_sch = (eye_intensity(sL, scheme, 0, wG) + eye_intensity(sR, scheme, 1, wG)) * 0.5;
    float mono     = lerp(mono_unf, mono_sch, t);

    if (outm == 2) return float4(mono, 0.0, 0.0, 1.0);
    return float4(mono.xxx, 1.0);
}

technique Anaglyph_to_SBS_or_TAB
{
    pass
    {
        VertexShader = PostProcessVS;
        PixelShader  = PS_AnaglyphToSBSorTAB;
    }
}
