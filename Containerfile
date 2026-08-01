# Use the official Fedora Bootc base image
FROM quay.io/fedora/fedora-bootc:44

# 1. Set environment variables for Locale and system generation
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 2. Install RPM Fusion Free and Nonfree repositories explicitly for Fedora 44
RUN dnf -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-44.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-44.noarch.rpm

# 3. Install the dnf5 COPR plugin and enable the official Niri repository
RUN dnf -y install 'dnf5-command(copr)' && dnf -y copr enable yalter/niri
RUN dnf -y swap ffmpeg-free ffmpeg --allowerasing

# 4. Install Niri, cosmic-greeter, hardware accelerated drivers, Kitty, and essentials
RUN dnf -y upgrade --refresh && dnf -y install \
    --refresh \
    --allow-downgrade \
    --skip-broken \
    --nodocs \
    --exclude=amd-ucode-firmware,amd-gpu-firmware \
    niri \
    microcode_ctl \
    iwl7260-firmware \
    iwlax2xx-firmware \
    xwayland-satellite \
    waybar \
    ly \
    kitty \
    wlsunset \
    swayidle \
    swaylock \
    swaybg \
    wlogout \
    nautilus \
    qalculate \
    mediawriter \
    flatpak \
    mpv \
    firefox \
    intel-media-driver \
    libva-utils \ 
    htop \
    micro \
    fastfetch \
    iwd \
    && dnf -y remove firefox-langpacks alacritty wpa_supplicant \
    && dnf clean all

# 4.5 Tell NetworkManager to use iwd as the wifi backend
RUN mkdir -p /etc/NetworkManager/conf.d && \
    echo -e "[device]\nwifi.backend=iwd" > /etc/NetworkManager/conf.d/10-wifi-iwd.conf

# 5. Configure greetd to use cosmic-greeter as the default login manager
RUN echo -e '[default_session]\ncommand = "cosmic-greeter"\nuser = "greeter"' > /etc/greetd/config.toml

# 5. Set the system hostname to Orion
RUN echo "orion" > /etc/hostname
