float3 octahedron_coords[6] =
{
  { 1, 0, 0 },{ 0, 1, 0 },{ 0, 0, 1 },
  { -1, 0, 0 },{ 0, -1, 0 },{ 0, 0, -1 }
};

float3 hexahedron_coords[8] =
{
  { 0.57735026919, 0.57735026919, 0.57735026919 },{ -0.57735026919, 0.57735026919, 0.57735026919 },
  { -0.57735026919, 0.57735026919, 0.57735026919 },{ -0.57735026919, 0.57735026919, -0.57735026919 },
  { -0.57735026919, -0.57735026919, 0.57735026919 },{ -0.57735026919, -0.57735026919, -0.57735026919 },
  { 0.57735026919, -0.57735026919, 0.57735026919 },{ 0.57735026919, -0.57735026919, -0.57735026919 }
};

float3 icosahedron_coords[12] =
{
  { 0.894427191, 0.4472135955, 0 },{ 0.894427191, -0.4472135955, 0 },{ -0.894427191, 0.4472135955, 0 },{ -0.894427191, -0.4472135955, 0 },
  { 0, 0.894427191, 0.4472135955 },{ 0, 0.894427191, -0.4472135955 },{ 0, -0.894427191, 0.4472135955 },{ 0, -0.894427191, -0.4472135955 },
  { 0.4472135955, 0, 0.894427191 },{ -0.4472135955, 0, 0.894427191 },{ 0.4472135955, 0, -0.894427191 },{ -0.4472135955, 0, -0.894427191 }
};