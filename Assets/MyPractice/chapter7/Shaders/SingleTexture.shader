Shader "Custom/SingleTexture"
{
	Properties
	{
		_Color ("Color Tint",Color) = (1, 1, 1, 1)
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex",2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1) //材质的高光反射颜色
		_Gloss("Gloss",Range(8.0,256)) = 20  //控制高光区域大小

	}
		SubShader
		{
			Pass
		  {
			Tags { "LightMode" = "ForwardBase" }//定义光照模式
			CGPROGRAM
			#pragma vertex vert     
			#pragma fragment frag
			#include "Lighting.cginc"
			//在shader中使用Properties中定义的属性，需要定义与属性类型相匹配的变量
			//fixed4 _Diffuse;
			//fixed4 _Specular;
			//fixed4 _Color;
			//sampler2D _MainTex;
			//float4 _MainTex_ST; //Unity使用纹理名_ST(释放+平移)的方式声明纹理的属性，存储纹理的缩放(xy)和平移(zw)值
			//float _Gloss;
			fixed4 _Color;
		    sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

		struct a2v //顶点着色器的输入
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL; 
			float4 tangent : TANGENT;   //顶点的法线信息，w分量决定副切线的方向
			float4 texcoord : TEXCOORD0; //存储模型的第一组纹理坐标
		};
		struct v2f //顶点着色器的输出
		{
			float4 pos : SV_POSITION;
			float4 uv: TEXCOORD0; //xy分量存储_MainTex的纹理坐标，zw存储_BumpMap的纹理坐标
			float3 lightDir: TEXCOORD1;  //存储变换后的光线方向
			float3 viewDir: TEXCOORD2;  // 存储变换后的视角方向
		};
		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
			//得到模型空间到切线空间的变换矩阵
			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

			float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);
			
			// Transform the light and view dir from world space to tangent space
			o.lightDir = mul(worldToTangent, WorldSpaceLightDir(v.vertex));
			o.viewDir = mul(worldToTangent, WorldSpaceViewDir(v.vertex));

			return o;
		}
		fixed4 frag(v2f i) : SV_Target
		{
			fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
			fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = _LightColor0.rgb * albedo *_Diffuse.rgb * saturate(dot(i.worldNormal, worldLightDir));
			//fixed3 reflectDir = normalize(reflect(-worldLightDir,i.worldNormal));
			fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
			fixed3 halfDir = normalize(worldLightDir + viewDir);
			fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(i.worldNormal, halfDir)),_Gloss);
			fixed3 color = ambient + diffuse + specular;
			return fixed4(color,1.0);
		}
		ENDCG
	   }
	}
	FallBack "Specular"
}
