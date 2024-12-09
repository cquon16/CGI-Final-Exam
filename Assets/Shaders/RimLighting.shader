Shader "Custom/RimLighting"
{
    Properties
    {
        // The main texture of the object, defaulting to white.
        _MainTex ("Texture", 2D) = "white" {}
        
        // The color of the rim effect that simulates a glowing edge.
        _RimColor ("Rim Color", Color) = (0, 0.5, 0.5, 0.0)
        
        // The power of the rim effect; higher values create a sharper edge.
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0
    }

    SubShader
    {
        CGPROGRAM
        // Use a surface shader with Lambert lighting model.
        #pragma surface surf Lambert
        
        // Structure to hold input data for the surface shader.
        struct Input
        {
            float2 uv_MainTex; // UV coordinates for the main texture.
            float3 viewDir;    // Direction from the pixel to the camera/viewer.
        };

        // User-defined variables for rim color and power.
        float4 _RimColor; // The color of the rim emitted by the shader.
        float _RimPower;  // Controls the intensity of the rim effect.

        // Texture sampler for the main texture.
        sampler2D _MainTex;

        // Surface shader function that calculates the final output for each pixel.
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Sample the main texture to get the base color.
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;

            // Calculate the rim lighting factor based on the view direction and the normal.
            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
            
            // Set the emission color based on the rim factor and the defined rim color.
            o.Emission = _RimColor.rgb * pow(rim, _RimPower); // The rim color glows more where the angle is steep.
        }
        ENDCG
    }
    
    // Optional fallback shader if this one fails to compile.
    FallBack "Diffuse"
}
