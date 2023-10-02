#!/bin/bash

clear
echo "Cleaning build artifacts from projects"

PROJECTS=$(ls -d */)
for project in ${PROJECTS}
do
  echo "Cleaning project: ${project}..."
  rm -rf ${project}bin
  rm -rf ${project}obj/Debug
  rm -rf ${project}obj/Release
done

echo " "
echo "Done."
echo " "
