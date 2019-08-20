Shader "Custom/Lit/TestCustomLitShader"
{
    Properties
    {
        _Tess("Tessellation factor",Range(2,50)) = 4
        _MainTex ("Texture", 2D) = "white" {}
        _TessellationFactorMinDistanceC("_TessellationFactorMinDistance",Float) = 10
        _TessellationFactorMaxDistanceC("_TessellationFactorMaxDistance",Float) = 50
    }

    HLSLINCLUDE
    #pragma target 5.0
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
    //#define UNITY_STEREO_MULTIVIEW_ENABLED
    //#define Max3 max3
    #define TESSELLATION_ON

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
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
            Tags { "LightMode" = "Forward" }


            HLSLPROGRAM

            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // Setup DECALS_OFF so the shader stripper can remove variants
            
            // Supported shadow modes per light type
            #pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH SHADOW_VERY_HIGH

            #pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST

            #define SHADERPASS SHADERPASS_FORWARD
            #define HAVE_TESSELLATION_MODIFICATION
            // #endif
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"

            //#define HAS_LIGHTLOOP
            #pragma multi_compile HAS_LIGHTLOOP

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"

            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/ShaderPass/LitSharePass.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitData.hlsl"
            //Vert shader and Frag shader include in this library, and include any library that tessellation required 
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPassForward.hlsl"

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma hull MyHull
            #pragma domain MyDomain

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Tess;
            float _TessellationFactorMinDistanceC;
            float _TessellationFactorMaxDistanceC;

            //
            float4 MyGetTessellationFactors(float3 p0, float3 p1, float3 p2, float3 n0, float3 n1, float3 n2)
            {
                float3 camearRWS = _WorldSpaceCameraPos;//GetPrimaryCameraPosition();
                float3 distFactor = GetDistanceBasedTessFactor(p0, p1, p2, camearRWS, _TessellationFactorMinDistanceC, _TessellationFactorMaxDistanceC);  // Use primary camera view
                float3 factor = distFactor * distFactor * _Tess;
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

                float3 edgefactor = float3(1.0,1.0,1.0);
                #ifdef HAVE_TESSELLATION_MODIFICATION
                    
                    ApplyTessellationModification(varying.vmesh, varying.vmesh.normalWS, varying.vmesh.positionRWS);
                #endif
                return VertTesselation(varying);
            }
            // hlsl中自定义了每个阶段的输入输出结构，之前cg中的结构在这里不能使用
            // v2f vert (appdata v)
            // {
            //     v2f o;
            //     o.vertex = TransformObjectToHClip(v.vertex);
            //     o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            //     //UNITY_TRANSFER_FOG(o,o.vertex);
            //     return o;
            // }
            PackedVaryingsType vert(AttributesMesh inputMesh)
            {
                VaryingsType varyingsType;
                varyingsType.vmesh = VertMesh(inputMesh);

                return PackVaryingsType(varyingsType);
            }

            // float4 frag (v2f i) : SV_Target
            // {
            //     // sample the texture
            //     float4 col = tex2D(_MainTex, i.uv);
            //     return col;
            // }

            void frag(PackedVaryingsToPS packedInput,
                        out float4 outColor : SV_Target0,  // outSpecularLighting
                        out float4 outDiffuseLighting : SV_Target1)
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(packedInput);
                FragInputs input = UnpackVaryingsMeshToFragInputs(packedInput.vmesh);

                // We need to readapt the SS position as our screen space positions are for a low res buffer, but we try to access a full res buffer.
                input.positionSS.xy = _OffScreenRendering > 0 ? (input.positionSS.xy * _OffScreenDownsampleFactor) : input.positionSS.xy;

                uint2 tileIndex = uint2(input.positionSS.xy) / GetTileSize();
                // input.positionSS is SV_Position
                PositionInputs posInput = GetPositionInput_Stereo(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, tileIndex, unity_StereoEyeIndex);

                float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
                SurfaceData surfaceData;
                BuiltinData builtinData;
                GetSurfaceAndBuiltinData(input, V, posInput, surfaceData, builtinData);

                BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);

                PreLightData preLightData = GetPreLightData(V, posInput, bsdfData);

                outColor = float4(0.0, 0.0, 0.0, 0.0);
                {
                    uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_OPAQUE;
                    float3 diffuseLighting;
                    float3 specularLighting;

                    LightLoop(V, posInput, preLightData, bsdfData, builtinData, featureFlags, diffuseLighting, specularLighting);

                    diffuseLighting *= GetCurrentExposureMultiplier();
                    specularLighting *= GetCurrentExposureMultiplier();

                    outColor = ApplyBlendMode(diffuseLighting, specularLighting, builtinData.opacity);
                    outColor = EvaluateAtmosphericScattering(posInput, V, outColor);

                }

            }

            ENDHLSL
        }
    }
}
