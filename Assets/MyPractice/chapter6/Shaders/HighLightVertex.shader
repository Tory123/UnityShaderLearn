// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/HighLightVertex"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1,1,1,1) //材质的高光反射颜色
		_Gloss("Gloss",Range(8.0,256)) = 20  //控制高光区域大小
	}
		SubShader
	{
		Pass
	  {
		Tags { "LightMode" = "ForwardBase" }//LightMode:定义Pass在Unity光照流水线中的角色
		CGPROGRAM
		#pragma vertex vert     
		#pragma fragment frag
		#include "Lighting.cginc"
		//在shader中使用Properties中定义的属性，需要定义与属性类型相匹配的变量
		fixed4 _Diffuse;
	    fixed4 _Specular;
		float _Gloss;

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
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(o.worldNormal, worldLightDir));
			fixed3 reflectDir = normalize(reflect(-worldLightDir,o.worldNormal));
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss) ;
			o.color = ambient + diffuse + specular;
			return o;
		}
		fixed4 frag(v2f i) : SV_Target
		{
			return fixed4(i.color,1.0);
		}
		ENDCG
	   }
	}
}
