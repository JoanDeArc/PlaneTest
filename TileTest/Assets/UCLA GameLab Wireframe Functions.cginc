// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Algorithms and shaders based on code from this journal
//http://cgg-journal.com/2008-2/06/index.html

#ifndef UCLA_GAMELAB_WIREFRAME
#define UCLA_GAMELAB_WIREFRAME

#include "UnityCG.cginc"

// DATA STRUCTURES //
// Vertex to Geometry
struct UCLAGL_v2g
{
	float4	pos		: POSITION;		// vertex position
	float2  uv		: TEXCOORD0;	// vertex uv coordinate
};

// Geometry to  UCLAGL_fragment
struct UCLAGL_g2f
{
	float4	pos		: POSITION;		// fragment position
	float2	uv		: TEXCOORD0;	// fragment uv coordinate
	float3  dist	: TEXCOORD1;	// distance to each edge of the triangle

	float alpha     : FLOAT;
};

// PARAMETERS //

//float4 _Texture_ST;			// For the Main Tex UV transform
float _Thickness = 1;		// Thickness of the wireframe line rendering
float4 _Color = {1,1,1,1};	// Color of the line
float4 _MainTex_ST;			// For the Main Tex UV transform
sampler2D _MainTex;			// Texture used for the line

float3 mousePos = {1, 1, 1};

// SHADER PROGRAMS //
// Vertex Shader
UCLAGL_v2g UCLAGL_vert(appdata_base v)
{
	UCLAGL_v2g output;
	output.pos =  UnityObjectToClipPos(v.vertex);
	output.uv = TRANSFORM_TEX (v.texcoord, _MainTex);//v.texcoord;

	return output;
}

// Geometry Shader
[maxvertexcount(3)]
void UCLAGL_geom(triangle UCLAGL_v2g p[3], inout TriangleStream<UCLAGL_g2f> triStream)
{
	//points in screen space
	float2 p0 = _ScreenParams.xy * p[0].pos.xy / p[0].pos.w;
	float2 p1 = _ScreenParams.xy * p[1].pos.xy / p[1].pos.w;
	float2 p2 = _ScreenParams.xy * p[2].pos.xy / p[2].pos.w;
	
	//edge vectors
	float2 v0 = p2 - p1;
	float2 v1 = p2 - p0;
	float2 v2 = p1 - p0;

	//area of the triangle
 	float area = abs(v1.x*v2.y - v1.y * v2.x);

	//values based on distance to the edges
	float dist0 = area / length(v0);
	float dist1 = area / length(v1);
	float dist2 = area / length(v2);

	//mousePos = UnityObjectToClipPos(mousePos);
	
	UCLAGL_g2f pIn;


	
	//add the first point
	pIn.pos = p[0].pos;
	pIn.uv = p[0].uv;
	pIn.dist = float3(dist0,0,0);
	

	float dx = length(mousePos.x - p[0].pos.x);
	float dy = length(mousePos.y - p[0].pos.y);
	float dz = length(mousePos.z - p[0].pos.z);
	float alpha = (dx*dx+dy*dy+dz*dz) * 0.4;
	alpha = clamp(alpha,0,1);
	pIn.alpha = alpha;

	triStream.Append(pIn);

	//add the second point
	pIn.pos =  p[1].pos;
	pIn.uv = p[1].uv;
	pIn.dist = float3(0,dist1,0);

	dx = length(mousePos.x - p[1].pos.x);
	dy = length(mousePos.y - p[1].pos.y);
	dz = length(mousePos.z - p[1].pos.z);
	alpha = (dx*dx+dy*dy+dz*dz) * 0.4;
	alpha = clamp(alpha,0,1);
	pIn.alpha = alpha;


	triStream.Append(pIn);
	
	//add the third point
	pIn.pos = p[2].pos;
	pIn.uv = p[2].uv;
	pIn.dist = float3(0,0,dist2);

	dx = length(mousePos.x - p[2].pos.x);
	dy = length(mousePos.y - p[2].pos.y);
	dz = length(mousePos.z - p[2].pos.z);
	alpha = (dx*dx+dy*dy+dz*dz) * 0.4;
	alpha = clamp(alpha,0,1);
	pIn.alpha = alpha;


	triStream.Append(pIn);
}

// Fragment Shader
float4 UCLAGL_frag(UCLAGL_g2f input) : COLOR
{			
	//find the smallest distance
	float val = min( input.dist.x, min( input.dist.y, input.dist.z));
	
	//calculate power to 2 to thin the line
	val = exp2( -1/_Thickness * val * val );
		
	//blend between the lines and the negative space to give illusion of anti aliasing
	float4 targetColor = _Color * tex2D( _MainTex, input.uv);
	float4 transCol = _Color * tex2D( _MainTex, input.uv);
	transCol.a = 0;


	//targetColor.a = input.alpha;

    return val * targetColor + ( 1 - val ) * transCol;
}


#endif