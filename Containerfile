# Use the official Fedora Bootc base image. BASE_IMAGE argument is linked to build.yml file.
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Set environment variables for Locale
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# 1. Consolidated DNF transaction with persistent package cache enablement
RUN dnf -y install --setopt=max_parallel_downloads=10 \
      glibc-langpack-en \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
      'dnf5-command(copr)' \
    && dnf -y copr enable yalter/niri \
    && dnf -y swap ffmpeg-free ffmpeg --allowerasing \
    && dnf -y install --setopt=keepcache=1 \
        --skip-broken \
        --nodocs \
        --exclude=amd-ucode-firmware,amd-gpu-firmware \
        niri iwlwifi-mvm-firmware xwayland-satellite waybar ly kitty wlsunset swayidle swaylock swaybg wlogout nautilus gnome-calculator mediawriter flatpak firefox intel-media-driver libva-utils \
        htop neovim fastfetch systemd-networkd iwd xdg-desktop-portal-gnome xdg-desktop-portal-wlr mate-polkit eza zoxide fish \
    && dnf -y --setopt=tsflags=noscripts remove firefox-langpacks alacritty wpa_supplicant NetworkManager*

# 2. Consolidated system and service configurations into a single image layer
RUN mkdir -p /etc/systemd/network /etc/iwd && \
    echo -e "[Match]\nName=wlan* wlp*\n\n[Network]\nDHCP=yes\nIgnoreCarrierLoss=3s" > /etc/systemd/network/25-wireless.network && \
    echo -e "[General]\nEnableNetworkConfiguration=false" > /etc/iwd/main.conf && \
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    systemctl enable systemd-networkd systemd-resolved iwd ly@tty2.service && \
    systemctl disable getty@tty2.service \
    # Enable Ly to login with niri without getting "CmdExecutedFailed" which is blocked by SELinux
    semanage permissive -a unconfined_service_t
