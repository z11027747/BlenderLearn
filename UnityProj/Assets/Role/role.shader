Shader "Custom/role" {
	
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
			};
			struct Varyings {
				float4 positionCS : SV_POSITION;
				float3 positionOS : TEXCOORD0;
			};

            float4 _ParamsSize;
            float4 _Color1;
            float4 _Color2;

			Varyings vert (Attributes input) {
				Varyings output;
				
                output.positionOS = input.positionOS;
				output.positionCS = TransformObjectToHClip(input.positionOS);
              return output;
			}

			half4 frag (Varyings input) : SV_TARGET {

                float y = smoothstep(_ParamsSize.x, _ParamsSize.y, input.positionOS.z);// +input.positionOS.z;
                return lerp(_Color1,_Color2,y);

			}

			ENDHLSL
		}
		
	}
}