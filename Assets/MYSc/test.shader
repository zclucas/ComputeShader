Shader "Custom/test"
{
    Properties{
        _MainTex("MainTex",2D)=""{}
        _SecTex("SecTex",2D)=""{}
        _TreeTex("TreeTex",2D)=""{}
        _Four("Four",2D)=""{}
    }
    
    SubShader{
    
        pass{
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            sampler2D _MainTex;
            sampler2D _SecTex;
            sampler2D _TreeTex;
            sampler2D _Four;
            float4 _MainTex_ST;
            struct a2v{
                float4 pos:POSITION;
                float2 uv:TEXCOORD;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD;
            };
            float4x4 rotateY(float a){
                return float4x4(cos(a),0,-sin(a),0 ,0,1,0,0 ,sin(a),0,cos(a),0 ,0,0,0,1);
            }
            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.pos);
                o.uv.xy=v.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                return o;
            }
            fixed4 frag(v2f o):SV_TARGET0{
                fixed3 col;             
                    col=tex2D(_MainTex,o.uv);
                return fixed4(col,1);
            }
            ENDCG
            
        }
        
    }
}
