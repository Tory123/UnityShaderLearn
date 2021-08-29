// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PixelsDiffuseShader"
{
    Properties
    {
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
		Pass
	  {
		Tags { "LightMode" = "ForwardBase" }
		CGPROGRAM
		#pragma vertex vert     
		#pragma fragment frag
		#include "Lighting.cginc"
		fixed4 _Diffuse;
		struct a2v //顶点着色器的输入
		{
			float4 vertex : POSITION;
			 float3 normal : NORMAL;
		};
		struct v2f //顶点着色器的输出
		{
			float4 pos : SV_POSITION;
			float3 worldNormal : TEXCOORD0;
			fixed3 color : COLOR;
		};
		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
			return o;
		}
		fixed4 frag(v2f i) : SV_Target
		{
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	      	fixed3 worldNormal = normalize(i.worldNormal);
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
			fixed3 color = ambient + diffuse;
			return fixed4(color, 1.0);
		}
		ENDCG
	   }
    }
}
