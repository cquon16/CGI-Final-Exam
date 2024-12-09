Shader "Custom/SkyScrollingTex"
{
    Properties
    {
        _SkyTexture("Water Texture", 2D) = "white" {}
        _WaveStrength("Wave Strength", Float) = 0.1
        _WaveSpeed("Wave Speed", Float) = 0.5
        _WaveFrequency("Wave Frequency", Float) = 1.0
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Float) = 1.0
        _ScrollSpeed("Scroll Speed", Vector) = (0.1, 0.05, 0, 0)
        

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float _WaveStrength;
            float _WaveSpeed;
            float _WaveFrequency;
            float4 _ScrollSpeed;
            sampler2D _SkyTexture;
            sampler2D _NormalMap;
            float _NormalStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Calculate wave displacement in the y-direction
                float time = _Time.y * _WaveSpeed;
                float wave = sin(v.vertex.x * _WaveFrequency + time) * _WaveStrength;
                wave += cos(v.vertex.z * _WaveFrequency + time) * _WaveStrength;
                
                // Offset vertex height by wave value
                o.pos.y += wave;
                
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Scroll UVs for the water texture
                float2 scrollUV = i.uv + (_ScrollSpeed.xy * _Time.y);

                // Sample the water texture and normal map
                float4 waterColor = tex2D(_SkyTexture, scrollUV);
                float3 normalMap = UnpackNormal(tex2D(_NormalMap, scrollUV)) * _NormalStrength;
                
                // Basic lighting
                float3 lightDir = normalize(float3(0.3, 1.0, 0.5));
                float lighting = saturate(dot(normalMap, lightDir) * 0.5 + 0.5);
                float3 finalColor = waterColor.rgb;

                // Output final color with lighting
                return float4(finalColor * lighting, waterColor.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}