Shader "Custom/house" {
	
	Properties {
		_ParamsSize("Size", vector) = (0,0,0,0)

        [HDR]_Color1("Color1", color) =(1,1,1,1)
        [HDR]_Color2("Color2", color) =(1,1,1,1)
		
		_C("C", 2D) = "white" {}
		_N("N", 2D) = "bump" {}
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
                float4 tangentOS : TANGENT;
			};
			struct Varyings {
				float4 positionCS : SV_POSITION;
				float3 positionOS : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 binormalWS : TEXCOORD4;
				float2 baseUV : TEXCOORD5;
			};

            float4 _ParamsSize;
            float4 _Color1;
            float4 _Color2;

            SAMPLER(sampler_clamp_bilinear);
             SAMPLER(sampler_repeat_bilinear);

            TEXTURE2D(_C);
            float4 _C_ST;
            TEXTURE2D(_N);
             float4 _N_ST;

			Varyings vert (Attributes input) {
				Varyings output;
				
                output.positionOS = input.positionOS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS = TransformWorldToHClip(output.positionWS);
				
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.tangentWS = TransformObjectToWorldDir(input.tangentOS);
                output.binormalWS =  cross(output.normalWS, output.tangentWS) * input.tangentOS.w * GetOddNegativeScale(); 

                output.baseUV = input.baseUV;
				return output;
			}

			half4 frag (Varyings input) : SV_TARGET {

                // half4 CMap = SAMPLE_TEXTURE2D(_C, sampler_repeat_bilinear, input.baseUV);
				// return CMap;


                half3 N = normalize(input.normalWS);

                half3 NMap = UnpackNormalScale(SAMPLE_TEXTURE2D(_N, sampler_clamp_bilinear,  input.baseUV), 1);
                half3 NWS=mul(NMap,half3x3(input.tangentWS.xyz, input.binormalWS.xyz, input.normalWS.xyz));
				// return half4(NWS,1.0);
				
                 half3 V = normalize(_WorldSpaceCameraPos - input.positionWS);

                half NdotL = 1-(dot(N, half3(0,1,0)))-_ParamsSize.z;
				

				float y = smoothstep(_ParamsSize.x, _ParamsSize.y, input.positionOS.y);// +input.positionOS.z;
				half4 color= lerp(_Color1,_Color2,NdotL);

				//   return ( 1-NdotL)* y;

					return (color);
                 
			}

			ENDHLSL
		}
		
	}
}