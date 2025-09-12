# syntax=docker/dockerfile:1.7
# Base: Ubuntu 22.04 + ROS 2 Humble
ARG BASE_IMAGE=ros:humble-ros-base
FROM ${BASE_IMAGE}

# ---------- Build args to toggle shell & editor ----------
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
ARG SHELL_FLAVOR=zsh     # zsh | bash
ARG EDITOR_FLAVOR=nvim   # nvim | vscode

ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=humble \
    WS_DIR=/workspaces/rsx-rover \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ---------- OS deps ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales sudo tzdata ca-certificates \
    git curl wget bash-completion \
    build-essential cmake pkg-config \
    python3-pip python3-venv python3-colcon-common-extensions \
    python3-rosdep python3-vcstool \
    iproute2 iputils-ping net-tools \
    less nano vim \
    # GUI tooling optional (rviz/rqt if you switch base to desktop)
    && rm -rf /var/lib/apt/lists/*

# ---------- Locale ----------
RUN locale-gen en_US.UTF-8

# ---------- User ----------
RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

# ---------- Optional shells & editors ----------
# Always ensure bash is present; add zsh/neovim conditionally
RUN set -eux; \
    if [ "${SHELL_FLAVOR}" = "zsh" ]; then \
        apt-get update && apt-get install -y zsh && rm -rf /var/lib/apt/lists/*; \
    fi; \
    if [ "${EDITOR_FLAVOR}" = "nvim" ]; then \
        apt-get update && apt-get install -y neovim && rm -rf /var/lib/apt/lists/*; \
    fi

# ---------- rosdep init (system-wide) ----------
RUN rosdep init || true
RUN rosdep update

# ---------- Entrypoint that overlays the workspace if built ----------
# Works regardless of user’s login shell.
COPY .devcontainer/entrypoint.sh /usr/local/bin/ros2_entrypoint.sh
RUN chmod +x /usr/local/bin/ros2_entrypoint.sh

# ---------- Developer quality of life ----------
# Auto-source ROS and (if present) the workspace in both shells.
RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> /etc/skel/.bashrc
RUN echo 'if [ -f "$WS_DIR/install/setup.bash" ]; then source "$WS_DIR/install/setup.bash"; fi' >> /etc/skel/.bashrc
RUN if [ "${SHELL_FLAVOR}" = "zsh" ]; then \
      echo 'emulate sh -c "source /opt/ros/$ROS_DISTRO/setup.bash" >/dev/null 2>&1' >> /etc/skel/.zshrc && \
      echo 'if [ -f "$WS_DIR/install/setup.zsh" ]; then source "$WS_DIR/install/setup.zsh"; fi' >> /etc/skel/.zshrc; \
    fi

# Apply the skeleton to our user
USER ${USERNAME}
WORKDIR ${WS_DIR}
RUN cp -n /etc/skel/.bashrc ~/.bashrc || true; \
    if [ "${SHELL_FLAVOR}" = "zsh" ]; then cp -n /etc/skel/.zshrc ~/.zshrc || true; fi

# Default shell inside container (only affects interactive sessions)
SHELL ["/bin/bash", "-lc"]

ENTRYPOINT ["/usr/local/bin/ros2_entrypoint.sh"]
CMD [ "bash" ]
