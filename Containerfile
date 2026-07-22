# Use the official Fedora Bootc base image
FROM quay.io/fedora/fedora-bootc:44

# 1. Install RPM Fusion Free and Nonfree repositories explicitly for Fedora 44
RUN dnf -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm

# 2. Install the dnf5 COPR plugin and enable the official Niri repository
RUN dnf -y install 'dnf5-command(copr)' && dnf -y copr enable yalter/niri
RUN dnf -y swap ffmpeg-free ffmpeg --allowerasing

# 3. Install Niri, cosmic-greeter, hardware accelerated drivers, Kitty, and essentials
RUN dnf -y upgrade --refresh && dnf -y install \
    niri \
    xwayland-satellite \
    waybar \
    cosmic-greeter \
    greetd \
    kitty \
    wlsunset \
    swayidle \
    swaylock \
    swaybg \
    wlogout \
    dolphin \
    qalculate \
    mediawriter \
    flatpak \
    mpv \
    firefox \
    mesa-va-drivers-freeworld \
    intel-media-driver \
    libva-utils \ 
    htop \
    micro \
    fastfetch \
    && dnf clean all

# 4. Configure greetd to use cosmic-greeter as the default login manager
RUN echo -e '[default_session]\ncommand = "cosmic-greeter"\nuser = "greeter"' > /etc/greetd/config.toml

# 5. Set the system hostname to Orion
RUN echo "orion" > /etc/hostname
