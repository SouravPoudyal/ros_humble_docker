 # Use the Jetson Nano-compatible ROS 2 Humble image
 FROM dustynv/ros:humble-desktop-l4t-r32.7.1

 # Example of installing programs
 RUN apt-get update \
     && apt-get install -y apt-utils \
     && apt-get install -y \
     vim \
     evtest \
     joystick \
     && rm -rf /var/lib/apt/lists/*

 # Example of copying a file
 COPY config/ /site_config/

 # Copy the camera-test.py file to a folder in the Docker image
 COPY camera-test.py embedded-cv/freenove_camera/

 # Create a non-root user for security purposes
 ARG USERNAME=ros_bumperbot
 ARG USER_UID=1000
 ARG USER_GID=$USER_UID

 RUN groupadd --gid $USER_GID $USERNAME \
   && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
   && mkdir -p /home/$USERNAME/.config \
   && mkdir -p /home/$USERNAME/.ros/log \
   && mkdir -p /home/$USERNAME/.rviz2 \
   && chown -R $USER_UID:$USER_GID /home/$USERNAME/.config \
   && chown -R $USER_UID:$USER_GID /home/$USERNAME/.ros \
   && chown -R $USER_UID:$USER_GID /home/$USERNAME/.rviz2 \
   && mkdir -p /home/$USERNAME/.vscode-server \
   && chown -R $USER_UID:$USER_GID /home/$USERNAME/.vscode-server

 # Set up sudo
 RUN apt-get update \
   && apt-get install -y sudo \
   && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
   && chmod 0440 /etc/sudoers.d/$USERNAME \
   && rm -rf /var/lib/apt/lists/*

 # Create the XDG_RUNTIME_DIR directory and set permissions
 RUN mkdir -p /tmp/runtime-$USERNAME \
     && chown $USER_UID:$USER_GID /tmp/runtime-$USERNAME \
     && chmod 0700 /tmp/runtime-$USERNAME

 # Set environment variables
 ENV XDG_RUNTIME_DIR=/tmp/runtime-$USERNAME

 # Copy the entrypoint and bashrc scripts so the container's environment sets up correctly
 COPY entrypoint.sh /entrypoint.sh
 COPY bashrc /home/${USERNAME}/.bashrc

 # Set the default user to the non-root user created
 USER $USERNAME

 # Set up entrypoint and default command
 ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
 CMD ["bash"]