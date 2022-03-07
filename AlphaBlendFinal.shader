Shader "Personal Shaders/Alpha Blend Final"
{
    Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		//主纹理
		_MainTex ("Main Tex", 2D) = "white" {}
		//透明度调节
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
		//凹凸纹理
		_BumpMap ("Bump Map", 2D) = "bump" {}
		//凹凸度调整
        _BumpScale("Bump Scale",float) = 1
		//漫反射渐变
		_RampTex("Ramp Tex",2D) = "white" {}
		//高光遮罩(使用r分量计算)
		_SpecularMask("Specular Mask",2D) = "white" {}
		//高光遮罩调节
		_SpecularScale("Specular Scale",float) = 1
		//高光颜色
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		//高光幂
		_Gloss ("Gloss", Range(8.0, 256)) = 20

	}
	SubShader
    {
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IngnoreProjector" = "False"}
        
        
		//ForwardBase 渲染背面
		Pass
        { 
			Tags { "LightMode"="ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
			CGPROGRAM
			
			#pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _RampTex;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;
            float _AlphaScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3; 
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = UnityObjectToClipPos(v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
                
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
  				
  				TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				

				fixed3 bump = UnpackNormalWithScale(tex2D(_BumpMap, i.uv.zw),_BumpScale);
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed halfLambert = 0.5 * dot(bump,lightDir) + 0.5;
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed mainTexAlpha = tex2D(_MainTex, i.uv.xy).a;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				

			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir)) * tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb;
			 	
			 	fixed3 halfDir = normalize(lightDir + viewDir);
				fixed specularMask = tex2D(_SpecularMask,i.uv.xy).r * _SpecularScale;
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss) * specularMask;
			
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + (diffuse + specular) * atten, mainTexAlpha * _AlphaScale);
			}
			
			ENDCG
		}
        //ForwardBase 渲染正面
		Pass
        { 
			Tags { "LightMode"="ForwardBase" }

            ZWrite Off 
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
			CGPROGRAM
			
			#pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _RampTex;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;
            float _AlphaScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3; 
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = UnityObjectToClipPos(v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
                
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
  				
  				TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormalWithScale(tex2D(_BumpMap, i.uv.zw),_BumpScale);
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				fixed halfLambert = 0.5 * dot(bump,lightDir) + 0.5;
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed mainTexAlpha = tex2D(_MainTex, i.uv.xy).a;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir)) * tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb;
			 	
			 	fixed3 halfDir = normalize(lightDir + viewDir);
			 	fixed specularMask = tex2D(_SpecularMask,i.uv.xy).r * _SpecularScale;
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss) * specularMask;
			
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + (diffuse + specular) * atten, mainTexAlpha * _AlphaScale);
			}
			
			ENDCG
		}
        
        //ForwardAdd 先渲染背面的其他逐像素光源对物体的影响
		Pass 
        { 
			Tags { "LightMode"="ForwardAdd" }
			
            ZWrite Off
            //利用源颜色的alpha通道，即透明程度来混合颜色
			Blend SrcAlpha One
            Cull Front
			CGPROGRAM
			
			#pragma multi_compile_fwdadd
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _RampTex;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;
            float _AlphaScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = UnityObjectToClipPos(v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
	
  				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			  	o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			  	o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
			 	
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormalWithScale(tex2D(_BumpMap, i.uv.zw),_BumpScale);
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed halfLambert = 0.5 * dot(bump,lightDir) + 0.5;
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed mainTexAlpha = tex2D(_MainTex, i.uv.xy).a;
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir)) * tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb;
			 	
			 	fixed3 halfDir = normalize(lightDir + viewDir);
			 	fixed specularMask = tex2D(_SpecularMask,i.uv.xy).r * _SpecularScale;
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss) * specularMask;
			
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4((diffuse + specular) * atten, mainTexAlpha * _AlphaScale);
			}
			
			ENDCG
		}
		//ForwardAdd 渲染正面的其他逐像素光源对物体的影响
		Pass 
        { 
			Tags { "LightMode"="ForwardAdd" }
			
            ZWrite Off
            //利用源颜色的alpha通道，即透明程度来混合颜色
			Blend SrcAlpha One
            Cull Back
			CGPROGRAM
			
			#pragma multi_compile_fwdadd
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			sampler2D _RampTex;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			float _Gloss;
            float _AlphaScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = UnityObjectToClipPos(v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
	
  				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			  	o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			  	o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
			 	
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormalWithScale(tex2D(_BumpMap, i.uv.zw),_BumpScale);
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed halfLambert = 0.5 * dot(bump,lightDir) + 0.5;
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed mainTexAlpha = tex2D(_MainTex, i.uv.xy).a;
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir)) * tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb;
			 	
			 	fixed3 halfDir = normalize(lightDir + viewDir);
			 	fixed specularMask = tex2D(_SpecularMask,i.uv.xy).r * _SpecularScale;
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss) * specularMask;
			
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4((diffuse + specular) * atten, mainTexAlpha * _AlphaScale);
			}
			
			ENDCG
		}
        //物体向别的物体投影,ShadowCaster
        /*pass
        {
            Tags{"LightMode" = "ShadowCaster"}
            CGPROGRAM
            #pragma multi_compile_shadowcaster
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };
            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }
            float4 frag(v2f i) : SV_TARGET
            {
                
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }*/
	} 
	Fallback "VertexLit"
}
