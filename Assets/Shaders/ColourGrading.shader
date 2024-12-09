Shader "Custom/ColourGrading"
{
    Properties
    { 
        // The main texture to apply color grading to, defaulting to white.
        _MainTex ("Texture", 2D) = "white" {}
        // The Lookup Table (LUT) texture that contains the color grading information.
        _LUT("LUT", 2D) = "white" {}
        // The contribution factor for blending between the original color and the graded color.
        _Contribution("Contribution", Range(0, 1)) = 1
        // Toggle for using color grading
        _UseColorGrading ("Use Color Grading", Float) = 1 // New property
    }

    SubShader
    {
        // Disable backface culling and Z writing, and set Z testing to always pass.
        Cull Off ZWrite Off ZTest Always

        Pass
        { 
            CGPROGRAM
            #pragma vertex vert // Specify the vertex shader function.
            #pragma fragment frag // Specify the fragment shader function.

            #include "UnityCG.cginc" // Include Unity's built-in shader functions and definitions.

            #define COLORS 32.0 // Define the number of colors in the LUT.

            // Structure for passing vertex data.
            struct appdata
            { 
                float4 vertex : POSITION; // Vertex position in object space.
                float2 uv : TEXCOORD0; // UV coordinates for texture mapping.
            };

            // Structure for passing data from the vertex shader to the fragment shader.
            struct v2f
            { 
                float2 uv : TEXCOORD0; // UV coordinates passed to fragment shader.
                float4 vertex : SV_POSITION; // Clip space position of the vertex.
            };

            // Vertex shader function
            v2f vert (appdata v)
            {
                v2f o; // Output structure
                o.vertex = UnityObjectToClipPos(v.vertex); // Transform vertex position to clip space.
                o.uv = v.uv; // Pass UV coordinates to the fragment shader.
                return o; // Return the transformed data.
            }

            // Texture samplers
            sampler2D _MainTex; // Sampler for the main texture.
            sampler2D _LUT; // Sampler for the LUT texture.
            float _Contribution; // Blend factor for original vs. graded color.
            float _UseColorGrading; // Control whether to apply color grading.

            // Fragment shader function
            fixed4 frag (v2f i) : SV_Target
            {
                float maxColor = COLORS - 1.0; // Maximum color index in the LUT.

                // Sample the main texture color and ensure it's in the [0, 1] range.
                fixed4 col = saturate(tex2D(_MainTex, i.uv));

                // If color grading is disabled, return the original color.
                if (_UseColorGrading < 0.5)
                {
                    return col;
                }

                // Calculate texel size for the LUT based on the number of colors.
                float2 lutTexelSize = 1.0 / float2(COLORS, COLORS);

                // Calculate the position in the LUT texture.
                float cell = floor(col.b * maxColor); // Determine the LUT row based on blue channel.
                float xOffset = col.r * lutTexelSize.x; // X offset from the red channel.
                float yOffset = col.g * lutTexelSize.y; // Y offset from the green channel.

                // Compute the final LUT position to sample from.
                float2 lutPos = float2(cell / COLORS + xOffset, yOffset);

                // Sample the color from the LUT.
                float4 gradedCol = tex2D(_LUT, lutPos);

                // Blend the original color with the graded color based on the contribution factor.
                return lerp(col, gradedCol, _Contribution);
            }
            ENDCG 
        } 
    }
    FallBack "Diffuse" // Optional fallback shader if this shader cannot be used.
}
