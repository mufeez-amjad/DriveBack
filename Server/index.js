const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io').listen(server);

var admin = require("firebase-admin");
//serviceAccountKey.json
var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://driveback-68d28.firebaseio.com"
});

users = [];
connections = [];

var db = admin.firestore();

server.listen(process.env.PORT || 3000);
console.log('Server running...');

io.sockets.on('connection', function (socket) {
    connections.push(socket);
    console.log('Connected: %s sockets connected', connections.length);

    socket.on('message', function (data) {
        var address = data[0].to;
        var message = data[0].message;
        console.log('To: ' + address);
        console.log('Message ' + message);
        //console.log(data);
    });

    socket.on('newUser', function (data) {
        var uid = data[0].uid
        delete data[0].uid
        
        //creates a new document inside users with the UID identifier
        var data = {
            First: data[0].First,
            Last: data[0].Last,
            Plate: data[0].Plate
          };
          
          // Add a new document in collection "cities" with ID 'LA'
          var setDoc = db.collection('users').doc(uid).set(data);

        //var setDoc = db.collection('users').doc(uid).set(data[0]);
        //console.log(data[0])
    });


    //Disconnect
    socket.on('disconnect', function (data) {
        connections.splice(connections.indexOf(socket), 1);
        console.log('Disconnected: %s sockets connected', connections.length);
    })
});