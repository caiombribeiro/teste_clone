pushd prog\tools
call build_dagor3_cdk_mini.cmd
if errorlevel 1 (
  echo build_dagor3_cdk_mini.cmd failed, trying once more...
  call build_dagor3_cdk_mini.cmd
)
if errorlevel 1 (
  echo failed to build CDK, stop!
  exit /b 1
)
popd

pushd prog\tools\dargbox
call create_vfsroms.bat
cd shaders
call compile_shaders_pc11.bat
popd

pushd prog\samples\physTest
jam
jam -f jamfile-test-jolt
cd shaders
call compile_game_shaders-dx11.bat
popd

pushd samples\skiesSample\prog
jam
cd shaders
call compile_shaders_dx12.bat
call compile_shaders_pc11.bat
call compile_shaders_tools.bat
popd

pushd samples\testGI\prog
jam
cd shaders
call compile_shaders_dx12.bat
call compile_shaders_pc11.bat
call compile_shaders_tools.bat
popd
