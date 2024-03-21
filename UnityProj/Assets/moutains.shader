Shader "Custom/moutains" {
	
	Properties {
        [HDR]_Color1("Color1", color) =(1,1,1,1)
        [HDR]_Color2("Color2", color) =(1,1,1,1)
        [HDR]_Color3("Color3", color) =(1,1,1,1)
		_Params1("Params1", vector) = (0,0,0,0)
		_Params2("Params2", vector) = (0,0,0,0)
        _NoiseMap("Noise", 2D) = "white" {}

        _FresnelColor1("FresnelColor1", Color) = (1,1,1,1)
        _FresnelColor2("FresnelColor2", Color) = (1,1,1,1)
        _FresnelParams("FresnelParams", Vector) = (0,0,1,1)
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
				float2 baseUV : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
			};
			
			float4 _Color1;
			float4 _Color2;
		 float4 _Color3;
			float4 _Params1;
			float4 _Params2;

            half4 _FresnelColor1;
            half4 _FresnelColor2;
            half4 _FresnelParams;

            SAMPLER(sampler_NoiseMap);
            TEXTURE2D(_NoiseMap);
            float4 _NoiseMap_ST;

			Varyings vert (Attributes input) {
				Varyings output;
				
                output.positionOS = input.positionOS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS = TransformWorldToHClip(output.positionWS);
                output.baseUV = TRANSFORM_TEX(input.baseUV, _NoiseMap);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				return output;
			}

			half4 frag (Varyings input) : SV_TARGET {


                float yOS = (input.positionOS.y * _Params1.x +_Params1.y);
                yOS=saturate(yOS);
                yOS = pow(yOS,_Params1.z);
                // return yOS;

                half4 lerpColor = lerp(_Color1, _Color2,yOS );
                // return lerpColor;
                
                
                half2 testUV = input.positionOS.xy;// +input.positionOS.z*0.002;
              testUV = testUV*_NoiseMap_ST.xy+_NoiseMap_ST.zw;

                float noise = (frac(sin(dot(testUV , half2(12.9898,78.233))) * 43758.5453) - 0.5) * 2.0;
                return noise;

               //  half noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, testUV).r;
               //  noise=noise;
               //   half4 noiseCol = lerp(_Color1,_Color2,1- noise);
               //  // return noiseCol;

               //  if(yOS>_Params2.x&&yOS<_Params2.y)
               // return  lerpColor+noiseCol;
               // return lerpColor;

                
               //  float yOS2 = (input.positionOS.y * _Params2.x +_Params2.y);
               //  yOS2=saturate(yOS2);
               //  yOS2 = pow(yOS2,_Params2.z);
               //   return lerp(1-noise,1,yOS2 ) *_Color2;
                

                half3 N = normalize(input.normalWS);
                half3 V = normalize(_WorldSpaceCameraPos - input.positionWS);
                
                half fresnel =_FresnelParams.x * pow(abs(max(0, dot(V, N))), _FresnelParams.y);

                // fresnel = step(fresnel, _FresnelParams.z);

                half4 fresnelCol = half4(0.0,0.0,0.0,0.0);

                if (fresnel > _FresnelParams.z)
                    fresnelCol = _FresnelColor1;
                else if (fresnel > _FresnelParams.w)
                    fresnelCol = _FresnelColor2;


                    lerpColor.rgb *= fresnelCol;


                return lerpColor;
			}

			ENDHLSL
		}
		
	}
}