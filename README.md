# Robotics for Space Exploration (RSX)

## What is RSX?

Robotics for Space Exploration (RSX) is the University of Toronto Faculty of Applied Science and Engineering’s affiliated Mars Rover design team. 
RSX designs, builds, and competes with Mars Rovers in international competitions, such as the University Rover Challenge, European Rover Challenge, and Canadian International Rover Challenge. 
RSX was formed in 2013 by passionate roboticists, space enthusiasts, and undergraduate students. RSX challenges students to be innovative, striving to push boundaries in extraterrestrial exploration. We encourage students to learn about, experiment with, and develop proficiency in engineering technology, and promote growth through hands-on experience. 

For us, the sky is not the limit – it’s just in the way.

For more information, visit our [website](https://rsx.skule.ca/). 

## Repository Details 

We primarily develop is C++ and Python using ROS noetic. 

## Getting Started 

Note: It is recommended to set up [ssh keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

### Requirements

- Ubuntu 20.04
- ROS Noetic

### On Ubuntu Focal w/ ROS noetic 
```
cd ~
mkdir -p rover_ws/src 
git clone git@github.com:rsx-utoronto/rsx-rover.git
cd ..
catkin build
```


## Docker Instructions
1. Build the image
```bash
# zsh + Neovim (default)
./docker-scripts/build.sh zsh nvim

# bash + VS Code (i.e., don’t install nvim)
./docker-scripts/build.sh bash vscode
```

2. Start the container.
```bash
# Linux + Hyprland (Wayland)
# Notes:
# Hyprland commonly wayland-1
# xhost +local: is used in wayland for using x11 when using Gazebo
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"   
xhost +local:
./docker-scripts/up.sh hyprland

# Linux + X11
xhost +local:
./docker-scripts/up.sh x11

# macOS
./docker-scripts/up.sh mac

# Windows (PowerShell)
./docker-scripts/windows-up.ps1 -Profile windows -Shell zsh -Editor nvim
```

3. Enter the dev shell.
```bash
# choose service if you used a profile name (rsxrover, rsxrover-x11, rsxrover-wayland, etc.)
./docker-scripts/enter.sh rsxrover
```

4. Inside the container: Install deps & build
```bash
./docker-scripts/deps.sh
./docker-scripts/build_ws.sh
# run your nodes/launch files; ROS environment is sourced automatically by the entrypoint
```


