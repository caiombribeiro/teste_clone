
float4 simple_point_light_pos_radius = (0, 0, 0, 0);
float4 simple_point_light_color_spec = (0, 0, 0, 0);
float4 simple_point_light_box_center = (0, 0, 0, 0);
float4 simple_point_light_box_extent = (0, 0, 0, 0);

macro INIT_AND_USE_SIMPLE_POINT_LIGHT(code)
  if (dynamic_lights_count != lights_off)
  {
    (code) {
      simple_point_light_pos_radius@f4 = simple_point_light_pos_radius;
      simple_point_light_color_spec@f4 = simple_point_light_color_spec;
      simple_point_light_box_center@f3 = simple_point_light_box_center;
      simple_point_light_box_extent@f3 = simple_point_light_box_extent;
    }
  }

  hlsl(code) {
    #ifndef LAMBERT_LIGHT
      #define LAMBERT_LIGHT 1
    #endif
    #ifndef DYNAMIC_LIGHTS_SPECULAR
      #define DYNAMIC_LIGHTS_SPECULAR 1
    #endif
    #include "punctualLights.hlsl"

    half3 get_dynamic_lighting(ProcessedGbuffer gbuffer, float3 worldPos, float3 view,
      float w, float2 screenpos, float NoV, float3 specularColor, float2 tc, half enviAO)
    {
      half3 dynamicLighting = half3(0, 0, 0);
    ##if dynamic_lights_count != lights_off
      if (all(abs(simple_point_light_box_center.xyz - worldPos.xyz) < simple_point_light_box_extent))
      {
        dynamicLighting = perform_point_light(
          worldPos.xyz, view, NoV, gbuffer, specularColor,
          gbuffer.extracted_albedo_ao,
          gbuffer.ao, simple_point_light_pos_radius,
          simple_point_light_color_spec, float4(0, 0, 0, 0),
          screenpos);
        dynamicLighting *= enviAO * 0.5 + 0.5;
      }
    ##endif
      return dynamicLighting;
    }
  }
endmacro
