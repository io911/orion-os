# Use the official Fedora Bootc base image. BASE_IMAGE argument is linked to build.yml file.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG BASE_IMAGE

# 1. Set environment variables for Locale and system generation
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN dnf -y install glibc-langpack-en && dnf clean all
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 2. Install RPM Fusion Free and Nonfree repositories explicitly for Fedora 44
RUN dnf -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 3. Install the dnf5 COPR plugin and enable the official Niri repository
RUN dnf -y install 'dnf5-command(copr)' && dnf -y copr enable yalter/niri
RUN dnf -y swap ffmpeg-free ffmpeg --allowerasing

# 4. Install Niri, drivers, Kitty and essentials
RUN dnf -y upgrade --refresh && dnf -y install \
    --refresh \
    --allow-downgrade \
    --skip-broken \
    --nodocs \
    --exclude=amd-ucode-firmware,amd-gpu-firmware \
    niri \
    iwlwifi-mvm-firmware \
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
    gnome-calculator \
    mediawriter \
    fuse-libs \
    flatpak \
    firefox \
    intel-media-driver \
    libva-utils \ 
    htop \
    neovim \
    fastfetch \
    systemd-networkd \
    iwd \
    xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-wlr \
    mate-polkit \
    eza zoxide \
    && dnf -y remove firefox-langpacks alacritty wpa_supplicant NetworkManager* \
    && dnf clean all

# 5. Configure systemd-networkd to handle wireless links and run DHCP automatically
RUN mkdir -p /etc/systemd/network && \
    echo -e "[Match]\nName=wlan* wlp*\n\n[Network]\nDHCP=yes\nIgnoreCarrierLoss=3s" > /etc/systemd/network/25-wireless.network

# 6. Configure iwd to operate independently and use systemd-networkd as its backend
RUN mkdir -p /etc/iwd && \
    echo -e "[General]\nEnableNetworkConfiguration=false" > /etc/iwd/main.conf

# 7. Enable the modern alternative systemd stack
RUN systemctl enable systemd-networkd systemd-resolved iwd

# 8. Pre-stage systemd-resolved for standard DNS handling
RUN ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# 9. Fix system-wide localectl default config
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 10. Enable Ly on TTY2 and forcefully override/disable any conflicting DM
RUN systemctl enable ly@tty2.service

# 11. Disable getty on the target TTY to prevent screen flickering
RUN systemctl disable getty@tty2.service
