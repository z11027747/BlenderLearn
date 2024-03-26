Shader "Custom/house" {
	
	Properties {
		_ParamsSize("Size", vector) = (0,0,0,0)

        [HDR]_Color1("Color1", color) =(1,1,1,1)
        [HDR]_Color2("Color2", color) =(1,1,1,1)
	}
	
	
	SubShader {
		
		Pass {

            // Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"

			struct Attributes {
				float3 positionOS : POSITION;
				float2 baseUV : TEXCOORD0;
                float3 normalOS : NORMAL;
			};
			struct Varyings {
				float4 positionCS : SV_POSITION;
				float3 positionOS : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
			};

            float4 _ParamsSize;
            float4 _Color1;
            float4 _Color2;

			Varyings vert (Attributes input) {
				Varyings output;
				
                output.positionOS = input.positionOS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				return output;
			}

			half4 frag (Varyings input) : SV_TARGET {

                 half3 N = normalize(input.normalWS);
                 half3 L = normalize(_MainLightPosition.xyz);

                 half y= dot(N,L)*0.5+0.5;

                 float Steps = _ParamsSize.xyYtoXYZ;
                  y = floor(y *Steps)/Steps;

                 return y;

                 return lerp(_Color1,_Color2,y);

                 
			}

			ENDHLSL
		}
		
	}
}