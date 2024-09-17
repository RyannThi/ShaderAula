Shader "Lit/Ocean"
{
    Properties
    {
        _Color  ("Color", Color) = (0,0,1,1)
        _Normal ("Normal", 2D) = "white" {}
        _Speed ("Speed", Float) = 1.0
        _Amplitude ("Amplitude", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _Normal;
            float4 _Normal_ST;
            float4 _Color;
            float _Speed;
            float _Amplitude;

            float4 _MainTex_ST;

            float4 position2;

            v2f vert (appdata v)
            {
                v2f output;

                //output.vertex = UnityObjectToClipPos(v.vertex);

                float amplitude = 0.4;
                float frequency = 2.0;
                float speed = _Speed * 0.1;

                //float edgeX = v.vertex.x - 0.5;

                position2 = v.vertex;
                position2.y += sin(position2.x * frequency + _Time.z * speed) * sin(position2.z * frequency + _Time.z * speed) * _Amplitude;// * edgeX;

                float3 positionFinal = position2;// * float3(2, 2, 1);

                // calcula o vertice da coordenada local para a coordenada de projecao e de mundo
                output.vertex = UnityObjectToClipPos(positionFinal);

                output.uv = TRANSFORM_TEX(v.uv, _Normal);

                output.normal = v.normal.xyz;

                UNITY_TRANSFER_FOG(output,output.vertex);

                return output;

                //
                /*
                v2f output;
                output.vertex = UnityObjectToClipPos(v.vertex);
                output.uv = TRANSFORM_TEX(v.uv, _Normal);
                output.normal = v.normal.xyz;

                UNITY_TRANSFER_FOG(output, output.vertex);
                return output;*/
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //light from unity  
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                // sample the texture
                fixed4 norm = tex2D(_Normal, i.uv + _Time.xx);
                fixed4 norm2 = tex2D(_Normal, i.uv * 0.9 - _Time.xx);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, _Color);

                // calculate lighting
                float bright = dot(i.normal * norm * norm2, lightDir);

                return _Color * bright;
            }
            ENDCG
        }
    }
}