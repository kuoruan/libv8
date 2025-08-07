FROM gitpod/workspace-full

USER gitpod

RUN sudo apt-get -q update && \
    sudo apt-get install -yq ccache && \
    sudo rm -rf /var/lib/apt/lists/*

RUN sudo update-ccache-symlinks

ENV PATH="/usr/lib/ccache:$PATH"
