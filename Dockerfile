# syntax=docker/dockerfile:1.7
ARG BASE_IMAGE=ros:humble-ros-base
FROM ${BASE_IMAGE}

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
ARG SHELL_FLAVOR=zsh     # zsh | bash
ARG EDITOR_FLAVOR=nvim   # nvim | vscode

ENV DEBIAN_FRONTEND=noninteractive \
    ROS_DISTRO=humble \
    WS_DIR=/workspaces/rsx-rover \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    # toggle dotfiles sync on entry
    SYNC_DOTFILES_ON_START=1

# ---------- Base OS deps ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales sudo tzdata ca-certificates \
    git curl wget bash-completion \
    build-essential cmake pkg-config \
    python3-pip python3-venv python3-colcon-common-extensions \
    python3-rosdep python3-vcstool \
    iproute2 iputils-ping net-tools \
    less nano vim \
    rsync \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

# ---------- User ----------
RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

# ---------- Optional shells & editors ----------
RUN set -eux; \
    if [ "${SHELL_FLAVOR}" = "zsh" ]; then \
        apt-get update && apt-get install -y zsh && rm -rf /var/lib/apt/lists/*; \
    fi; \
    if [ "${EDITOR_FLAVOR}" = "nvim" ]; then \
        apt-get update && apt-get install -y neovim && rm -rf /var/lib/apt/lists/*; \
    fi

# ---------- rosdep ----------
RUN rosdep init || true
RUN rosdep update

# ---------- Entry + dotfiles sync helpers ----------
COPY .devcontainer/entrypoint.sh /usr/local/bin/ros2_entrypoint.sh
COPY .devcontainer/sync_dotfiles.sh /usr/local/bin/sync_dotfiles.sh
RUN chmod +x /usr/local/bin/ros2_entrypoint.sh /usr/local/bin/sync_dotfiles.sh

# ---------- Auto-source ROS/workspace for interactive shells ----------
RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' >> /etc/skel/.bashrc
RUN echo 'if [ -f "$WS_DIR/install/setup.bash" ]; then source "$WS_DIR/install/setup.bash"; fi' >> /etc/skel/.bashrc
RUN if [ "${SHELL_FLAVOR}" = "zsh" ]; then \
      echo 'emulate sh -c "source /opt/ros/$ROS_DISTRO/setup.bash" >/dev/null 2>&1' >> /etc/skel/.zshrc && \
      echo 'if [ -f "$WS_DIR/install/setup.zsh" ]; then source "$WS_DIR/install/setup.zsh"; fi' >> /etc/skel/.zshrc; \
    fi

USER ${USERNAME}
WORKDIR ${WS_DIR}
RUN cp -n /etc/skel/.bashrc ~/.bashrc || true; \
    if [ "${SHELL_FLAVOR}" = "zsh" ]; then cp -n /etc/skel/.zshrc ~/.zshrc || true; fi

SHELL ["/bin/bash", "-lc"]
ENTRYPOINT ["/usr/local/bin/ros2_entrypoint.sh"]
CMD [ "bash" ]
