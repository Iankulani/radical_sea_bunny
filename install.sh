#!/bin/bash
# RADICAL SEA BUNNY - Linux Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🐇 RADICAL SEA BUNNY v2.0.0 - Installation${NC}"
echo -e "${BLUE}🌊 Ultimate Cybersecurity Command & Control Platform${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  Running without sudo. Some features may not work.${NC}"
    echo -e "${YELLOW}   Consider running with: sudo $0${NC}"
    echo ""
fi

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     OS_TYPE="Linux";;
    Darwin*)    OS_TYPE="macOS";;
    *)          OS_TYPE="UNKNOWN";;
esac

echo -e "${GREEN}Detected OS: ${OS_TYPE}${NC}"

# Install system dependencies
echo -e "\n${BLUE}📦 Installing system dependencies...${NC}"

if [ "$OS_TYPE" = "Linux" ]; then
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        echo -e "${GREEN}Using APT package manager${NC}"
        apt-get update
        apt-get install -y \
            python3 \
            python3-pip \
            python3-venv \
            nmap \
            curl \
            netcat-openbsd \
            iputils-ping \
            traceroute \
            dnsutils \
            whois \
            openssh-client \
            nikto \
            iptables \
            tcpdump \
            wget \
            git \
            build-essential \
            libssl-dev \
            libffi-dev \
            python3-dev
    elif command -v yum &> /dev/null; then
        echo -e "${GREEN}Using YUM package manager${NC}"
        yum install -y \
            python3 \
            python3-pip \
            nmap \
            curl \
            nc \
            iputils \
            traceroute \
            bind-utils \
            whois \
            openssh-clients \
            iptables \
            tcpdump \
            wget \
            git \
            gcc \
            openssl-devel \
            libffi-devel \
            python3-devel
    elif command -v dnf &> /dev/null; then
        echo -e "${GREEN}Using DNF package manager${NC}"
        dnf install -y \
            python3 \
            python3-pip \
            nmap \
            curl \
            nc \
            iputils \
            traceroute \
            bind-utils \
            whois \
            openssh-clients \
            iptables \
            tcpdump \
            wget \
            git \
            gcc \
            openssl-devel \
            libffi-devel \
            python3-devel
    elif command -v pacman &> /dev/null; then
        echo -e "${GREEN}Using PACMAN package manager${NC}"
        pacman -Sy --noconfirm \
            python \
            python-pip \
            nmap \
            curl \
            netcat \
            iputils \
            traceroute \
            bind-tools \
            whois \
            openssh \
            iptables \
            tcpdump \
            wget \
            git \
            gcc \
            openssl \
            libffi \
            python-virtualenv
    elif command -v apk &> /dev/null; then
        echo -e "${GREEN}Using APK package manager${NC}"
        apk add --no-cache \
            python3 \
            py3-pip \
            nmap \
            curl \
            netcat-openbsd \
            iputils \
            traceroute \
            bind-tools \
            whois \
            openssh-client \
            iptables \
            tcpdump \
            wget \
            git \
            gcc \
            musl-dev \
            openssl-dev \
            libffi-dev \
            python3-dev
    else
        echo -e "${RED}❌ Unsupported package manager${NC}"
        echo -e "${YELLOW}Please install dependencies manually${NC}"
    fi

elif [ "$OS_TYPE" = "macOS" ]; then
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo -e "${GREEN}Using Homebrew${NC}"
    brew update
    brew install \
        python3 \
        nmap \
        curl \
        netcat \
        traceroute \
        bind \
        whois \
        openssh \
        nikto \
        wget \
        git
fi

echo -e "${GREEN}✅ System dependencies installed${NC}"

# Install Python dependencies
echo -e "\n${BLUE}📦 Installing Python dependencies...${NC}"

# Create virtual environment
if [ ! -d "venv" ]; then
    echo -e "${GREEN}Creating Python virtual environment...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install requirements
if [ -f "requirements.txt" ]; then
    echo -e "${GREEN}Installing from requirements.txt...${NC}"
    pip install -r requirements.txt
else
    echo -e "${YELLOW}requirements.txt not found${NC}"
fi

# Install additional Python packages
pip install \
    requests \
    psutil \
    colorama \
    python-dotenv \
    paramiko \
    scapy \
    whois \
    cryptography \
    discord.py \
    slack-sdk \
    telethon \
    flask \
    flask-socketio \
    flask-cors \
    numpy \
    matplotlib \
    seaborn \
    reportlab \
    qrcode \
    pyshorteners \
    tabulate \
    tqdm

# Create necessary directories
echo -e "\n${BLUE}📁 Creating directories...${NC}"
mkdir -p .radical_sea_bunny
mkdir -p radical_sea_bunny_reports
mkdir -p .radical_sea_bunny/payloads
mkdir -p .radical_sea_bunny/workspaces
mkdir -p .radical_sea_bunny/scans
mkdir -p .radical_sea_bunny/phishing_pages
mkdir -p .radical_sea_bunny/phishing_templates
mkdir -p .radical_sea_bunny/captured_credentials
mkdir -p .radical_sea_bunny/ssh_keys
mkdir -p .radical_sea_bunny/traffic_logs
mkdir -p .radical_sea_bunny/nikto_results
mkdir -p .radical_sea_bunny/web_templates
mkdir -p .radical_sea_bunny/sessions
mkdir -p radical_sea_bunny_reports/graphics
mkdir -p temp

# Create default config if not exists
if [ ! -f ".radical_sea_bunny/config.json" ]; then
    echo -e "${GREEN}Creating default configuration...${NC}"
    cat > .radical_sea_bunny/config.json << EOF
{
    "version": "2.0.0",
    "auto_start": false,
    "auto_block_enabled": false,
    "auto_block_threshold": 5,
    "scan_timeout": 30,
    "report_format": "html",
    "generate_graphics": true,
    "web": {
        "enabled": true,
        "port": 5000,
        "host": "0.0.0.0",
        "secret_key": "",
        "require_auth": false,
        "username": "admin",
        "password_hash": ""
    },
    "monitoring": {
        "enabled": true,
        "port_scan_threshold": 10,
        "syn_flood_threshold": 100,
        "http_flood_threshold": 200
    },
    "social_engineering": {
        "enabled": true,
        "default_port": 8080,
        "capture_credentials": true,
        "auto_shorten_urls": true
    },
    "ssh": {
        "enabled": true,
        "default_timeout": 30,
        "max_connections": 5
    }
}
EOF
fi

# Create alias script
cat > radical_sea_bunny_alias.sh << 'EOF'
#!/bin/bash
alias radical-sea-bunny='cd "$(dirname "$0")" && source venv/bin/activate && python3 radical_sea_bunny.py'
EOF
chmod +x radical_sea_bunny_alias.sh

# Create launcher script
cat > launch.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python3 radical_sea_bunny.py "$@"
EOF
chmod +x launch.sh

echo -e "\n${GREEN}✅ RADICAL SEA BUNNY installation complete!${NC}"
echo ""
echo -e "${CYAN}🐇 To start RADICAL SEA BUNNY:${NC}"
echo -e "   ${BLUE}./launch.sh${NC}"
echo ""
echo -e "${CYAN}📱 Or use the alias:${NC}"
echo -e "   ${BLUE}source radical_sea_bunny_alias.sh${NC}"
echo -e "   ${BLUE}radical-sea-bunny${NC}"
echo ""
echo -e "${CYAN}🐳 Docker installation:${NC}"
echo -e "   ${BLUE}docker build -t radical_sea_bunny .${NC}"
echo -e "   ${BLUE}docker run -it --network host radical_sea_bunny${NC}"
echo ""
echo -e "${CYAN}📚 Documentation:${NC}"
echo -e "   ${BLUE}cat README.md${NC}"
echo ""
echo -e "${YELLOW}⚠️  For full functionality, run with sudo:${NC}"
echo -e "   ${BLUE}sudo ./launch.sh${NC}"