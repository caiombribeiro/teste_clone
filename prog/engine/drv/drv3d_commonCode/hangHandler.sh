include "shader_global.sh"

shader hang_gpu_cs
{
  supports none;
  supports global_frame;
  
  hlsl(cs) {
    RWTexture2D< uint > gpu_hang_uav : register(u7);

    [numthreads( 32, 32, 1 )]
    void hang_gpu()
    {
      float foo;
      for (int i = 0; i < 1000000000; ++i)
        InterlockedAdd(gpu_hang_uav[uint2(0,0)], 1, foo);
    }
  }

  compile("target_cs", "hang_gpu");
}