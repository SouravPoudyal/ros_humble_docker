#!/bin/bash

set -e

# Source the ROS 2 setup file
source /opt/ros/humble/install/setup.bash

echo "Provided arguments: $@"

exec $@
