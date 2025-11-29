const express = require('express');
const http = require('http');
const socketio = require('socket.io');
const cors = require('cors');
require('dotenv').config();

const app = express();
const server = http.createServer(app);

// Get local IP address automatically
const getLocalIP = () => {
  const interfaces = require('os').networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const interface of interfaces[name]) {
      if (interface.family === 'IPv4' && !interface.internal) {
        return interface.address;
      }
    }
  }
  return 'localhost';
};

const LOCAL_IP = getLocalIP();

// Enhanced CORS configuration
app.use(cors({
  origin: ["http://localhost:3200", "http://127.0.0.1:3200", "http://" + LOCAL_IP + ":3200", "*"],
  methods: ["GET", "POST"],
  credentials: true
}));

app.use(express.json());

// Socket.io setup
const io = socketio(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  transports: ['websocket', 'polling']
});

io.engine.on("connection", (rawSocket) => {
  const origin = rawSocket.req?.headers?.origin || 'Unknown';
  console.log('Raw connection from:', origin);
});

const connectedDevices = new Map();

// Socket.io connection handler
io.on("connection", (socket) => {
  console.log("=".repeat(50));
  console.log("✅ NEW CONNECTION ESTABLISHED");
  console.log("   Socket ID:", socket.id);
  console.log("   Client origin:", socket.handshake.headers.origin || 'Unknown');
  console.log("   Transport:", socket.conn.transport.name);
  console.log("   Remote address:", socket.handshake.address);
  console.log("=".repeat(50));

  // Send connection confirmation
  socket.emit('connected', {
    message: 'Connected to server',
    socketId: socket.id
  });

  // Parent registers their device
  socket.on('register_parent', (data) => {
    const { parentId, childId } = data;
    connectedDevices.set(parentId, {
      socketId: socket.id,
      type: 'parent',
      childId: childId
    });

    socket.parentId = parentId;
    console.log(`✅ Parent ${parentId} registered with child ${childId}`);
    
    // Notify parent of successful registration
    socket.emit('parent_registered', {
      success: true,
      parentId: parentId,
      childId: childId
    });
  });

  // Child registers their device
  socket.on('register_child', (data) => {
    console.log("=".repeat(50));
    console.log("📝 CHILD REGISTRATION ATTEMPT");
    console.log("   Socket ID:", socket.id);
    console.log("   Received data:", JSON.stringify(data, null, 2));
    
    const { childId } = data;
    
    if (!childId) {
      console.log("❌ ERROR: childId is missing in registration data");
      socket.emit('child_registered', {
        success: false,
        error: 'childId is required'
      });
      return;
    }
    
    connectedDevices.set(childId, {
      socketId: socket.id,
      type: 'child',
      registeredAt: new Date().toISOString()
    });

    socket.childId = childId;
    console.log(`✅ Child ${childId} registered successfully`);
    console.log(`   Total connected devices: ${connectedDevices.size}`);
    console.log("=".repeat(50));
    
    // Notify child of successful registration
    socket.emit('child_registered', {
      success: true,
      childId: childId
    });
  });

  // Parent sends lock command
  socket.on('lock_child_phone', (data) => {
    const { parentId, childId, lock } = data;

    console.log(`🔒 Lock command from ${parentId} for child ${childId}: ${lock}`);

    // Find child's socket
    const childDevice = connectedDevices.get(childId);

    if (childDevice && childDevice.type === 'child') {
      // Send lock command to child
      io.to(childDevice.socketId).emit('phone_lock_status', {
        locked: lock,
        timestamp: new Date().toISOString()
      });
      console.log(`📤 Lock command sent to child ${childId}`);

      // Confirm to parent
      socket.emit('lock_command_sent', {
        success: true,
        childId: childId,
        locked: lock,
        timestamp: new Date().toISOString()
      });
    } else {
      console.log(`❌ Child device ${childId} not found or not connected`);
      socket.emit('lock_command_sent', {
        success: false,
        error: 'Child device not connected',
        childId: childId
      });
    }
  });

  // Child sends lock acknowledgment
  socket.on('lock_acknowledgment', (data) => {
    const { childId, locked, commandTimestamp, acknowledgedAt } = data;
    console.log(`✅ Lock acknowledgment from child ${childId}: ${locked}`);

    // Find parent's socket
    const childDevice = connectedDevices.get(childId);
    if (childDevice && childDevice.type === 'child') {
      // Find parent by searching for parent with this childId
      for (const [id, device] of connectedDevices.entries()) {
        if (device.type === 'parent' && device.childId === childId) {
          io.to(device.socketId).emit('lock_acknowledged', {
            childId: childId,
            locked: locked,
            commandTimestamp: commandTimestamp,
            acknowledgedAt: acknowledgedAt,
            timestamp: new Date().toISOString()
          });
          console.log(`📤 Lock acknowledgment sent to parent ${id}`);
          break;
        }
      }
    }
  });

  // Child sends status update
  socket.on('child_status_update', (data) => {
    const { childId, status, battery, lastActive, appState, timestamp } = data;
    console.log(`📊 Status update from child ${childId}:`, status);

    // Find parent's socket
    const childDevice = connectedDevices.get(childId);
    if (childDevice && childDevice.type === 'child') {
      // Find parent by searching for parent with this childId
      for (const [id, device] of connectedDevices.entries()) {
        if (device.type === 'parent' && device.childId === childId) {
          io.to(device.socketId).emit('child_status', {
            childId: childId,
            status: status,
            battery: battery,
            lastActive: lastActive,
            appState: appState,
            timestamp: timestamp || new Date().toISOString()
          });
          console.log(`📤 Status update sent to parent ${id}`);
          break;
        }
      }
    }
  });

  // Child sends emergency alert
  socket.on('child_emergency_alert', (data) => {
    const { childId, reason, location, timestamp } = data;
    console.log(`🚨 Emergency alert from child ${childId}: ${reason}`);

    // Find parent's socket
    const childDevice = connectedDevices.get(childId);
    if (childDevice && childDevice.type === 'child') {
      // Find parent by searching for parent with this childId
      for (const [id, device] of connectedDevices.entries()) {
        if (device.type === 'parent' && device.childId === childId) {
          io.to(device.socketId).emit('child_emergency', {
            childId: childId,
            reason: reason,
            location: location,
            timestamp: timestamp || new Date().toISOString()
          });
          console.log(`📤 Emergency alert sent to parent ${id}`);
          break;
        }
      }
    }
  });

  // Child requests unlock
  socket.on('unlock_request', (data) => {
    const { childId, reason, requestedAt } = data;
    console.log(`🔓 Unlock request from child ${childId}: ${reason}`);

    // Find parent's socket
    const childDevice = connectedDevices.get(childId);
    if (childDevice && childDevice.type === 'child') {
      // Find parent by searching for parent with this childId
      for (const [id, device] of connectedDevices.entries()) {
        if (device.type === 'parent' && device.childId === childId) {
          io.to(device.socketId).emit('unlock_request_received', {
            childId: childId,
            reason: reason,
            requestedAt: requestedAt,
            timestamp: new Date().toISOString()
          });
          console.log(`📤 Unlock request sent to parent ${id}`);
          break;
        }
      }
    }
  });

  // Handle disconnection
  socket.on('disconnect', (reason) => {
    console.log("=".repeat(50));
    console.log('❌ USER DISCONNECTED');
    console.log('   Socket ID:', socket.id);
    console.log('   Reason:', reason);
    console.log('   Parent ID:', socket.parentId || 'None');
    console.log('   Child ID:', socket.childId || 'None');
    console.log("=".repeat(50));

    // Remove from connected devices
    if (socket.parentId) {
      connectedDevices.delete(socket.parentId);
      console.log(`🗑️  Parent ${socket.parentId} removed from connected devices`);
    }
    if (socket.childId) {
      connectedDevices.delete(socket.childId);
      console.log(`🗑️  Child ${socket.childId} removed from connected devices`);
    }
    console.log(`   Remaining connected devices: ${connectedDevices.size}`);
  });

  socket.on('error', (error) => {
    console.log('🚨 Socket error:', error);
  });
});

// REST API routes
app.get('/api/test', (req, res) => {
  res.json({
    message: 'Server is running!',
    ip: LOCAL_IP,
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    connectedDevices: connectedDevices.size,
    devices: Array.from(connectedDevices.entries()).map(([id, data]) => ({
      id,
      type: data.type,
      childId: data.childId || null,
      connected: true
    }))
  });
});

app.get('/api/connected-devices', (req, res) => {
  const devices = Array.from(connectedDevices.entries()).map(([id, data]) => ({
    id,
    type: data.type,
    childId: data.childId || null,
    connected: true
  }));
  res.json({ devices });
});

// Start server
const PORT = process.env.PORT || 3200;
server.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Local: http://localhost:${PORT}`);
  console.log(`📍 Network: http://${LOCAL_IP}:${PORT}`);
  console.log(`🌐 WebSocket: ws://${LOCAL_IP}:${PORT}`);
  console.log(`\n📡 API Endpoints:`);
  console.log(`   GET /api/health - Server health check`);
  console.log(`   GET /api/connected-devices - List connected devices`);
  console.log(`\n🔌 Socket Events:`);
  console.log(`   Parent: register_parent, lock_child_phone`);
  console.log(`   Child: register_child, child_status_update, lock_acknowledgment`);
});
