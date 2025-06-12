FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
USER root

# --- 1. Install Base + Ceph + System Tools ---
RUN apt-get update && apt-get install -y \
    sudo \
    gnupg \
    curl \
    wget \
    net-tools \
    openssh-server \
    systemd \
    systemd-sysv \
    dbus \
    lvm2 \
    cryptsetup \
    btrfs-progs \
    xfsprogs \
    parted \
    gdisk \
    python3 \
    python3-pip \
    vim \
    tmux \
    less \
    htop \
    jq \
    bash-completion \
    chrony \
    iproute2 \
    iputils-ping \
    software-properties-common \
    unzip \
    ca-certificates \
    auditd \
    apparmor \
    nfs-common \
    ceph-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 2. Install OpenSCAP Tools ---
RUN apt-get update && apt-get install -y \
    openscap-scanner \
    libopenscap25t64 \
    openscap-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 3. Fetch and Apply SCAP Security Guide Remediation ---
RUN set -eux; \
    SSG_VERSION=$(curl -s https://api.github.com/repos/ComplianceAsCode/content/releases/latest | grep -oP '"tag_name": "\K[^"]+' || echo "0.1.66"); \
    echo "🔄 Using SCAP Security Guide version: $SSG_VERSION"; \
    SSG_VERSION_NO_V=$(echo "$SSG_VERSION" | sed 's/^v//'); \
    wget -O /ssg.zip "https://github.com/ComplianceAsCode/content/releases/download/${SSG_VERSION}/scap-security-guide-${SSG_VERSION_NO_V}.zip"; \
    mkdir -p /usr/share/xml/scap/ssg/content; \
    unzip -jo /ssg.zip "scap-security-guide-${SSG_VERSION_NO_V}/*" -d /usr/share/xml/scap/ssg/content/; \
    rm -f /ssg.zip; \
    SCAP_GUIDE="/usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml"; \
    echo "📘 Using SCAP guide: $SCAP_GUIDE"; \
    oscap xccdf eval \
        --remediate \
        --profile xccdf_org.ssgproject.content_profile_cis_level2_server \
        --results /root/oscap-results.xml \
        --report /root/oscap-report.html \
        "$SCAP_GUIDE" || echo "⚠️  SCAP evaluation completed with warnings"; \
    echo "✅ SCAP remediation complete."

# --- 4. Clean up SCAP ---
RUN rm -rf /usr/share/xml/scap/ssg/content && \
    apt remove -y openscap-scanner libopenscap25t64 && \
    apt autoremove -y && \
    apt clean && rm -rf /var/lib/apt/lists/*

# --- 5. Add Ceph Repos & Tools ---
RUN curl -fsSL https://download.ceph.com/keys/release.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/ceph.gpg && \
    echo "deb https://download.ceph.com/debian-quincy/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/ceph.list && \
    apt-get update && apt-get install -y \
    ceph \
    ceph-mgr \
    ceph-mon \
    ceph-osd \
    ceph-mds \
    radosgw && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 6. Enable systemd login ---
RUN mkdir -p /etc/systemd/system/getty@tty1.service.d && \
    echo '[Service]' > /etc/systemd/system/getty@tty1.service.d/override.conf && \
    echo 'ExecStart=' >> /etc/systemd/system/getty@tty1.service.d/override.conf && \
    echo 'ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM' >> /etc/systemd/system/getty@tty1.service.d/override.conf

# --- 7. Clean final image and setup ---
RUN mkdir -p /var/log/audit && \
    update-initramfs -u && \
    apt-get clean && \
    rm -rf /usr/src/* /tmp/* /var/tmp/* /var/lib/apt/lists/*

# --- 8. Set up systemd boot ---
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
