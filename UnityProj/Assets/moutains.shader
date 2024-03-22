Shader "Custom/moutains" {
	
	Properties {
        _HeightOS("HeightOS", float) =1

        // [HDR]_Color1("Color1", color) =(1,1,1,1)
        // [HDR]_Color2("Color2", color) =(1,1,1,1)
        _Color3("Color3", color) =(1,1,1,1)

        _ColorMap("Color", 2D) = "white" {}

		_ParamsSin("Params Sin", vector) = (0,0,0,0)
		_ParamsLerp("Params Lerp", vector) = (0,0,0,0)
		_ParamsNoise("Params Noise", vector) = (0,0,0,0)

        // _NoiseMap("Noise", 2D) = "white" {}

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
                float3 normalWS : TEXCOORD2;
			};

            float _HeightOS;
			
			// float4 _Color1;
			// float4 _Color2;
		    float4 _Color3;

			float4 _ParamsSin;
			float4 _ParamsLerp;
			float4 _ParamsNoise;

            half4 _FresnelColor1;
            half4 _FresnelColor2;
            half4 _FresnelParams;

            SAMPLER(sampler_clamp_bilinear);
            // SAMPLER(sampler_repeat_bilinear);

            TEXTURE2D(_ColorMap);
            float4 _ColorMap_ST;
            // TEXTURE2D(_NoiseMap);
            // float4 _NoiseMap_ST;

			Varyings vert (Attributes input) {
				Varyings output;
				
                output.positionOS = input.positionOS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionCS = TransformWorldToHClip(output.positionWS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				return output;
			}

			half4 frag (Varyings input) : SV_TARGET {

                // half3 N = normalize(input.normalWS);
                // half3 V = normalize(_WorldSpaceCameraPos - input.positionWS);

                float x = input.positionOS.x+input.positionOS.z;
                float y = input.positionOS.y;
                
                y += sin((x+_ParamsSin.x)*_ParamsSin.y)*_ParamsSin.z+_ParamsSin.w;
                y=saturate(y);

                 float lerpY = smoothstep( _ParamsLerp.x, _ParamsLerp.y, y);
                //    return lerpY;

                // half4 lerpColor = lerp( _Color1, _Color2, lerpY );
                half4 lerpColor = SAMPLE_TEXTURE2D(_ColorMap, sampler_clamp_bilinear, half2(lerpY,0));
                //    return lerpColor;

                float mixY = smoothstep( _ParamsLerp.z, _ParamsLerp.w, y);
                 mixY=saturate(mixY);
                    // return mixY;
                
                half2 uv = input.positionOS.xz ;

                  float noise = frac(sin(dot(uv , half2(12.9898, 78.233))) * 43635.8) ;
                // float noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_repeat_bilinear, uv*_NoiseMap_ST.xy).r;
                //  noise=saturate((noise - _ParamsNoise.x)* _ParamsNoise.y);

                half4 noiseColor = lerp( 0, _Color3, step(_ParamsNoise.x, noise)) * _ParamsNoise.y;
                  noiseColor *= mixY;
            //   return noiseColor;

                return ( lerpColor + noiseColor );
			}

			ENDHLSL
		}
		
	}
}