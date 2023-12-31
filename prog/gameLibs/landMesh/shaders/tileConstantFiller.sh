macro TILE_CONSTANT_FILLER()
  cull_mode  = none;
  z_test = false;        // D3DRS_ZFUNC = D3DCMP_ALWAYS
  z_write = false;
  channel short2 pos = pos;
  channel color8 tc[0] = tc[0];
  hlsl {
    struct VsOutput
    {
      VS_OUT_POSITION(pos)
      float4 color : TEXCOORD0;
    };
  }

  hlsl {
    #define YTWO float2(2, -2)
    #define YMINONE float2(-1, 1)
  }

  (vs) {
    //inv_texture_size@f2 = (1./(clipmapTexMips*TILE_WIDTH), 1./TILE_WIDTH,0,0);
    clipmapTexMips@f1 = (clipmapTexMips);
  }
  hlsl(vs) {
    VsOutput fill_constant_vs(int2 pos_wh : POSITION, float4 color:TEXCOORD0)
    {
      VsOutput output;
      float2 texture_size = float2(TILE_WIDTH*clipmapTexMips*MAX_VTEX_CNT, TILE_WIDTH);
      float2 pos_pixels = pos_wh.xy;
      float2 pos_screen = (pos_pixels)/(texture_size);
      output.pos = float4(pos_screen * YTWO + YMINONE, 1, 1);
      output.color = float4(BGRA_SWIZZLE(color).rgb, 1);
      return output;
    }
  }
  hlsl(ps) {
    half4 fill_constant_ps(VsOutput input): SV_Target
    {
      return input.color;
    }
  }
  compile("target_ps", "fill_constant_ps");
  compile("target_vs", "fill_constant_vs");
endmacro