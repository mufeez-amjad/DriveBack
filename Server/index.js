const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io').listen(server);

var admin = require("firebase-admin");
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
    //console.log('Connected: %s sockets connected', connections.length);

    socket.on('newMessage', function (data) {
        var date = new Date().toLocaleDateString();
        var time = new Date().toLocaleTimeString('en-US', { hour12: false, hour: "numeric", minute: "numeric"});
        var dateNTime = date + ' ' + time;

        let from = data[0].from.toUpperCase();
        let to = data[0].to.toUpperCase();
        
        var messageJSON = {
            from: from,
            message: data[0].message,
            time: dateNTime
        };

        var usersRef = db.collection('users');
        var convosRef = db.collection('conversations');


        //check all convos
        //check to see if already exists with receiver
        //add to existing convo
        //if no convos are to receiver, make a new one

        var checkConvos = usersRef.doc(from).get()
                .then(doc => {
                    data = doc.data();
                    var convos = data.conversations;

                    var convoExists = false;

                    for (var i in convos) {
                        var id = convos[i];
                        
                        var checkConvo = convosRef.doc(id).get()
                            .then(doc => {
                                data = doc.data();
                                    //if convo already exists with recipient
                                    if (data.to == to){
                                        convoExists = true;
                                        
                                        //update the messages and time in the conversation
                                        var messagesArray = data.messages;
                                        messagesArray.push(messageJSON);
                                        var updateMany = convosRef.doc(id).update({
                                            time: dateNTime,
                                            messages: messagesArray,
                                        });
                                    }
                            })
                            .catch(err => {
                                console.log('Error getting conversation', err);
                            });
                        if (convoExists) break;
                    }

                    if (!convoExists) {
                        addMessage(from, to, dateNTime, messageJSON);
                        console.log('Created new conversation!')
                    }

                })
                .catch(err => {
                    console.log('Error getting user', err);
                });
    });

    socket.on('newUser', function (data) {

        //TODO: don't overwrite existing user with convos
        //TODO: send signal to close sign up window iOS

        var plate = data[0].Plate.toUpperCase();
        
        //formats input correctly
        let fName = data[0].First.charAt(0).toUpperCase() + data[0].First.slice(1).toLowerCase();
        let lName = data[0].Last.charAt(0).toUpperCase() + data[0].Last.slice(1).toLowerCase();

        var data = { 
            uid: data[0].uid,
            first: fName,
            last: lName,
            conversations: []
        };
          
          var setDoc = db.collection('users').doc(plate).set(data);
          console.log('New user created!')
    });

    socket.on('disconnect', function (data) {
        connections.splice(connections.indexOf(socket), 1);
        //console.log('Disconnected: %s sockets connected', connections.length);
    });
});

function addMessage(from, to, dateNTime, messageJSON){

    var newMessage = db.collection('conversations').add({
        from: from,
        to: to,
        time: dateNTime,
        messages: [messageJSON]
      }).then(ref => {

        //dismiss client screen only if message sent successfully
        //socket.emit("sent")

        var usersRef = db.collection('users');

        //add to sender
        var getConvos = usersRef.doc(from).get()
            .then(doc => {
                data = doc.data()
                var convos = data.conversations
                convos.push(ref.id)
                var updateSingle = usersRef.doc(from).update({ conversations: convos });
            })
            .catch(err => {
                console.log('Error getting document', err);
            });

        //add to receiver (could not exist)
        var getConvos = usersRef.doc(to).get()
        .then(doc => {
            if (!doc.exists) {
                //creates new user document with conversation

                var data = { 
                    uid: "",
                    first: "",
                    last: "",
                    conversations: [ref.id]
                };

                var setDoc = usersRef.doc(to).set(data); 

            } else {
                data = doc.data()
                var convos = data.conversations
                convos.push(ref.id)
                var updateSingle = usersRef.doc(to).update({ conversations: convos });
            }
        })
        .catch(err => {
            console.log('Error getting document', err);
        });

      });
} 