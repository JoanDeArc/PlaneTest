Shader "Unlit/MyShader"
{
	Properties {
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Color ("Line Color", Color) = (1,1,1,1)
		_Color2 ("Main Color", Color) = (1,1,1,1) 
		_Thickness ("Thickness", Float) = 1
	}

	SubShader {
		Tags {"RenderType"="Opaque" "Queue"="Transparent" "RenderType"="TransparentCutout"}

						
		Pass {
			Lighting Off
			SetTexture [_MainTex] {

				constantColor [_Color2]

				Combine texture * constant, texture * constant 

			 } 
		} 

		Pass {			 		
						
			Blend SrcAlpha OneMinusSrcAlpha 
			Lighting Off
			ZWrite Off
			LOD 200


			CGPROGRAM
				#pragma target 5.0
				#include "UnityCG.cginc"
				#include "UCLA GameLab Wireframe Functions.cginc"
				#pragma vertex vert
				#pragma fragment frag
				#pragma geometry geom

				// Vertex Shader
				UCLAGL_v2g vert(appdata_base v)
				{
					return UCLAGL_vert(v);
				}
				
				// Geometry Shader
				[maxvertexcount(3)]
				void geom(triangle UCLAGL_v2g p[3], inout TriangleStream<UCLAGL_g2f> triStream)
				{
					UCLAGL_geom( p, triStream);
				}
				

				// Fragment Shader
				float4 frag(UCLAGL_g2f input) : COLOR
				{	
					return UCLAGL_frag(input);
				}
			ENDCG
						
		}

	}
}
