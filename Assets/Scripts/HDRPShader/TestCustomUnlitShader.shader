Shader "Custom/Unlit/TestCustomUnlitShader"
{
    Properties
    {
        _Tess ("Tessellation", Range(1,32)) = 4
        _MainTex ("Texture", 2D) = "white" {}
       [Enum(None, 0, Tessellation displacement, 3)] _DisplacementMode("DisplacementMode", Int) = 3
        [ToggleUI] _DisplacementLockObjectScale("displacement lock object scale", Float) = 1.0
        [ToggleUI] _DisplacementLockTilingScale("displacement lock tiling scale", Float) = 1.0
        [ToggleUI] _DepthOffsetEnable("Depth Offset View space", Float) = 0.0

        [Enum(None, 0, Phong, 1)] _TessellationMode("Tessellation mode", Float) = 0
        _TessellationFactorC("Tessellation Factor", Range(0.0, 64.0)) = 4.0
        _TessellationFactorMinDistanceC("Tessellation min fading distance", Float) = 20.0
        _TessellationFactorMaxDistanceC("Tessellation max fading distance", Float) = 50.0
        _TessellationFactorTriangleSize("Tessellation triangle size", Float) = 100.0
        _TessellationShapeFactor("Tessellation shape factor", Range(0.0, 100.0)) = 0.75 // Only use with Phong
        _TessellationBackFaceCullEpsilon("Tessellation back face epsilon", Range(-1.0, 0.0)) = -0.25
        _WorldSpaceCameraPosC("camera pos", vector) = (10,10,10)
    }
    HLSLINCLUDE
    #pragma target 5.0
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

    //-------------------------------------------------------------------------------------
    // Variant
    //-------------------------------------------------------------------------------------

    #pragma shader_feature_local _ALPHATEST_ON
    // #pragma shader_feature_local _DEPTHOFFSET_ON
    // #pragma shader_feature_local _DOUBLESIDED_ON
    // #pragma shader_feature_local _ _TESSELLATION_DISPLACEMENT _PIXEL_DISPLACEMENT
    // #pragma shader_feature_local _VERTEX_DISPLACEMENT_LOCK_OBJECT_SCALE
    // #pragma shader_feature_local _DISPLACEMENT_LOCK_TILING_SCALE
    // #pragma shader_feature_local _PIXEL_DISPLACEMENT_LOCK_OBJECT_SCALE
    // #pragma shader_feature_local _VERTEX_WIND
    // #pragma shader_feature_local _TESSELLATION_PHONG
    // #pragma shader_feature_local _ _REFRACTION_PLANE _REFRACTION_SPHERE

    // #pragma shader_feature_local _ _EMISSIVE_MAPPING_PLANAR _EMISSIVE_MAPPING_TRIPLANAR
    // #pragma shader_feature_local _ _MAPPING_PLANAR _MAPPING_TRIPLANAR
    // #pragma shader_feature_local _NORMALMAP_TANGENT_SPACE
    // #pragma shader_feature_local _ _REQUIRE_UV2 _REQUIRE_UV3

    // #pragma shader_feature_local _NORMALMAP
    // #pragma shader_feature_local _MASKMAP
    // #pragma shader_feature_local _BENTNORMALMAP
    // #pragma shader_feature_local _EMISSIVE_COLOR_MAP
    // #pragma shader_feature_local _ENABLESPECULAROCCLUSION
    // #pragma shader_feature_local _HEIGHTMAP
    // #pragma shader_feature_local _TANGENTMAP
    // #pragma shader_feature_local _ANISOTROPYMAP
    // #pragma shader_feature_local _DETAIL_MAP
    // #pragma shader_feature_local _SUBSURFACE_MASK_MAP
    // #pragma shader_feature_local _THICKNESSMAP
    // #pragma shader_feature_local _IRIDESCENCE_THICKNESSMAP
    // #pragma shader_feature_local _SPECULARCOLORMAP
    // #pragma shader_feature_local _TRANSMITTANCECOLORMAP

    // #pragma shader_feature_local _DISABLE_DECALS
    // #pragma shader_feature_local _DISABLE_SSR
    // #pragma shader_feature_local _ENABLE_GEOMETRIC_SPECULAR_AA

    // // Keyword for transparent
    // #pragma shader_feature _SURFACE_TYPE_TRANSPARENT
    // #pragma shader_feature_local _ _BLENDMODE_ALPHA _BLENDMODE_ADD _BLENDMODE_PRE_MULTIPLY
    // #pragma shader_feature_local _BLENDMODE_PRESERVE_SPECULAR_LIGHTING
    // #pragma shader_feature_local _ENABLE_FOG_ON_TRANSPARENT

    // // MaterialFeature are used as shader feature to allow compiler to optimize properly
    // #pragma shader_feature_local _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
    // #pragma shader_feature_local _MATERIAL_FEATURE_TRANSMISSION
    // #pragma shader_feature_local _MATERIAL_FEATURE_ANISOTROPY
    // #pragma shader_feature_local _MATERIAL_FEATURE_CLEAR_COAT
    // #pragma shader_feature_local _MATERIAL_FEATURE_IRIDESCENCE
    // #pragma shader_feature_local _MATERIAL_FEATURE_SPECULAR_COLOR

    // enable dithering LOD crossfade
    #pragma multi_compile _ LOD_FADE_CROSSFADE

    //enable GPU instancing support
    #pragma multi_compile_instancing
    #pragma instancing_options renderinglayer

    //-------------------------------------------------------------------------------------
    // Define
    //-------------------------------------------------------------------------------------
    //这个定义是必须的，否则将会报错
    #define TESSELLATION_ON
    //#define USING_STEREO_MATRICES

    // This shader support vertex modification
    // #define HAVE_VERTEX_MODIFICATION
    #define HAVE_TESSELLATION_MODIFICATION
    #define SHADEROPTIONS_CAMERA_RELATIVE_RENDERING (0)

    // If we use subsurface scattering, enable output split lighting (for forward pass)
    #if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) && !defined(_SURFACE_TYPE_TRANSPARENT)
    #define OUTPUT_SPLIT_LIGHTING
    #endif

    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"

    // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/VaryingMesh.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/VertMesh.hlsl"
    // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
    // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/TessellationShare.hlsl"
    // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"
    // //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TessellationShare.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariablesFunctions.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitProperties.hlsl"
    // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

    //-------------------------------------------------------------------------------------
    // Include
    //-------------------------------------------------------------------------------------

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Wind.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitProperties.hlsl"
    #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderConfig.cs.hlsl"

    ENDHLSL
    SubShader
    {
        Tags{ "RenderPipeline"="HDRenderPipeline" "RenderType" = "HDLitShader" }
        LOD 100
        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "Forward" } // This will be only for transparent object based on the RenderQueue index

            Stencil
            {
                WriteMask [_StencilWriteMask]
                Ref [_StencilRef]
                Comp Always
                Pass Replace
            }

            Blend [_SrcBlend] [_DstBlend]
            // In case of forward we want to have depth equal for opaque mesh
            ZTest [_ZTestDepthEqualForOpaque]
            ZWrite [_ZWrite]
            Cull [_CullModeForward]

            HLSLPROGRAM

            #pragma multi_compile _ DEBUG_DISPLAY
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // Setup DECALS_OFF so the shader stripper can remove variants
            #pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
            
            // Supported shadow modes per light type
            #pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH SHADOW_VERY_HIGH

            #pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST

            #define SHADERPASS SHADERPASS_FORWARD
            #define HAVE_TESSELLATION_MODIFICATION
            // // In case of opaque we don't want to perform the alpha test, it is done in depth prepass and we use depth equal for ztest (setup from UI)
            // // Don't do it with debug display mode as it is possible there is no depth prepass in this case
            // #if !defined(_SURFACE_TYPE_TRANSPARENT) && !defined(DEBUG_DISPLAY)
            //     #define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST
            // #endif
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"


        // #ifdef DEBUG_DISPLAY
        //     #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Debug/DebugDisplay.hlsl"
        // #endif

            // The light loop (or lighting architecture) is in charge to:
            // - Define light list
            // - Define the light loop
            // - Setup the constant/data
            // - Do the reflection hierarchy
            // - Provide sampling function for shadowmap, ies, cookie and reflection (depends on the specific use with the light loops like index array or atlas or single and texture format (cubemap/latlong))

            #define HAS_LIGHTLOOP

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
            //Vert shader and Frag shader include in this library
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForward.hlsl"

            #pragma vertex Vert
            #pragma fragment MyFrag
            #pragma hull MyHull
            #pragma domain MyDomain
            float _TessellationFactorC;
            float _TessellationFactorMaxDistanceC;
            float _TessellationFactorMinDistanceC;

            float4 MyGetTessellationFactors(float3 p0, float3 p1, float3 p2, float3 n0, float3 n1, float3 n2)
            {
                float3 camearRWS = _WorldSpaceCameraPos;//GetPrimaryCameraPosition();
                float3 distFactor = GetDistanceBasedTessFactor(p0, p1, p2, camearRWS, _TessellationFactorMinDistanceC, _TessellationFactorMaxDistanceC);  // Use primary camera view
                float3 factor = distFactor * distFactor * 5 * _TessellationFactorC;
                factor = max(factor, float3(1.0, 1.0, 1.0));
                return CalcTriTessFactorsFromEdgeTessFactors(factor);
            }

            // operates once per patch to generate edge tessellation factors
            TessellationFactors MyHullConstant(InputPatch<PackedVaryingsToDS, 3> input)
            {
                VaryingsToDS varying0 = UnpackVaryingsToDS(input[0]);
                VaryingsToDS varying1 = UnpackVaryingsToDS(input[1]);
                VaryingsToDS varying2 = UnpackVaryingsToDS(input[2]);

                float3 p0 = varying0.vmesh.positionRWS;
                float3 p1 = varying1.vmesh.positionRWS;
                float3 p2 = varying2.vmesh.positionRWS;

                float3 n0 = varying0.vmesh.normalWS;
                float3 n1 = varying1.vmesh.normalWS;
                float3 n2 = varying2.vmesh.normalWS;


                _TessellationFactor = _TessellationFactorC;
                // ref: http://reedbeta.com/blog/tess-quick-ref/
                // x - 1->2 edge
                // y - 2->0 edge
                // z - 0->1 edge
                // w - inside tessellation factor
                //GetTessellationFactors is defined in LitDataMeshModification.hlsl
                float4 tf = MyGetTessellationFactors(p0, p1, p2, n0, n1, n2);
                TessellationFactors output;
                output.edge[0] = min(tf.x, MAX_TESSELLATION_FACTORS);
                output.edge[1] = min(tf.y, MAX_TESSELLATION_FACTORS);
                output.edge[2] = min(tf.z, MAX_TESSELLATION_FACTORS);
                output.inside  = min(tf.w, MAX_TESSELLATION_FACTORS);

                return output;
            }



            [maxtessfactor(MAX_TESSELLATION_FACTORS)]//
            [domain("tri")]//domain type
            [partitioning("fractional_odd")]//partition type
            [outputtopology("triangle_cw")]//
            [patchconstantfunc("MyHullConstant")]//determine patch-constant phase function
            [outputcontrolpoints(3)]//output contol points count
            PackedVaryingsToDS MyHull(InputPatch<PackedVaryingsToDS, 3> input, uint id : SV_OutputControlPointID)
            {
                // Pass-through
                return input[id];
            }

            [domain("tri")]
            PackedVaryingsToPS MyDomain(TessellationFactors tessFactors, const OutputPatch<PackedVaryingsToDS, 3> input, float3 baryCoords : SV_DomainLocation)
            {
                VaryingsToDS varying0 = UnpackVaryingsToDS(input[0]);
                VaryingsToDS varying1 = UnpackVaryingsToDS(input[1]);
                VaryingsToDS varying2 = UnpackVaryingsToDS(input[2]);

                VaryingsToDS varying = InterpolateWithBaryCoordsToDS(varying0, varying1, varying2, baryCoords);

                // We have Phong tessellation in all case where we don't have displacement only
                // #ifdef _TESSELLATION_PHONG

                //     float3 p0 = varying0.vmesh.positionRWS;
                //     float3 p1 = varying1.vmesh.positionRWS;
                //     float3 p2 = varying2.vmesh.positionRWS;

                //     float3 n0 = varying0.vmesh.normalWS;
                //     float3 n1 = varying1.vmesh.normalWS;
                //     float3 n2 = varying2.vmesh.normalWS;
                //     //GetPrimaryCameraPosition is defined in shadervariablesfunction.hlsl
                //     float tessellationFactor = _TessellationFactor;
                //     varying.vmesh.positionRWS = PhongTessellation(varying.vmesh.positionRWS,p0,p1,p2,n0,n1,n2,baryCoords,tessellationFactor);

                //     // varying.vmesh.positionRWS = PhongTessellation(  varying.vmesh.positionRWS,
                //     //                                                 p0, p1, p2, n0, n1, n2,
                //     //                                                 baryCoords, _TessellationShapeFactor);

                // #endif

                // float3 p0 = varying0.vmesh.positionRWS;
                // float3 p1 = varying1.vmesh.positionRWS;
                // float3 p2 = varying2.vmesh.positionRWS;

                // float3 n0 = varying0.vmesh.normalWS;
                // float3 n1 = varying1.vmesh.normalWS;
                // float3 n2 = varying2.vmesh.normalWS;
                // //GetPrimaryCameraPosition is defined in shadervariablesfunction.hlsl
                // float tessellationFactor = _TessellationFactor;
                // varying.vmesh.positionRWS = PhongTessellation(varying.vmesh.positionRWS,p0,p1,p2,n0,n1,n2,baryCoords,tessellationFactor);
                // varying.vmesh.positionRWS = GetDistanceBasedTessFactor(p0,p1,p2,GetPrimaryCameraPosition(),
                //                                                             _TessellationFactorMinDistance,
                //                                                             _TessellationFactorMaxDistance);
                float3 edgefactor = float3(1.0,1.0,1.0);
                //varying.vmesh.positionRWS = GetScreenSpaceTessFactor( p0, p1, p2, _ViewProjMatrix, _ScreenSize, _TessellationShapeFactor);
                #ifdef HAVE_TESSELLATION_MODIFICATION
                    
                    ApplyTessellationModification(varying.vmesh, varying.vmesh.normalWS, varying.vmesh.positionRWS);
                #endif


                // float3 camposRW = float3(_WorldSpaceCameraPosC.x,_WorldSpaceCameraPosC.y,_WorldSpaceCameraPosC.z);//GetPrimaryCameraPosition();
                // varying.vmesh.positionRWS = GetDistanceBasedTessFactor(p0,p1,p2,camposRW,
                //                                                         _TessellationFactorMinDistance,
                //                                                         _TessellationFactorMaxDistance);
                return VertTesselation(varying);
            }

            float4 MyFrag(PackedVaryingsToPS packedInput) : SV_Target0{
                 return float4(1,1,1,1);
            }
            ENDHLSL
        }

        // Pass
        // {
        //     Name "Forward"
        //     Tags { "LightMode" = "Forward" }
        //     HLSLPROGRAM

        //     #define SHADERPASS SHADERPASS_DEPTH_ONLY
        //     #define SCENESELECTIONPASS // This will drive the output of the scene selection shader
        //     //#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitDepthPass.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
        //     #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassDepthOnly.hlsl"

        //     #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/VertMesh.hlsl"

        //     #pragma vertex Vert
        //     #pragma fragment Frag

        //     #pragma vertex:disp tessellate:tessFixed
        //     // make fog work
        //     #pragma multi_compile_fog
        //     #pragma target 5.0
        //     //#include "Tessellation.cginc"
        //     //#include "UnityCG.cginc"

        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //         float2 uv : TEXCOORD0;
        //     };

        //     struct v2f
        //     {
        //         float2 uv : TEXCOORD0;
        //         //UNITY_FOG_COORDS(1)
        //         float4 vertex : SV_POSITION;
        //     };

        //     float _Tess;
        //     //tessellation function
        //     // float4.xyz declare degree of division
        //     // float4.w declare the rate
        //     float4 tessFixed()
        //     {
        //         return _Tess;
        //     }

        //     sampler2D _MainTex;
        //     float4 _MainTex_ST;

        //     // v2f vert (appdata v)
        //     // {
        //     //     v2f o;
        //     //     o.vertex = UnityObjectToClipPos(v.vertex);
        //     //     o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        //     //     UNITY_TRANSFER_FOG(o,o.vertex);
        //     //     return o;
        //     // }

        //     // fixed4 frag (v2f i) : SV_Target
        //     // {
        //     //     // sample the texture
        //     //     fixed4 col = tex2D(_MainTex, i.uv);
        //     //     // apply fog
        //     //     UNITY_APPLY_FOG(i.fogCoord, col);
        //     //     return col;
        //     // }
        //     ENDHLSL
        // }
    }
}
