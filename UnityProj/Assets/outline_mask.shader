Shader "Custom/outline_mask"
{
    Properties
    {
        _Color1("Color1", color) =(1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Cull Front
            // ZTest Less

            Stencil{
                Ref 100
                Comp Always
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
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

			float4 _Color1;

            Varyings vert(Attributes v)
            {
                Varyings o;

                float4 positionCS = TransformObjectToHClip(v.positionOS);
                o.positionCS = positionCS;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                return _Color1;
            }
            ENDHLSL
        }
    }
}