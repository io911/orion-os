# Use the official Fedora Bootc base image
FROM quay.io/fedora/fedora-bootc:44

# 1. Install RPM Fusion Free and Nonfree repositories explicitly for Fedora 44
RUN dnf -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm

# 2. Enable the official Niri Copr repository
RUN dnf -y copr enable yalter/niri
RUN dnf -y swap ffmpeg-free ffmpeg --allowerasing

# 3. Install Niri, cosmic-greeter, hardware accelerated drivers, Kitty, and essentials
RUN dnf -y install \
    niri \
    xwayland-satellite \
    waybar \
    cosmic-greeter \
    greetd \
    kitty \
    wl-sunset \
    swayidle \
    swaybg \
    wlogout \
    dophin \
    qalculate \
    mpv \
    firefox \
    mesa-dri-drivers \
    mesa-va-drivers-freeworld \
    mesa-vdpau-drivers-freeworld \
    intel-media-driver \
    libva \
    libva-utils \ 
    htop \
    micro \
    pipewire \
    wireplumber \
    git \
    fastfetch \
    && dnf clean all

# 4. Configure greetd to use cosmic-greeter as the default login manager
RUN echo -e '[default_session]\ncommand = "cosmic-greeter"\nuser = "greeter"' > /etc/greetd/config.toml

# 5. Enable the greetd background service
RUN systemctl enable greetd.service

# 6. Set the system hostname to Orion
RUN echo "orion" > /etc/hostname
