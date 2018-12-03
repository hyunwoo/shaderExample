Shader "Custom/WaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _NormalTex;
            sampler2D _MainTex;
            
            float4 _NormalTex_ST;
            float4 _MainTex_ST;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 normCoord = i.uv;
                normCoord.x += _Time.x * 0.1;
                fixed4 norm = tex2D(_NormalTex, normCoord.x);
                // add normal to uv
                
                float2 coord = i.uv;
                coord.xy += norm.xy * 0.01 * sin(_Time.x * 10 + i.uv.x * 0.1);
                coord.xy *= 20;
                coord.x += _Time.x;
                
                fixed4 col = tex2D(_MainTex, coord);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}