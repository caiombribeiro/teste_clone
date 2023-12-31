include "shader_global.sh"
include "ssao_use.sh"
shader sao
{
  INIT_SAO()
  
  cull_mode=none;
  z_write=false;
  z_test=false;

  

  channel float2 pos = pos;
  channel float3 tc[0] = tc[0];

  hlsl {
    struct VsOutput
    {
      VS_OUT_POSITION(pos)
      float2 tc : TEXCOORD0;
    };
  }
  
  (vs) { lowres_rt_params@f4 = lowres_rt_params; }
  DECL_POSTFX_TC_VS_RT()
  
  hlsl(vs) {

    struct VsInput
    {
      float2 pos        : POSITION;
      float3 viewVect   : TEXCOORD0;
    };

    VsOutput SSAO_vs(VsInput input)
    {
      VsOutput output;
      output.pos = float4(input.pos.xy,0,1);
      output.tc = input.pos * float2(0.5, -0.5) + float2(0.50001, 0.50001);
      output.tc.xy = output.tc;

      return output;
    }
  }

  hlsl(ps) {
    half4 SSAO_ps(VsOutput IN) : SV_Target
    {
      float2 screenTC = IN.tc.xy;
      float rawDepth = tex2Dlod(depth_tex, float4(IN.tc.xy,0,0)).x;
      BRANCH
      if (rawDepth<=0)
        return 1;

      float w = linearize_z(rawDepth, zn_zfar.zw);
      return def_SSAO(w, screenTC).xxxx;
    }
  }

  compile("target_vs", "SSAO_vs");
  compile("target_ps", "SSAO_ps");
}