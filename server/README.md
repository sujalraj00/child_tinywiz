this# Parent-Child Server

Socket.io server for parent-child app communication and phone locking functionality.

## Features

- ✅ Parent device registration
- ✅ Child device registration
- ✅ Remote phone lock/unlock
- ✅ Real-time status updates
- ✅ Emergency alerts
- ✅ Unlock requests from child
- ✅ Connection status monitoring

## Installation

```bash
cd server
npm install
```

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on port 3200 (or PORT from environment variables).

## API Endpoints

### Health Check
```
GET /api/health
```
Returns server status and connected devices count.

### Connected Devices
```
GET /api/connected-devices
```
Returns list of all connected devices (parents and children).

## Socket Events

### Parent Events

#### Register Parent
```javascript
socket.emit('register_parent', {
  parentId: 'parent123',
  childId: 'child456'
});
```

#### Lock Child Phone
```javascript
socket.emit('lock_child_phone', {
  parentId: 'parent123',
  childId: 'child456',
  lock: true  // true to lock, false to unlock
});
```

#### Listen for Lock Acknowledgment
```javascript
socket.on('lock_acknowledged', (data) => {
  console.log('Child acknowledged lock:', data);
});
```

#### Listen for Child Status
```javascript
socket.on('child_status', (data) => {
  console.log('Child status:', data);
});
```

#### Listen for Emergency Alerts
```javascript
socket.on('child_emergency', (data) => {
  console.log('Emergency from child:', data);
});
```

#### Listen for Unlock Requests
```javascript
socket.on('unlock_request_received', (data) => {
  console.log('Child requesting unlock:', data);
});
```

### Child Events

#### Register Child
```javascript
socket.emit('register_child', {
  childId: 'child456',
  deviceInfo: {
    platform: 'flutter',
    timestamp: new Date().toISOString()
  }
});
```

#### Send Status Update
```javascript
socket.emit('child_status_update', {
  childId: 'child456',
  status: 'active',
  battery: 100,
  lastActive: new Date().toISOString(),
  appState: 'foreground',
  timestamp: new Date().toISOString()
});
```

#### Send Lock Acknowledgment
```javascript
socket.emit('lock_acknowledgment', {
  childId: 'child456',
  locked: true,
  commandTimestamp: '2024-01-01T00:00:00.000Z',
  acknowledgedAt: new Date().toISOString()
});
```

#### Request Unlock
```javascript
socket.emit('unlock_request', {
  childId: 'child456',
  reason: 'Need to call someone',
  requestedAt: new Date().toISOString()
});
```

#### Send Emergency Alert
```javascript
socket.emit('child_emergency_alert', {
  childId: 'child456',
  reason: 'Emergency help needed',
  location: 'Unknown',
  timestamp: new Date().toISOString()
});
```

## Environment Variables

Create a `.env` file in the server directory:

```env
PORT=3200
CORS_ORIGIN=*
```

## Network Configuration

The server automatically detects your local IP address and displays it on startup. Use this IP address in your Flutter apps to connect to the server.

Example output:
```
🚀 Server running on port 3200
📍 Local: http://localhost:3200
📍 Network: http://192.168.1.13:3200
🌐 WebSocket: ws://192.168.1.13:3200
```

## Testing

You can test the server using the health check endpoint:

```bash
curl http://localhost:3200/api/health
```

## Troubleshooting

1. **Connection Issues**: Make sure both parent and child apps are using the correct server URL (check the network IP from server startup).

2. **Lock Not Working**: Ensure:
   - Child is registered before parent sends lock command
   - Both devices are connected to the same network
   - Server is running and accessible

3. **Port Already in Use**: Change the PORT in `.env` file or kill the process using port 3200.

