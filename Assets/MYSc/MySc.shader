Shader "Custom/MySc"
{
    Properties{
        _MainTex("MainTex",2D)=""{}
        _SecTex("SecTex",2D)=""{}
        _TreeTex("TreeTex",2D)=""{}
        _Four("Four",2D)=""{}
        _Color1("one",COLOR)=(1,1,1,1)
        _Color2("two",COLOR)=(1,1,1,1)
        _Color3("three",COLOR)=(1,1,1,1)
        _Color4("fivv",COLOR)=(1,1,1,1)
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
            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;
            fixed4 _Color4;
            struct infos{
                float4x4 TF;
                int index;
            };
            StructuredBuffer<infos> data;
            struct a2v{
                float4 pos:POSITION;
                float2 uv:TEXCOORD;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD;
                uint index:TEXCOORD1;
            };
            float4x4 rotateY(float a){
                return float4x4(cos(a),0,-sin(a),0 ,0,1,0,0 ,sin(a),0,cos(a),0 ,0,0,0,1);
            }
            v2f vert(a2v v,uint index:SV_INSTANCEID){
                v2f o;
                v.pos=mul(rotateY(_Time),v.pos);
                v.pos=mul(data[index].TF,v.pos);
                v.pos=mul(rotateY(_Time),v.pos);
                o.pos=UnityObjectToClipPos(v.pos);
                o.uv.xy=v.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                o.uv.x+=_Time;
                o.index=data[index].index;
                return o;
            }
            fixed4 frag(v2f o):SV_TARGET0{
                fixed3 col;
                fixed3 ami;
                if(o.index%4==0)
                    {
                    col=tex2D(_MainTex,o.uv);
                    ami=_Color1;
                    }
                else if(o.index%4==1)
                    {
                    col=tex2D(_SecTex,o.uv);
                    ami=_Color2;
                    }
                else if(o.index%4==2)
                    {
                    col=tex2D(_TreeTex,o.uv);
                    ami=_Color3;
                    }
                else 
                    {
                    col=tex2D(_Four,o.uv);
                    ami=_Color4;
                    }
                return fixed4(col*ami*2,1);
            }
            ENDCG
            
        }
        
    }
}
