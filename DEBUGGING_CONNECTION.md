# Debugging Child App Connection

## Issue
Child app is not registering with the server, so parent cannot send lock commands.

## Debugging Steps

### 1. Check if Child App is Running
- Make sure the child app is actually running on a device/emulator
- Check Flutter logs: `flutter logs` or check your IDE console

### 2. Verify Server URL
Check `lib/core/constants/app_constants.dart`:
```dart
static const String defaultServerUrl = 'http://192.168.1.13:3200';
```
Make sure this matches your server's IP address.

### 3. Check Connection Logs
After the fixes, you should see these logs in the child app:
```
🔄 Child connecting to: http://192.168.1.13:3200
🆔 Child ID: child456
✅ Child socket connected to server
📝 Registering child: child456
📤 Registration event emitted
✅ Server connection confirmed: {...}
✅ Child registration confirmed: {...}
```

### 4. Check Server Logs
When child connects, server should show:
```
User connected: <socket-id>
✅ Child child456 registered
```

### 5. Test Connection Manually
You can test the connection by:
1. Starting the server
2. Running the child app
3. Checking server logs for "Child child456 registered"
4. Checking child app logs for connection messages

### 6. Common Issues

#### Issue: "Cannot connect to server"
- **Solution**: Check firewall settings, ensure both devices on same network
- **Solution**: Verify server URL is correct

#### Issue: "Socket connects but doesn't register"
- **Solution**: Check that `_registerChild()` is being called in `onConnect` callback
- **Solution**: Verify `_childId` is not null

#### Issue: "Registration event sent but server doesn't receive"
- **Solution**: Check server event handler is set up correctly
- **Solution**: Verify event name matches: `register_child`

### 7. Quick Test
Run this in your terminal to check server health:
```bash
curl http://192.168.1.13:3200/api/health
```

Should return:
```json
{
  "status": "OK",
  "timestamp": "...",
  "connectedDevices": 1
}
```

### 8. Verify Both Apps Use Same Child ID
- Child app uses: `AppConstants.defaultChildId` = `'child456'`
- Parent app uses: `'child456'` when calling `lockChildPhone()`

They must match!

## Expected Flow

1. **Child App Starts**
   - Calls `initializeSocket('child456')`
   - Connects to server
   - Registers with `register_child` event

2. **Server Receives Registration**
   - Stores child in `connectedDevices` map
   - Sends `child_registered` confirmation

3. **Parent App Connects**
   - Registers with `register_parent` event
   - Links to child456

4. **Parent Sends Lock Command**
   - Server finds child456 in `connectedDevices`
   - Forwards lock command to child
   - Child receives and locks

## If Still Not Working

1. **Check Network**: Both apps must be on same WiFi network
2. **Check Server**: Server must be running and accessible
3. **Check Logs**: Look for error messages in both apps and server
4. **Restart Everything**: Sometimes a fresh start helps
   - Stop server
   - Stop child app
   - Restart server
   - Restart child app
   - Wait 3-5 seconds for connection
   - Then try lock command from parent





