# Flutter Web Deployment Guide for WSL

## 🚀 Quick Start

Your Flutter web app has been successfully built and is ready for deployment! The web server is currently running on port 8000.

## 📍 Access Your App

### From WSL (Linux):
```
http://localhost:8000
```

### From Windows (with port forwarding):
```
http://localhost:8000
```

## 🔧 WSL Port Forwarding Setup

To access your Flutter web app from Windows browser, you need to set up port forwarding:

### Step 1: Find your WSL IP address
```bash
# In WSL terminal
hostname -I
```
This will output something like: `172.20.0.2`

### Step 2: Set up port forwarding (run in Windows Command Prompt as Administrator)
```cmd
# Replace [WSL_IP] with your actual WSL IP
netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=[WSL_IP]

# Example:
netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=172.20.0.2
```

### Step 3: Verify port forwarding
```cmd
netsh interface portproxy show all
```

### Step 4: Remove port forwarding when done (optional)
```cmd
netsh interface portproxy delete v4tov4 listenport=8000 listenaddress=0.0.0.0
```

## 📁 Deployment Files

Your Flutter web app files are located in: `/home/lqw/mygit/github-follow-contributions/flutter_web_deploy/`

### Key Files:
- `index.html` - Main entry point
- `main.dart.js` - Compiled Flutter application
- `flutter.js` - Flutter framework
- `flutter_service_worker.js` - Service worker for offline support
- `assets/` - Static assets (fonts, images, data)
- `canvaskit/` - CanvasKit renderer files
- `manifest.json` - PWA manifest

## 🌐 Web Server Commands

### Start Server (already running):
```bash
cd /home/lqw/mygit/github-follow-contributions/flutter_web_deploy
python3 -m http.server 8000
```

### Stop Server:
Press `Ctrl+C` in the terminal where the server is running.

### Start on Different Port:
```bash
python3 -m http.server 8080  # Use port 8080 instead
```

## 🔍 Troubleshooting

### Page Not Loading:
1. **Check if server is running**: Look for "Serving HTTP on 0.0.0.0 port 8000" message
2. **Verify port forwarding**: Run `netsh interface portproxy show all` in Windows CMD
3. **Check firewall**: Ensure port 8000 is allowed in Windows Firewall
4. **Test WSL access**: Try `curl http://localhost:8000` in WSL

### Blank Page:
1. **Check browser console**: Press F12 and look for errors
2. **Verify files**: Ensure all files are in the deployment directory
3. **Check JavaScript**: Make sure JavaScript is enabled in your browser

### Port Already in Use:
```bash
# Find process using port 8000
lsof -i :8000
# Kill the process
kill -9 [PID]
```

## 📱 PWA Features

Your Flutter web app includes:
- ✅ Offline support (service worker)
- ✅ Installable as app
- ✅ Responsive design
- ✅ Mobile-optimized UI

## 🔄 Restarting the Server

If you need to restart the server:
```bash
# Stop current server (Ctrl+C)
# Then run:
cd /home/lqw/mygit/github-follow-contributions/flutter_web_deploy
python3 -m http.server 8000
```

## 🆘 Still Having Issues?

1. **Check the deployment script output** for any errors
2. **Verify Flutter build**: Re-run `./deploy_flutter_web.sh`
3. **Check file permissions**: Ensure files are readable
4. **Test with different browser** to isolate browser-specific issues

## 📞 Support Files

- Deployment script: `/home/lqw/mygit/github-follow-contributions/deploy_flutter_web.sh`
- Build script: `/home/lqw/mygit/github-follow-contributions/build_flutter.sh`
- Migration guide: `/home/lqw/mygit/github-follow-contributions/FLUTTER_MIGRATION_GUIDE.md`