// ShaderLab
Shader "Unlit/Flag1"
{
    Properties
    {
        // _MainTex eh o nome da variavel. "Texture" eh o nome no inspetor, "2D" tipo da variavel. "white" eh inicializacao
        _MainTex ("Texture", 2D) = "white" {}
    }
    // bloco de codigo que define o comportamento do shader
    SubShader
    {
        // tags que definem o comportamento do shader
        Tags { "RenderType"="Opaque" }

        // voce pode colocar varios subshaders com lods diferentes
        LOD 100

        Cull off

        // eh uma etapa de renderizacao de shader (podendo ter mais)
        Pass
        {
            // inicio do codigo do shader (parecido com hlsl)
            // CGProgram
            CGPROGRAM

            // se refere a funcao que processsa o vertex
            #pragma vertex vert

            // '' o fragment
            #pragma fragment frag

            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            // valores de entrada do vertex
            // os tipos de semantica podem ser: POSITION, NORMAL, TEXCOORD0, TEXCOORD1, TEXCOORD2, TEXCOORD3, COLOR, TANGENT, BLENDWEIGHT, BLENDINDICES
            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // struct que define os dados de saida do vertex shader e entrada do fragment shader
            // TEXCOORD0 eh a semantica da variavel uv
			// os tipos de semantica podem ser: TEXCOORD0, TEXCOORD1, TEXCOORD2, TEXCOORD3, COLOR
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // var que define a textura do material. sendo o mesmo nome da var do shaderlab, referencia automaticamente
            sampler2D _MainTex;

            // var que define a transformacao da textura
            //na unity, o _ST referencia automaticamente ao parametro de tiling e offset do material
            float4 _MainTex_ST;

            float4 position2;

            // funcao que processa o vertex
            v2f vert(appdata v)
            {
                v2f output;

                //output.vertex = UnityObjectToClipPos(v.vertex);

                float amplitude = 0.4;
                float frequency = 2.0;
                float speed = 2.0;

                //float edgeX = v.vertex.x - 0.5;

                position2 = v.vertex;
                position2.y += sin(position2.x * frequency + _Time.z * speed) * amplitude;// * edgeX;

                float3 positionFinal = position2;// * float3(2, 2, 1);

                // calcula o vertice da coordenada local para a coordenada de projecao e de mundo
                output.vertex = UnityObjectToClipPos(positionFinal);

                output.uv = TRANSFORM_TEX(v.uv, _MainTex);

                UNITY_TRANSFER_FOG(output,output.vertex);

                return output;
            }

            // funcao que processa o fragment
            // semantica sv_target indica que a saida é o fragmneto final
            fixed4 frag(v2f input) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, input.uv);

                // apply fog
                UNITY_APPLY_FOG(input.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}
