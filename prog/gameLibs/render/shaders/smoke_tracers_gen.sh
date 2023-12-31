include "shader_global.sh"
include "frustum.sh"
include "globtm.sh"
hlsl {
  #include <smokeTracers.hlsli>
}
//  updateCommands_cs = new_compute_shader("update_tracer_commands_cs");
//  createCommands_cs = new_compute_shader("create_tracer_commands_cs");
//  cullTracers_cs = new_compute_shader("cull_tracers_cs");
shader create_tracer_commands_cs
{
  ENABLE_ASSERT(cs)
  hlsl(cs) {
    RWStructuredBuffer<GPUSmokeTracerVertices> tracerVerts : register(u0);
    RWStructuredBuffer<GPUSmokeTracerDynamic>  tracersDynamic : register(u1);
    RWStructuredBuffer<GPUSmokeTracer>  tracers : register(u2);

    float currentTime: register(c2);
    uint commandsCount: register(c3);
    TracerCreateCommand commands[TRACER_MAX_CREATE_COMMANDS] : register(c4);

    [numthreads( TRACER_COMMAND_WARP_SIZE, 1, 1 )]
    void main( uint3 dtId : SV_DispatchThreadID )
    {
      uint commandId = dtId.x;
      if (commandId>=commandsCount)
        return;
      TracerCreateCommand cmd = commands[commandId];
      float len = length(cmd.dir);
      float3 ndir = cmd.dir/len;
      structuredBufferAt(tracers, cmd.id).startTime = currentTime;
      structuredBufferAt(tracers, cmd.id).ttl = cmd.ttl;
      structuredBufferAt(tracers, cmd.id).smoke_color_density = cmd.smoke_color;
      structuredBufferAt(tracers, cmd.id).head_color = cmd.head_color__burnTime.rgb;
      structuredBufferAt(tracers, cmd.id).burnTime = cmd.head_color__burnTime.a;
      structuredBufferAt(tracers, cmd.id).radiusStart = len;
      structuredBufferAt(tracers, cmd.id).dir = ndir;//actually it will be always constant for tracer
      structuredBufferAt(tracers, cmd.id).p0 = cmd.pos0;

      structuredBufferAt(tracersDynamic, cmd.id).movingDir = ndir;
      structuredBufferAt(tracersDynamic, cmd.id).firstVert_totalVerts = 1;
      structuredBufferAt(tracersDynamic, cmd.id).len = 0;
      structuredBufferAt(tracersDynamic, cmd.id).radius = len*2;
      structuredBufferAt(tracerVerts, cmd.id*TRACER_SEGMENTS_COUNT + 0).pos_dist = float4(cmd.pos0, 0);
      structuredBufferAt(tracerVerts, cmd.id*TRACER_SEGMENTS_COUNT + 0).time = 0;
    }
  }
  compile("target_cs", "main");
}

shader update_tracer_commands_cs
{
  ENABLE_ASSERT(cs)
  hlsl(cs) {
    RWStructuredBuffer<GPUSmokeTracerVertices> tracerVerts : register(u0);
    RWStructuredBuffer<GPUSmokeTracerDynamic>  tracersDynamic : register(u1);
    StructuredBuffer<GPUSmokeTracer>  tracers : register(t0);
    float currentTime: register(c2);
    uint commandsCount: register(c3);
    TracerUpdateCommand commands[TRACER_MAX_UPDATE_COMMANDS] : register(c4);

    [numthreads( TRACER_COMMAND_WARP_SIZE, 1, 1 )]
    void main( uint3 dtId : SV_DispatchThreadID )
    {
      uint commandId = dtId.x;
      if (commandId>=commandsCount)
        return;
      TracerUpdateCommand cmd = commands[commandId];
      uint vertCnt = structuredBufferAt(tracersDynamic, cmd.id).firstVert_totalVerts;
      uint firstVert = vertCnt>>16;
      vertCnt &= 0xFFFF;

      uint cpoint = vertCnt%TRACER_SEGMENTS_COUNT;
      //==
      //cpoint = min(verts, TRACER_SEGMENTS_COUNT-1);
      //==
      uint startVertId = cmd.id*TRACER_SEGMENTS_COUNT;
      uint lastFixedVertexId = (cpoint+(TRACER_SEGMENTS_COUNT-2))%TRACER_SEGMENTS_COUNT;
      uint prevVertexId = (cpoint+TRACER_SEGMENTS_COUNT-1)%TRACER_SEGMENTS_COUNT;
      float4 prev_pos_dist = structuredBufferAt(tracerVerts, startVertId + lastFixedVertexId).pos_dist;
      float3 lastFixedVertexPos = prev_pos_dist.xyz;
      float3 travelVec = cmd.pos-lastFixedVertexPos;
      float travelDist = length(travelVec);
      if (travelDist < 0.001 || distance(structuredBufferAt(tracerVerts, startVertId + prevVertexId).pos_dist.xyz, cmd.pos)<0.0001)
        return;
      float3 travelDir = travelVec/travelDist;
      const float angleThreshold = 0.9986295347545738;//cos(3 deg);
      //const float movingDistanceConstMinThreshold = 1.0;
      //const float movingDistanceConstThreshold = 4.0;
      //const float movingDistanceTimeScaledThreshold = 64.f;
      //const float movingDistanceMaxThreshold = 256.f;
      
      float tracerTime = max(0, currentTime-structuredBufferAt(tracers, cmd.id).startTime);
      //const float movingDistanceThreshold = min(movingDistanceConstThreshold+tracerTime*movingDistanceTimeScaledThreshold, movingDistanceMaxThreshold);
      const float movingDistanceThreshold = 64;

      float newTravelDist = travelDist;
      bool oldVertIsDead = firstVert + 2 < vertCnt && structuredBufferAt(tracerVerts, startVertId + ((firstVert+1)%TRACER_SEGMENTS_COUNT)).time < tracerTime-structuredBufferAt(tracers, cmd.id).ttl;

      BRANCH
      if (((vertCnt-firstVert) < TRACER_SEGMENTS_COUNT || structuredBufferAt(tracerVerts, startVertId + cpoint).time < tracerTime-structuredBufferAt(tracers, cmd.id).ttl) &&
           (vertCnt < 2 || dot(travelDir, structuredBufferAt(tracersDynamic, cmd.id).movingDir) < angleThreshold || travelDist > movingDistanceThreshold))
      {
        structuredBufferAt(tracersDynamic, cmd.id).movingDir = travelDir;

        FLATTEN
        if (cpoint == (firstVert%TRACER_SEGMENTS_COUNT))
          firstVert = firstVert+1;
        structuredBufferAt(tracersDynamic, cmd.id).firstVert_totalVerts = (vertCnt+1) | ((firstVert)<<16);
        float4 prev_pos_dist = structuredBufferAt(tracerVerts, startVertId + (cpoint+(TRACER_SEGMENTS_COUNT-1))%TRACER_SEGMENTS_COUNT).pos_dist;
        newTravelDist = prev_pos_dist.w + length(cmd.pos - prev_pos_dist.xyz);
      } else
      {
        cpoint = (lastFixedVertexId+1)%TRACER_SEGMENTS_COUNT;
        newTravelDist += prev_pos_dist.w;
      }

      structuredBufferAt(tracerVerts, startVertId + cpoint).pos_dist = float4(cmd.pos, newTravelDist);
      structuredBufferAt(tracerVerts, startVertId + cpoint).time = tracerTime;
      //OBB update (max only)
      float3 fromStart = (cmd.pos-structuredBufferAt(tracers, cmd.id).p0);
      float nlen = dot(fromStart, structuredBufferAt(tracers, cmd.id).dir);
      structuredBufferAt(tracersDynamic, cmd.id).len = max(nlen, structuredBufferAt(tracersDynamic, cmd.id).len);
      structuredBufferAt(tracersDynamic, cmd.id).radius = max(length(fromStart - nlen*structuredBufferAt(tracers, cmd.id).dir), structuredBufferAt(tracersDynamic, cmd.id).radius);
    }
  }
  compile("target_cs", "main");
}

shader cull_tracers_cs
{
  (cs) {
    world_view_pos@f3 = world_view_pos;
    globtm_psf@f44 = { globtm_psf_0, globtm_psf_1, globtm_psf_2, globtm_psf_3 };
    local_view_z@f3 = local_view_z;
  }

  INIT_AND_USE_FRUSTUM_CHECK_CS()
  hlsl(cs) {
    RWStructuredBuffer<GPUSmokeTracerHeadRender>  culled_tracer_heads : register(u0);
    RWStructuredBuffer<GPUSmokeTracerTailRender>  culled_tracer_tails : register(u1);
    RWStructuredBuffer<GPUSmokeTracerDynamic>  tracersDynamic : register(u2);//only RW for updating firstVert!
    RWByteAddressBuffer tracer_indirection_buffer : register(u3);
    StructuredBuffer<GPUSmokeTracer>  tracers : register(t8);
    StructuredBuffer<GPUSmokeTracerVertices>  tracerVerts : register(t9);
    float4 smoke_trace_current_time: register(c12);
    uint commandsCount: register(c13);
    uint4 tracerIds[TRACER_MAX_CULL_COMMANDS] : register(c14);

    void make_basis(float3 ndir, out float3 left, out float3 up)
    {
      left = normalize(cross(float3(0,1,0), ndir));
      up = cross(ndir, left);
      left = cross(up, ndir);
    }

    [numthreads( TRACER_CULL_WARP_SIZE, 1, 1 )]
    void main( uint3 dtId : SV_DispatchThreadID )
    {
      uint commandId = dtId.x;
      if (commandId>=commandsCount)
        return;
      uint4 tracer4Cmd = tracerIds[commandId/8];
      uint cmdIdAttr = (commandId/2)%4;
      uint id = cmdIdAttr == 0 ? tracer4Cmd.x : (cmdIdAttr == 1 ? tracer4Cmd.y : (cmdIdAttr == 2 ? tracer4Cmd.z : tracer4Cmd.w));
      id = (commandId%2) ? (id>>16) : (id&0xFFFF);

      uint firstVert_totalVerts = tracersDynamic[id].firstVert_totalVerts;
      uint vertCnt = firstVert_totalVerts;
      uint firstVert = vertCnt>>16;
      vertCnt &= 0xFFFF;

      if (vertCnt<1)//fixme: should never happen, if add check on cpu side
        return;

      float tracerTime = smoke_trace_current_time.x - tracers[id].startTime;
      uint startVertId = id*TRACER_SEGMENTS_COUNT;
      bool oldVertIsDead = firstVert + 2 < vertCnt && tracerVerts[startVertId + ((firstVert+1)%TRACER_SEGMENTS_COUNT)].time < tracerTime-tracers[id].ttl;

      BRANCH
      if (oldVertIsDead)
      {
        firstVert = firstVert+1;
        firstVert_totalVerts = vertCnt | ((firstVert)<<16);
        tracersDynamic[id].firstVert_totalVerts = firstVert_totalVerts;
        //todo: softly
      }

      uint vertId2 = (vertCnt-1)%TRACER_SEGMENTS_COUNT + startVertId;
      uint firstVertId = firstVert%TRACER_SEGMENTS_COUNT + startVertId;

      float3 p0 = tracerVerts[firstVertId].pos_dist.xyz + get_tracers_wind(tracerVerts[firstVertId].time);
      float3 p1 = tracerVerts[vertId2].pos_dist.xyz + get_tracers_wind(tracerVerts[vertId2].time);

      float3 boxMin = min(p0, p1), boxMax = max(p0,p1);
      float longestTime = (tracerTime-tracerVerts[firstVertId].time);
      float radiusStart = tracers[id].radiusStart;
      float currentRadius = radiusStart + 
        (get_tracers_max_turbulence_radius(radiusStart) + get_tracers_max_wind_radius(radiusStart))*sqrt(longestTime);

      boxMin -= currentRadius; boxMax += currentRadius;
      if (!testBoxB(boxMin, boxMax))
        return;
      //todo: culling in local space
      /*float3 left, up;
      make_basis(tracers[id].dir, left, up);
      float3x3 tracerSpace = transpose(float3x3(left, up, tracers[id].dir));
      float3 localPos = -mul(tracers[id].p0, tracerSpace);
      float4x4 local_space = float4x4(
        float4(tracerSpace[0], 0),
        float4(tracerSpace[1], 0),
        float4(tracerSpace[2], 0),
        float4(localPos, 1)
      );
      float4x4 m2 = mul(transpose(local_space), globtm_psf);//mul(p,matrix)
      float4 planes03X, planes03Y, planes03Z, planes03W, plane4, plane5;
      get_frustum_planes(transpose(m2), planes03X, planes03Y, planes03Z, planes03W, plane4, plane5);

      if (!baseTestBoxB(-(tracers[id].radius+currentRadius), tracers[id].radius+currentRadius + float3(0,0,tracers[id].len),//fixme wind radius
        planes03X, planes03Y, planes03Z, planes03W, plane4, plane5))
        return;*/

      GPUSmokeTracerTailRender tail=(GPUSmokeTracerTailRender)0;
      tail.firstVert_totalVerts = firstVert_totalVerts;
      tail.startTime = tracers[id].startTime;
      tail.smoke_color_density = tracers[id].smoke_color_density;
      tail.ttl = tracers[id].ttl;
      tail.radiusStart = tracers[id].radiusStart;//can be compressed
      tail.id = id*2 + (dot(tracers[id].dir, local_view_z) > 0 ? 1 : 0);

      if (tail.smoke_color_density.w > 0) //to cull tail without smoke
      {
        uint tailIdx;
        tracer_indirection_buffer.InterlockedAdd((1 + 4) * 4, 1u, tailIdx); // +4 because we add instance to second indirect buffer
        culled_tracer_tails[tailIdx] = tail;
      }
      //=====

      //head
      uint vertId1 = (vertCnt-2)%TRACER_SEGMENTS_COUNT + startVertId;
      float head_time = (tracerVerts[vertId2].time+tracers[id].startTime);
      float decayTime = smoke_trace_current_time.x-head_time;

      float exposure_time = smoke_trace_current_time.z;//+1./120;
      float burnEffect = saturate((tracers[id].burnTime - tracerTime)*(20));
      if (decayTime<exposure_time && burnEffect>0)
      {
        GPUSmokeTracerHeadRender renderBox=(GPUSmokeTracerHeadRender)0;
        float3 p0 = tracerVerts[vertId1].pos_dist.xyz;
        float3 p1 = tracerVerts[vertId2].pos_dist.xyz;
        float3 dir = (p1-p0);
        float time_to_exposure = exposure_time-decayTime;//+1./120.; //(120hz)
        float prev_head_time = (tracerVerts[vertId1].time+tracers[id].startTime);
        float3 vel = (p1.xyz-p0.xyz)/(head_time-prev_head_time);
        float start_p1_length = length(p1 - tracers[id].p0);
        float vel_length = length(vel);
        float vel_multiplier = min(time_to_exposure, tracerTime-decayTime);
        if (vel_length > 0.0)
          vel_multiplier = clamp(vel_multiplier, 0.0, start_p1_length / vel_length);
        renderBox.p0.xyz = p1.xyz - vel*vel_multiplier;
        renderBox.p1 = p1;
        float viewDist = distance(world_view_pos, p1);
        float pixel_radius = 1.5*viewDist * smoke_trace_current_time.w;
        float tracerRadius = radiusStart*0.0125;
        float cRadius = max(tracerRadius, pixel_radius);
        float fade = sqrt(tracerRadius / cRadius);
        float boxRadius = cRadius;
        renderBox.radius = boxRadius;
        //float time_opacity = 1-saturate((tracerTime-tracerVerts[vertId2].time)/tracers[id].ttl);
        float time_opacity = 1;//-saturate(decayTime/exposure_time);
        time_opacity *= burnEffect;
        float density = time_opacity*fade;
        float3 tracer_color = 8*tracers[id].head_color.xyz;//==
        renderBox.color = float4(tracer_color*burnEffect, density);
        float3 boxMin = min(renderBox.p0.xyz, renderBox.p1.xyz), boxMax = max(renderBox.p0.xyz, renderBox.p1.xyz);
        boxMin -= boxRadius; boxMax += boxRadius;

        if (testBoxB(boxMin, boxMax))
        {
          uint headIdx;
          tracer_indirection_buffer.InterlockedAdd(1 * 4, 1u, headIdx);
          culled_tracer_heads[headIdx] = renderBox;
        }
      }
    }
  }
  compile("target_cs", "main");
}

shader clear_indirect_buffers
{
  ENABLE_ASSERT(cs)
  hlsl(cs) {
    RWByteAddressBuffer tracer_indirection_buffer : register(u3);

    [numthreads( 2, 1, 1 )]
    void main(uint dtId : SV_DispatchThreadID)
    {
      storeBuffer(tracer_indirection_buffer, (1 + dtId * 4) * 4, 0);
    }
  }
  compile("target_cs", "main");
}
