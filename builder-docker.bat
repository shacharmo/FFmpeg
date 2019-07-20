@echo off
echo Creating archive from current branch
git archive --output docker/source.tar head
echo Starting docker build
cd docker
build.bat