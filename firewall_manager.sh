#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Function to add a rule with iptables
add_iptables_rule() {
    local ip=$1
    local port=$2
    local proto=$3
    local action=$4
    
    if [[ $action == "allow" ]]; then
        iptables -A INPUT -p $proto --dport $port -s $ip -j ACCEPT
    else
        iptables -A INPUT -p $proto --dport $port -s $ip -j DROP
    fi
}

# Function to remove a rule with iptables
remove_iptables_rule() {
    local ip=$1
    local port=$2
    local proto=$3
    local action=$4
    
    if [[ $action == "allow" ]]; then
        iptables -D INPUT -p $proto --dport $port -s $ip -j ACCEPT
    else
        iptables -D INPUT -p $proto --dport $port -s $ip -j DROP
    fi
}

# Function to add a rule with UFW
add_ufw_rule() {
    local ip=$1
    local port=$2
    local proto=$3
    local action=$4
    
    if [[ $action == "allow" ]]; then
        ufw allow from $ip to any port $port proto $proto
    else
        ufw deny from $ip to any port $port proto $proto
    fi
}

# Function to remove a rule with UFW
remove_ufw_rule() {
    local ip=$1
    local port=$2
    local proto=$3
    local action=$4
    
    if [[ $action == "allow" ]]; then
        ufw delete allow from $ip to any port $port proto $proto
    else
        ufw delete deny from $ip to any port $port proto $proto
    fi
}

# Prompt user to choose between iptables and UFW
echo "Choose firewall management tool:"
echo "1) iptables"
echo "2) UFW"
read -p "Enter choice [1-2]: " tool_choice

# Validate tool choice
if [[ $tool_choice != "1" && $tool_choice != "2" ]]; then
    echo "Invalid choice"
    exit 1
fi

# Prompt for action: add or remove rule
echo "Choose action:"
echo "1) Add rule"
echo "2) Remove rule"
read -p "Enter choice [1-2]: " action_choice

# Validate action choice
if [[ $action_choice != "1" && $action_choice != "2" ]]; then
    echo "Invalid choice"
    exit 1
fi

# Gather details for the rule
read -p "Enter IP address: " ip
read -p "Enter port: " port
read -p "Enter protocol (tcp/udp): " proto
read -p "Enter action (allow/deny): " action

# Validate protocol and action
if [[ $proto != "tcp" && $proto != "udp" ]]; then
    echo "Invalid protocol"
    exit 1
fi

if [[ $action != "allow" && $action != "deny" ]]; then
    echo "Invalid action"
    exit 1
fi

# Execute the appropriate function based on choices
if [[ $tool_choice == "1" ]]; then
    if [[ $action_choice == "1" ]]; then
        add_iptables_rule $ip $port $proto $action
    else
        remove_iptables_rule $ip $port $proto $action
    fi
else
    if [[ $action_choice == "1" ]]; then
        add_ufw_rule $ip $port $proto $action
    else
        remove_ufw_rule $ip $port $proto $action
    fi
fi

echo "Firewall rule successfully updated."
