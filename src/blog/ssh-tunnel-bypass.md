# Bypassing Network Restrictions with SSH Tunneling

## Introduction

I recently ran into a frustrating problem: my university network blocks certain websites and services. While I understand the reasoning, sometimes I legitimately need access to resources that fall under their overly broad filters, such as github, netflix, spotify and so much more.

I tried using a VPN service but it's also blocked, so I decided to build my own solution using a free-tier AWS EC2 instance and SSH. What I ended up with is a lightweight, secure SOCKS5 proxy that tunnels my traffic through an external server.

## The Problem: Network Restrictions

University networks, corporate environments, and even some public WiFi networks impose restrictions on internet access. Common blocks include:

- **Port 22 (SSH)** - blocked entirely.
- **Gaming ports** - 27015-27030 (Steam), 80/443 (web) filtered for gaming services
- **VPN protocols** - OpenVPN (1194), WireGuard (51820), IKEv2 (500/4500)
- **Specific domains** - Social media, streaming, certain cloud services
- **DNS filtering** - Redirecting or blocking DNS queries for restricted sites

My network blocks most VPN protocols and many popular proxy services. But SSH over port 443? That stays open because it looks like regular HTTPS traffic.

## The Solution: SSH Dynamic Port Forwarding

SSH has a powerful feature called **dynamic port forwarding** that creates a SOCKS5 proxy on your local machine. All traffic sent through this proxy is forwarded through the SSH connection to the remote server.

```
Your Machine ---[SSH Tunnel]---> EC2 Server ---> Internet
     |                              |
  Local SOCKS5                   Acts as your
  proxy (port 1080)              exit node
```

The beauty is that it's:
- **Encrypted** - SSH provides strong encryption
- **Stealthy** - Looks like regular SSH traffic (especially on port 443)
- **No special client needed** - Most apps support SOCKS5 proxies
- **Cost-effective** - AWS free tier covers everything

## Step-by-Step Setup

### 1. Launch an EC2 Instance (Free Tier)

AWS Free Tier gives you 750 hours per month of t3.micro or t2.micro instances. Here's what I used:

```bash
# AWS Console settings:
- AMI: Ubuntu 24.04 LTS
- Instance type: t3.micro (2 vCPU, 1 GB RAM)
- Security group: Allow inbound SSH (port 22)
- Key pair: Download and save your .pem file
```

### 2. Configure Security Group

In the EC2 console, edit your security group to allow:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| SSH | TCP | 22 | 0.0.0.0/0 |

For better security, restrict the source to your university's IP range if you know it.

### 3. Connect and Verify

```bash
# Make sure your key file has correct permissions
chmod 400 your-key.pem

# Connect to your instance
# Note: If you used ubuntu in the ec2 the user is usualy "ubuntu"
ssh -i your-key.pem <user>@<public-ip>

```

### 4. Create the Tunnel

Now comes the magic. On your **local machine**, create the SSH tunnel:

```bash
# Standard tunnel on port 1080
ssh -D 1080 -N -f -p 443 -i "your-key.pem" <user>@<public-ip>

```

Let's break down those flags:

| Flag | Meaning |
|------|---------|
| `-D 1080` | Dynamic port forwarding (SOCKS5) on local port 1080 |
| `-f` | Fork to background after authentication |
| `-C` | Enable compression (faster browsing) |
| `-q` | Quiet mode (suppress warnings) |
| `-N` | No remote command execution (just forwarding) |

### 5. Using Port 443 to Bypass Firewalls

If your network blocks port 22, configure your EC2 to accept SSH on port 443:

```bash
# On EC2, edit SSH config
sudo vim /etc/ssh/sshd_config

# Add this line
Port 443

# Restart SSH
sudo systemctl restart sshd

```

Now connect using port 443:

```bash
ssh -D 1080 -N -f -p 443 -i "your-key.pem" <user>@<public-ip>

```

From the outside, this looks exactly like HTTPS traffic.

## Configuring Applications to Use the Tunnel

### Browser: FoxyProxy

**FoxyProxy** is the cleanest way to handle browser proxy settings. Here's how I set it up:

1. Install FoxyProxy extension (Firefox or Chrome)
2. Click the FoxyProxy icon → Options → Add New Proxy
3. Configure:

| Setting | Value |
|---------|-------|
| Title | SSH Tunnel |
| Proxy Type | SOCKS5 |
| IP Address | 127.0.0.1 |
| Port | 1080 |

4. Under **URL Patterns**, you can:
   - Use **"Use this proxy for all URLs"** for everything
   - Or add patterns for specific sites:
     ```
     *.twitter.com
     *.youtube.com
     *.github.com
     ```
5. Enable FoxyProxy and select your SSH Tunnel profile

The beauty of FoxyProxy is that you can toggle the proxy on/off with one click. No digging through browser settings every time.

### Terminal: ProxyChains

For command-line tools, **proxychains** is the answer. It forces any application through your SOCKS5 proxy.

**Installation:**
```bash
# I use arch btw! 
sudo pacman -S proxychains-ng

# On macOS
brew install proxychains-ng

# On debian based distros (ubuntu, kali)
sudo apt install proxychains4

```

**Configuration:** Edit `/etc/proxychains4.conf` (or `~/.proxychains/proxychains.conf`):

```bash
# Uncomment strict_chain (recommended)
strict_chain

# Comment out dynamic_chain if it's uncommented
#dynamic_chain

# At the bottom, configure your proxy
[ProxyList]
socks5 127.0.0.1 1080
```

**Usage:**
```bash
# Run any command through the tunnel
proxychains curl ifconfig.me
proxychains ssh user@some-server
proxychains git clone https://github.com/some/repo.git

# For pacman (package installation)
sudo proxychains pacman -Syu
sudo proxychains4 pacman -S package-name
```

**Pro tip:** Create an alias in your `~/.bashrc`:
```bash
alias pc='proxychains'
alias pc-ssh='proxychains ssh'
```

Then just use `pc curl ifconfig.me` or `pc-ssh user@host`.

### Phone: HTTP Injector (Android)

This is where things get really cool. I can route my **entire phone's traffic** through the same SSH tunnel using **HTTP Injector**. It's like having a VPN powered by my own EC2 server.

**Setup on Android:**

1. Install **HTTP Injector** from the Play Store
2. Go to `Settings`, under `Tunnel` click `Secure Shell (SSH)`:

| Setting | Value |
|---------|-------|
| SSH Host | your-ec2-public-dns or ec2 public ip |
| SSH Port | 22 (or 443 if you changed it) |
| Username | <user> |
| Auth Method | Private Key |
| Private Key | Your .pem file content (paste it) |

3. Under `Connection`:

| Setting | Value |
|---------|-------|
|  Local Port | 1080 |

4. Enable **"Start SSH Tunnel"** and hit **Start**

That's it. Once connected, HTTP Injector creates a VPN interface on your phone that routes all traffic through your EC2 server. The phone sees it as a regular VPN, but underneath it's your SSH tunnel.

**What works over this setup:**
- **Browsers** - Chrome, Firefox, any mobile browser
- **Apps** - Instagram, Twitter, YouTube, Spotify - basically any app that respects the system VPN
- **Terminal** - git, pacman and any terminal command that uses network

### Testing Both Setups

**Test the tunnel is working:**

```bash
# On laptop
proxychains4 curl -s ifconfig.me

# Should show EC2 IP
```

**On phone:**
- Open Chrome, search "what is my ip"
- Should show your EC2 instance's IP, not your mobile carrier's IP

## My Multi-Device Workflow

Here's how I use this setup across all my devices:

### Laptop
1. **Start the tunnel:**
   ```bash
   autossh -M 0 -o "ServerAliveInterval 30" -D 1080 -f -N aws-tunnel
   ```
2. **Enable FoxyProxy** in browser (one click)
3. **For terminal work:**
   ```bash
   proxychains4 git clone https://github.com/blocked/repo.git
   sudo proxychains4 apt install package-name
   ```

### Phone
1. **Open HTTP Injector**
2. **Tap Start** (takes 5 seconds)
3. **Use any app** - everything routes through the tunnel automatically

### Tablet (if I had one)
Same setup as phone - HTTP Injector works great on Android tablets too.

## Keep the Tunnel Alive

SSH connections can drop. Here's how I handle it:

**Option A: SSH Keepalive (in `~/.ssh/config`)**
```
Host aws-tunnel
    HostName your-ec2-public-dns
    User ubuntu
    IdentityFile ~/.ssh/your-key.pem
    DynamicForward 1080
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

Then simply: `ssh aws-tunnel`

**Option B: autossh (more robust)**
```bash
# Install autossh
sudo apt install autossh

# Run with monitoring
autossh -M 0 -o "ServerAliveInterval 30" \
        -o "ServerAliveCountMax 3" \
        -D 1080 -f -N aws-tunnel
```

**Option C: HTTP Injector handles reconnections automatically**

## Cost Management

The AWS Free Tier is generous, but don't let your instance run when you don't need it:

```bash
# Stop the instance from CLI (if you have AWS CLI configured)
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Or just log into AWS Console and stop it
```

I created a simple script `toggle-tunnel.sh`:

```bash
#!/bin/bash
INSTANCE_ID="i-1234567890abcdef0"

case "$1" in
  start)
    aws ec2 start-instances --instance-ids $INSTANCE_ID
    echo "Starting instance... wait 2 minutes then connect"
    ;;
  stop)
    aws ec2 stop-instances --instance-ids $INSTANCE_ID
    echo "Instance stopping"
    ;;
  status)
    aws ec2 describe-instances --instance-ids $INSTANCE_ID \
      --query 'Reservations[0].Instances[0].State.Name'
    ;;
esac
```

## Security Considerations

**What this DOES NOT protect against:**
- Network administrators seeing that you're using SSH (though they can't see the content)
- Tracking via browser fingerprints, cookies, or logged-in accounts
- Malware or compromised endpoints

**What it DOES provide:**
- Encryption between your devices and EC2
- Bypass of content filters
- Your EC2 IP becomes your public-facing IP

**Best practices:**
- Keep your EC2 instance updated (`sudo apt update && sudo apt upgrade`)
- Use key-based authentication (no passwords)
- Consider using a non-standard SSH port (like 443)
- Monitor your AWS billing to catch unexpected charges
- **Never share your private key** - keep it safe

## Troubleshooting

**Connection refused:**
- Check security group rules
- Verify SSH is running on the port you specified
- Confirm your local network isn't blocking the port

**Slow browsing:**
- Use `-C` flag for compression
- Choose an EC2 region geographically close to you
- t3.micro has burstable CPU, which is usually fine for browsing

**DNS leaks:**
- In FoxyProxy, enable "Proxy DNS" in the proxy settings
- For Chrome: use `--proxy-server="socks5://127.0.0.1:1080" --host-resolver-rules="MAP * ~NOTFOUND"`

**Proxychains not working:**
- Make sure the tunnel is running (`ps aux | grep ssh`)
- Verify proxychains config has correct proxy details
- Try `proxychains4 curl -v ifconfig.me` to see verbose output

**HTTP Injector not connecting:**
- Verify your EC2 instance is running
- Check that the private key is pasted correctly (including the `-----BEGIN RSA PRIVATE KEY-----` lines)
- Try connecting over mobile data vs WiFi to isolate network issues
- Ensure your EC2 security group allows inbound SSH from all IPs (or at least your phone's IP)

## Why This Setup Works Well

This combination has become my go-to solution across all devices:

| Device | Tool | Why It Works |
|--------|------|--------------|
| **Laptop** | FoxyProxy + Proxychains | Toggle easily, per-app control |
| **Phone** | HTTP Injector | System-wide VPN-like experience |
| **Server** | AWS t3.micro (Ubuntu 24.04) | Free tier, stable, well-documented |

The best part? I learned actual skills. I now understand:
- SSH tunneling internals
- AWS EC2 management
- SOCKS5 proxy mechanics
- How to debug network issues
- Cross-device networking

## Alternatives

While SSH tunneling is a great starting point, you can take things further with more sophisticated protocols like **VLESS + REALITY** or **VMess + WebSocket + CDN**. These modern solutions offer better traffic obfuscation, making your connection virtually indistinguishable from regular HTTPS traffic. They also solve the IP-blocking problem by hiding your server behind Cloudflare's massive network—if your EC2 IP gets blocked, the CDN shields it completely.

### Why Go Beyond SSH?

| Limitation of SSH Tunnel | How Modern Protocols Help |
|--------------------------|---------------------------|
| SSH traffic can be identified and throttled | Mimics regular HTTPS traffic using TLS |
| Your EC2 IP is exposed and can be blocked | Hide behind Cloudflare CDN (hundreds of IPs) |
| No built-in traffic camouflage | VLESS + REALITY removes TLS fingerprints |
| Single port, predictable pattern | WebSocket multiplexing over port 443 |

### Resources to Explore

- [SSH Port Forwarding: Local, Remote, and Dynamic Explained](https://www.digitalocean.com/community/tutorials/ssh-port-forwarding)

- [AWS Free Tier EC2 Instance Setup](https://aws.amazon.com/getting-started/hands-on/free-tier-ec2-instance-setup/)
- [Amazon EC2 Getting Started](https://aws.amazon.com/ec2/getting-started/)

- [X-UI Setup Guide (Video Tutorial)](https://youtu.be/4TYffXhDYTo)
- [X-UI Installation Script Repository](https://github.com/maou0/xui-install-configure-script) 

**Hiding Your Server with Cloudflare (The Game Changer)**
- [V2Ray WS + CDN Setup: Hiding Your Server IP with Cloudflare](https://vpnymous.com/v2ray-ws-cdn-setup-hiding-your-server-ip-with-cloudflare-practical-guide/) — Practical guide to making your server invisible behind Cloudflare's network 
- [VLESS Reality Protocol Guide](https://github.com/xiaochaib/chaiwiki/wiki/%E4%B8%80%E9%94%AE%E6%90%AD%E5%BB%BAV2Ray%EF%BC%88XRay%EF%BC%89--Vision-REALITY%E5%8D%8F%E8%AE%AE%E7%A7%91%E5%AD%A6%E4%B8%8A%E7%BD%91%E8%8A%82%E7%82%B9%EF%BC%81)

## Conclusion

This whole project started because my university network blocked everything—VPNs, gaming, even some development resources. I could've just complained about it, but instead, I built something.

And honestly? That's what I love about this field. Every restriction is just an invitation to learn something new. Setting up this SSH tunnel taught me more about networking than any textbook could. I learned how SSH actually works under the hood—not just as a login tool but as a full-fledged tunneling protocol. I learned how to spin up an EC2 instance without touching the AWS console. I figured out how to make my phone route through the same tunnel with HTTP Injector, which felt like magic the first time it worked.

But the best part? This setup is *mine*. Not some VPN service with questionable privacy policies. Not a free proxy that probably logs everything. Just my server, my key, my rules.

If you're reading this and thinking about setting it up yourself, here's my advice: **just start**. Don't wait until you understand everything. Launch that EC2 instance, run the SSH command, and when it fails (because it will the first time), read the error message and figure it out. That's how you actually learn.

And when you get it working—when you see your browser show your EC2 IP instead of your university's—you'll feel like you just hacked the matrix. (Spoiler: you didn't, but it feels that way.)

Now go build something. Break it. Fix it. Learn from it. That's what this whole experience is about.

---

**Questions? Found a better way to do this?** Hit me up on [GitHub](https://github.com/0-x-joseph) or [LinkedIn](https://www.linkedin.com/in/youssef-bouryal). I'm always curious to see how others solve these problems.
