#!/bin/bash
# CatScript System Diagnostics
# by Arseniy Y.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

color_echo() {
    case "$2" in
        red)    echo -e "${RED}$1${NC}" ;;
        green)  echo -e "${GREEN}$1${NC}" ;;
        yellow) echo -e "${YELLOW}$1${NC}" ;;
        blue)   echo -e "${BLUE}$1${NC}" ;;
        *)      echo "$1" ;;
    esac
}

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]:-$0}" 2>/dev/null || echo "${BASH_SOURCE[0]:-$0}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

if [[ "${EUID:-$(id -u)}" -eq 0 ]] || [[ -n "${SUDO_USER-}" ]]; then
    color_echo "ERROR: Run as regular user (without sudo)" red
    exit 1
fi

perm_oct=$(stat -c '%a' "$SCRIPT_PATH" 2>/dev/null)
if [[ -n "$perm_oct" ]] && { [[ $(((perm_oct/10)%10 & 1)) -eq 1 ]] || [[ $((perm_oct%10 & 1)) -eq 1 ]]; }; then
    chmod go-x "$SCRIPT_PATH" 2>/dev/null || { color_echo "Fix permissions manually: chmod go-x '$SCRIPT_PATH'" red; exit 1; }
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUTPUT_FILE="${SCRIPT_DIR}/CatScript_${TIMESTAMP}.html"

cat <<'EOF'

  /$$$$$$              /$$      /$$$$$$                      /$$             /$$    
 /$$__  $$            | $$     /$$__  $$                    |__/            | $$    
| $$  \__/  /$$$$$$  /$$$$$$  | $$  \__/  /$$$$$$$  /$$$$$$  /$$  /$$$$$$  /$$$$$$  
| $$       |____  $$|_  $$_/  |  $$$$$$  /$$_____/ /$$__  $$| $$ /$$__  $$|_  $$_/  
| $$        /$$$$$$$  | $$     \____  $$| $$      | $$  \__/| $$| $$  \ $$  | $$    
| $$    $$ /$$__  $$  | $$ /$$ /$$  \ $$| $$      | $$      | $$| $$  | $$  | $$ /$$
|  $$$$$$/|  $$$$$$$  |  $$$$/|  $$$$$$/|  $$$$$$$| $$      | $$| $$$$$$$/  |  $$$$/
 \______/  \_______/   \___/   \______/  \_______/|__/      |__/| $$____/    \___/  
                                                                | $$                
                                                                | $$                
                                                                |__/                
by Arseniy Y.

EOF

cat > "$OUTPUT_FILE" <<'HTML_HEAD'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CatScript System Diagnostics</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: #e6e6e6;
            line-height: 1.6;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            text-align: center;
            padding: 40px 20px;
            background: rgba(0, 0, 0, 0.6);
            border-radius: 15px;
            margin-bottom: 30px;
            border: 2px solid #4cc9f0;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }
        
        .header h1 {
            font-size: 48px;
            background: linear-gradient(45deg, #4cc9f0, #4361ee, #3a0ca3, #7209b7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            font-weight: 800;
            letter-spacing: 2px;
            text-shadow: 0 0 20px rgba(76, 201, 240, 0.5);
        }
        
        .header p {
            font-size: 18px;
            color: #a0a0a0;
            margin-top: 10px;
        }
        
        .timestamp {
            background: rgba(76, 201, 240, 0.2);
            padding: 8px 20px;
            border-radius: 20px;
            display: inline-block;
            margin-top: 15px;
            font-size: 14px;
            color: #4cc9f0;
        }
        
        .section {
            background: rgba(30, 30, 50, 0.8);
            border-radius: 12px;
            margin-bottom: 20px;
            overflow: hidden;
            border: 1px solid #3a0ca3;
            transition: all 0.3s ease;
        }
        
        .section:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.4);
            border-color: #4cc9f0;
        }
        
        .section-header {
            background: linear-gradient(90deg, #1a1a2e 0%, #2a2a4a 100%);
            padding: 15px 25px;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 600;
            font-size: 18px;
            color: #4cc9f0;
            user-select: none;
        }
        
        .section-header:hover {
            background: linear-gradient(90deg, #1a1a2e 0%, #3a3a6a 100%);
        }
        
        .section-content {
            padding: 20px 25px;
            display: none;
            background: rgba(25, 25, 45, 0.7);
            max-height: 600px;
            overflow-y: auto;
        }
        
        .section-content.active {
            display: block;
        }
        
        .section-content pre {
            background: rgba(0, 0, 0, 0.4);
            border-radius: 8px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            line-height: 1.5;
            color: #e0e0e0;
            white-space: pre-wrap;
            word-wrap: break-word;
            max-height: 500px;
            overflow-y: auto;
            border: 1px solid #3a0ca3;
        }
        
        .section-content pre::-webkit-scrollbar {
            width: 8px;
        }
        
        .section-content pre::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.2);
        }
        
        .section-content pre::-webkit-scrollbar-thumb {
            background: #4cc9f0;
            border-radius: 4px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        
        .stat-card {
            background: rgba(50, 50, 80, 0.6);
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid #4cc9f0;
        }
        
        .stat-card h4 {
            color: #4361ee;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .stat-card p {
            color: #e6e6e6;
            font-size: 16px;
            font-weight: 500;
        }
        
        .footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 14px;
            margin-top: 30px;
            border-top: 1px solid rgba(76, 201, 240, 0.3);
        }
        
        @media (max-width: 768px) {
            .header h1 {
                font-size: 32px;
            }
            
            .section-header {
                font-size: 16px;
                padding: 12px 15px;
            }
            
            .section-content {
                padding: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>CatScript</h1>
            <p>System Diagnostics Report</p>
            <p style="font-size: 16px; margin-top: 5px;">by Arseniy Y.</p>
            <div class="timestamp" id="timestamp"></div>
        </div>
HTML_HEAD

# Функция для добавления секции в HTML
add_section() {
    local title="$1"
    local content="$2"
    local id="${title//[^a-zA-Z0-9]/_}"
    
    cat >> "$OUTPUT_FILE" <<EOF
        <div class="section">
            <div class="section-header" onclick="toggleSection(this)">
                $title
                <span class="toggle-icon">▼</span>
            </div>
            <div class="section-content">
                <pre>$content</pre>
            </div>
        </div>
EOF
}

# Сбор данных
OS_INFO=$(cat /etc/os-release 2>/dev/null || echo "OS information not available")
KERNEL=$(uname -r 2>/dev/null || echo "N/A")
HOSTNAME=$(hostname 2>/dev/null || echo "N/A")
UPTIME=$(uptime 2>/dev/null || echo "N/A")
DATE=$(date 2>/dev/null || echo "N/A")

LSPCI=$(lspci 2>/dev/null || echo "lspci not available")
LSCPU=$(lscpu 2>/dev/null || echo "lscpu not available")
FREE=$(free -h 2>/dev/null || echo "free not available")
DF=$(df -h 2>/dev/null || echo "df not available")
LSBLK=$(lsblk -o NAME,MAJ:MIN,RM,SIZE,RO,TYPE,MOUNTPOINT 2>/dev/null || echo "lsblk not available")

IP_ADDR=$(ip addr show 2>/dev/null || echo "ip command not available")
IP_ROUTE=$(ip route show 2>/dev/null || echo "ip command not available")
RESOLV=$(cat /etc/resolv.conf 2>/dev/null || echo "resolv.conf not available")

if command -v dpkg &>/dev/null; then
    PACKAGES=$(dpkg -l 2>/dev/null | head -100 || echo "Package list not available")
elif command -v rpm &>/dev/null; then
    PACKAGES=$(rpm -qa 2>/dev/null | head -100 || echo "Package list not available")
else
    PACKAGES="Package manager not detected"
fi

PROCESSES=$(ps aux --sort=-%cpu 2>/dev/null | head -50 || echo "Process list not available")
SYSTEMD=$(systemctl list-units --type=service --state=running 2>/dev/null | head -50 || echo "Systemd services not available")

USERS=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd 2>/dev/null || echo "User list not available")
GROUPS=$(cat /etc/group 2>/dev/null | head -50 || echo "Group list not available")

ENV=$(env 2>/dev/null || echo "Environment variables not available")
LIMITS=$(ulimit -a 2>/dev/null || echo "Limits not available")

if command -v nvidia-smi &>/dev/null; then
    NVIDIA=$(nvidia-smi 2>/dev/null || echo "NVIDIA info not available")
else
    NVIDIA="NVIDIA drivers not detected"
fi

if [[ -f /var/log/syslog ]]; then
    SYSLOG=$(tail -200 /var/log/syslog 2>/dev/null || echo "Syslog not available")
elif [[ -f /var/log/messages ]]; then
    SYSLOG=$(tail -200 /var/log/messages 2>/dev/null || echo "System messages not available")
else
    SYSLOG="System logs not found"
fi

DMESG=$(dmesg | tail -100 2>/dev/null || echo "dmesg not available")

# Добавление секций
add_section "System Information" "Hostname: $HOSTNAME
Kernel: $KERNEL
Date: $DATE
Uptime: $UPTIME"

add_section "OS Details" "$OS_INFO"

add_section "Hardware (lspci)" "$LSPCI"

add_section "CPU Information" "$LSCPU"

add_section "Memory Usage" "$FREE"

add_section "Disk Usage" "$DF"

add_section "Block Devices" "$LSBLK"

add_section "Network Configuration" "$IP_ADDR"

add_section "Routing Table" "$IP_ROUTE"

add_section "DNS Configuration" "$RESOLV"

add_section "Installed Packages" "$PACKAGES"

add_section "Running Processes" "$PROCESSES"

add_section "System Services" "$SYSTEMD"

add_section "System Users" "$USERS"

add_section "System Groups" "$GROUPS"

add_section "Environment Variables" "$ENV"

add_section "System Limits" "$LIMITS"

add_section "NVIDIA Information" "$NVIDIA"

add_section "System Logs" "$SYSLOG"

add_section "Kernel Messages (dmesg)" "$DMESG"

# Закрытие HTML
cat >> "$OUTPUT_FILE" <<'HTML_FOOTER'
    </div>
    
    <div class="footer">
        <p>Generated by CatScript System Diagnostics Toolkit • by Arseniy Y. • $(date)</p>
    </div>

    <script>
        function toggleSection(header) {
            const content = header.nextElementSibling;
            const icon = header.querySelector('.toggle-icon');
            
            if (content.classList.contains('active')) {
                content.classList.remove('active');
                icon.textContent = '▼';
            } else {
                content.classList.add('active');
                icon.textContent = '▲';
            }
        }
        
        // Автоматически раскрыть первую секцию
        document.addEventListener('DOMContentLoaded', function() {
            const firstHeader = document.querySelector('.section-header');
            if (firstHeader) {
                toggleSection(firstHeader);
            }
            
            // Установить timestamp
            const timestampEl = document.getElementById('timestamp');
            const now = new Date();
            timestampEl.textContent = 'Generated: ' + now.toLocaleString('ru-RU', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit'
            });
        });
    </script>
</body>
</html>
HTML_FOOTER

color_echo "✓ Diagnostic report created:" green
color_echo "  CatScript_${TIMESTAMP}.html" blue
color_echo "  ${SCRIPT_DIR}/" white
echo ""

color_echo "Open the file in your browser to view the report." yellow
echo ""

# Попытка автоматического открытия (опционально)
if command -v xdg-open &>/dev/null; then
    read -r -p "Open the report in browser now? [Y/n]: " open_choice
    if [[ -z "$open_choice" ]] || [[ "$open_choice" =~ ^[Yy]$ ]]; then
        xdg-open "$OUTPUT_FILE" &>/dev/null &
        color_echo "Opening report in browser..." green
    fi
fi
