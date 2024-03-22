Shader "Custom/outline"
{
    Properties
    {
        _OutlineColor("OutlineColor", color) =(1,1,1,1)
        _OutlineWidth("OutlineWidth", float) = 0.1
    }
    SubShader
    {
        Pass
        {
            Cull Front
            // ZTest Less

            Stencil
            {
                Ref 100
                Comp NotEqual
                Pass Replace
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            half4 _OutlineColor;
            float _OutlineWidth;

            Varyings vert(Attributes v)
            {
                Varyings o;

                float3 normalWS = TransformObjectToWorldNormal(v.tangentOS.xyz);

                float3 normalCS = TransformWorldToHClipDir(normalWS);
                float2 extendDis = normalize(normalCS.xy) * _OutlineWidth; 

                float scaleX = abs(_ScreenParams.x / _ScreenParams.y); 
                extendDis.x /= scaleX; 

                float4 positionCS = TransformObjectToHClip(v.positionOS);
                positionCS.xy += extendDis;

                o.positionCS = positionCS;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}