const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io').listen(server);

users = [];
connections = [];

server.listen(process.env.PORT || 3000);
console.log('Server running...')

io.sockets.on('connection', function (socket) {
    connections.push(socket);
    console.log('Connected: %s sockets connected', connections.length);

    socket.on('message', function(data){
        var address = data[0].to;
        var message = data[0].message;
        console.log('To: ' + address);
        console.log('Message ' + message);
        //console.log(data);
    });

    //Disconnect
    socket.on('disconnect', function (data) {
        connections.splice(connections.indexOf(socket), 1);
        console.log('Disconnected: %s sockets connected', connections.length);
    })
});