# Parent-Child App Features

This document describes all the implemented features for the parent-child communication system.

## Overview

The system consists of:
1. **Server** (`server/server.js`) - Socket.io server handling communication
2. **Child App** (this Flutter project) - Child's device app
3. **Parent App** (separate project) - Parent's control app

## Implemented Features

### ✅ 1. Device Registration

#### Child Registration
- Child app automatically registers when connected to server
- Sends `register_child` event with childId
- Server confirms registration with `child_registered` event

#### Parent Registration
- Parent app registers with `register_parent` event
- Links parent to specific child device
- Server confirms with `parent_registered` event

### ✅ 2. Remote Phone Lock/Unlock

#### Lock Functionality
- Parent sends `lock_child_phone` event with `lock: true`
- Server forwards `phone_lock_status` event to child
- Child app displays full-screen lock screen
- Lock screen prevents all interactions (back button disabled)
- Child sends acknowledgment back to parent

#### Unlock Functionality
- Parent sends `lock_child_phone` event with `lock: false`
- Child app unlocks and returns to normal operation
- Child sends acknowledgment to parent

### ✅ 3. Lock Screen Features

The lock screen includes:
- **Visual Lock Indicator**: Large lock icon with red background
- **Connection Status**: Shows if connected to parent
- **Unlock Request Button**: Child can request unlock from parent
- **Prevents Interaction**: Back button and all gestures disabled
- **Real-time Updates**: Updates when lock status changes

### ✅ 4. Status Updates

#### Automatic Status Updates
- Child app sends status every 30 seconds when connected
- Includes: status, battery level, last active time, app state
- Parent receives `child_status` events

#### Manual Status Updates
- Can be triggered on specific events
- Sent when app state changes (foreground/background)

### ✅ 5. Emergency Alerts

- Child can send emergency alerts to parent
- Includes reason and location (if available)
- Parent receives `child_emergency` event
- Useful for urgent situations

### ✅ 6. Unlock Requests

- Child can request unlock from lock screen
- Includes optional reason text
- Parent receives `unlock_request_received` event
- Parent can then choose to unlock remotely

### ✅ 7. Connection Management

#### Auto-Reconnection
- Child app attempts to reconnect if disconnected
- Maintains childId across reconnections

#### Connection Status
- Real-time connection status display
- Visual indicators (green/red) for connection state
- Automatic status updates when connected

## Architecture

### Clean Architecture with MVVM

```
lib/
├── domain/          # Business logic
│   ├── entities/    # Data models
│   ├── repositories/# Repository interfaces
│   └── usecases/    # Business use cases
├── data/            # Data layer
│   ├── datasources/ # Data sources (Socket, Audio, etc.)
│   └── repositories/# Repository implementations
└── presentation/    # UI layer
    ├── viewmodels/  # MVVM ViewModels
    └── views/       # UI screens
```

## Server Events Flow

### Lock Command Flow
```
Parent App → lock_child_phone → Server → phone_lock_status → Child App
                                                              ↓
Child App → lock_acknowledgment → Server → lock_acknowledged → Parent App
```

### Status Update Flow
```
Child App → child_status_update → Server → child_status → Parent App
```

### Unlock Request Flow
```
Child App → unlock_request → Server → unlock_request_received → Parent App
```

## Configuration

### Child App Constants
Located in `lib/core/constants/app_constants.dart`:
- `defaultChildId`: 'child456'
- `defaultServerUrl`: 'http://192.168.1.13:3200'

**Important**: Update `defaultServerUrl` to match your server's IP address.

### Server Configuration
- Default port: 3200
- Auto-detects local IP address
- CORS enabled for all origins

## Testing the System

### 1. Start the Server
```bash
cd server
npm install
npm start
```

### 2. Update Server URL
In `lib/core/constants/app_constants.dart`, update:
```dart
static const String defaultServerUrl = 'http://YOUR_SERVER_IP:3200';
```

### 3. Run Child App
```bash
flutter run
```

### 4. Test Lock Feature
From parent app (or using a socket client):
```javascript
socket.emit('lock_child_phone', {
  parentId: 'parent123',
  childId: 'child456',
  lock: true
});
```

## Security Considerations

1. **PIN Protection**: Parent gatekeeper requires PIN to exit app
2. **Lock Enforcement**: Lock screen prevents all interactions
3. **Connection Validation**: Server validates device registrations
4. **Acknowledgment System**: Ensures commands are received

## Future Enhancements

Potential improvements:
- [ ] Battery level detection
- [ ] Location tracking
- [ ] Screen time monitoring
- [ ] App usage restrictions
- [ ] Scheduled locks
- [ ] Multiple children support per parent
- [ ] Push notifications
- [ ] Encrypted communication

## Troubleshooting

### Child Not Receiving Lock Commands
1. Check server is running
2. Verify child is registered (check server logs)
3. Ensure correct childId is used
4. Check network connectivity

### Lock Screen Not Appearing
1. Check `_isLocked` state in HomeViewModel
2. Verify socket connection is active
3. Check server logs for `phone_lock_status` event

### Connection Issues
1. Verify server URL in app constants
2. Check firewall settings
3. Ensure both devices on same network
4. Check server logs for connection errors

## API Reference

See `server/README.md` for complete Socket.io event documentation.

