Shader "Custom/water" {
	
	Properties {
		_ParamsSize("Size", vector) = (0,0,0,0)

        [HDR]_Color("Color", color) =(1,1,1,1)

        _MirrorMap("MirrorMap", 2D) = "white" {}

        [Header(Distort)]
        _DistortTex("DistortTex", 2D) = "White" {}
        _Distort("Distort", Range(0,1)) = 0
        _DistortUVSpeedX("DistortUVSpeed X", float) = 0
        _DistortUVSpeedY("DistortUVSpeed Y", float) = 0
	}
	
	
	SubShader {
		
		Pass {


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
				float2 baseUV : TEXCOORD3;
			};

            float4 _ParamsSize;
			 float4 _Color;
			 
			 half _Distort;
			 half _DistortUVSpeedX, _DistortUVSpeedY;

            SAMPLER(sampler_clamp_trilinear);
            SAMPLER(sampler_repeat_bilinear);

            TEXTURE2D(_MirrorMap);
            float4 _MirrorMap_ST;
			
            TEXTURE2D(_DistortTex);
            float4 _DistortTex_ST;

			Varyings vert (Attributes input) {
				Varyings output;
				
                output.positionOS = input.positionOS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.baseUV = input.baseUV;
				return output;
			}

			half4 frag (Varyings input) : SV_TARGET {

                half2 uv = 1-input.positionOS.xz/_ParamsSize.xy-0.5;

                half2 distortUV = uv*_DistortTex_ST.xy+_DistortTex_ST.zw;
				distortUV += float2(_DistortUVSpeedX, _DistortUVSpeedY) * _Time.y;
                half4 distortCol = SAMPLE_TEXTURE2D(_DistortTex, sampler_repeat_bilinear, distortUV);
                uv = lerp(uv, distortCol.rg, _Distort);

                half2 mirrorUV = uv*_MirrorMap_ST.xy+_MirrorMap_ST.zw;
                half4 mirrorCol = SAMPLE_TEXTURE2D(_MirrorMap, sampler_clamp_trilinear, mirrorUV);
                    //   return lerpColor;

                    half3 N = normalize(input.normalWS);
                    half3 V = normalize(_WorldSpaceCameraPos - input.positionWS);

                    half frensel = saturate(1 - saturate(dot(N,V)));
    
                return _Color*( mirrorCol )*frensel;
			}

			ENDHLSL
		}
		
	}
}