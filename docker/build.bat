@echo off
setlocal

rem Get args from Dockerfile
for /f "tokens=2 delims==" %%a in ('type Dockerfile^|find "ARG BASE_IMAGE="') do (
  set orgBaseImage=%%a & goto :continue
)
:continue
set orgBaseImage=%orgBaseImage:~0,-1%

for /f "tokens=2 delims==" %%a in ('type Dockerfile^|find "ARG FFMPEG_VERSION="') do (
  set orgFfmpegVersion=%%a & goto :continue
)
:continue
set orgFfmpegVersion=%orgFfmpegVersion:~0,-1%

rem 
if "%1"=="-q" (
  set "baseImage=%orgBaseImage%"
  set "ffmpegVersion=%orgffmpegVersion%"
  goto :check
)

rem Get overwrites from user
set "baseImage="
set /p baseImage="Enter base image (empty for '%orgBaseImage%'):"
if "%baseImage%"=="" (
	set "baseImage=%orgBaseImage%"
)
set "ffmpegVersion="
set /p ffmpegVersion="Enter ffmpeg version (empty for '%orgFfmpegVersion%'):"
if "%ffmpegVersion%"=="" (
	set "ffmpegVersion=%orgffmpegVersion%"
)

:check
for /f %%i in ('docker images -q webiks/%baseImage%-ffmpeg-%ffmpegVersion%') do set imageId=%%i
if NOT "%imageId%"=="" (
  if "%1"=="-q" (  
    echo "Image already exists"
    exit
  ) else (
    set /p create="Image already exists, re-create it [y/n]?"
    if NOT "%create%"=="y" (
      exit
    )
  )
)

:build
rem docker build using arguments
docker build --build-arg BASE_IMAGE=%baseImage% --build-arg FFMPEG_VERSION=%ffmpegVersion% -t webiks/%baseImage%-ffmpeg-%ffmpegVersion% .