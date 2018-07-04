const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io').listen(server);
const crypto = require("crypto");

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

/*TODO: 
check if conversation already exists from compose screen, add to existing instead of making new one
go through all the conversations in profile
check to see if it's not with same person
if it is, add it to the conversation
*/

io.sockets.on('connection', function (socket) {
    connections.push(socket);
    console.log('Connected: %s sockets connected', connections.length);

    socket.on('newMessage', function (data) {
        var date = new Date().toLocaleDateString();
        var time = new Date().toLocaleTimeString('en-US', { hour12: false, hour: "numeric", minute: "numeric"});
        var dateNTime = date + ' ' + time;

        let from = data[0].from;
        let to = data[0].to;
        
        var messageJSON = {
            from: from,
            message: data[0].message,
            time: dateNTime
        };

        var convoExists = false

        var checkConvos = usersRef.doc(from).get()
                .then(doc => {
                    data = doc.data()
                    var convos = data.Conversations
                    for (var id in data){
                        if (data.hasOwnProperty(id)) {
                            
                            var checkConvo = usersRef.doc(id).get()
                                .then(doc => {
                                    if (!doc.exists) {
                                        //creates new user document with conversation

                                        var data = { 
                                            UID: "",
                                            First: "",
                                            Last: "",
                                            Conversations: [ref.id]
                                        };

                                        var setDoc = usersRef.doc(to).set(data); 

                                    } else {
                                        data = doc.data()
                                        var convos = data.Conversations
                                        convos.append(ref.id)
                                        var updateSingle = usersRef.doc(to).update({ Conversations: convos });
                                    }
                                })
                                .catch(err => {
                                    console.log('Error getting document', err);
                                });
                            console.log(someObject[prop]);

                        }
                     }

                })
                .catch(err => {
                    console.log('Error getting document', err);
                });

        var newMessage = db.collection('conversations').add({
            from: from,
            to: to,
            time: dateNTime,
            messages: [messageJSON]
          }).then(ref => {

            //dismiss client screen only if message sent successfully

            var usersRef = db.collection('users');

            //add to sender
            var getConvos = usersRef.doc(from).get()
                .then(doc => {
                    data = doc.data()
                    var convos = data.Conversations
                    convos.push(ref.id)
                    var updateSingle = usersRef.doc(from).update({ Conversations: convos });
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
                        UID: "",
                        First: "",
                        Last: "",
                        Conversations: [ref.id]
                    };

                    var setDoc = usersRef.doc(to).set(data); 

                } else {
                    data = doc.data()
                    var convos = data.Conversations
                    convos.append(ref.id)
                    var updateSingle = usersRef.doc(to).update({ Conversations: convos });
                }
            })
            .catch(err => {
                console.log('Error getting document', err);
            });

          });

    });

    socket.on('newUser', function (data) {
        var plate = data[0].Plate
        
        //formats input correctly
        let fName = data[0].First.charAt(0).toUpperCase() + data[0].First.slice(1).toLowerCase();
        let lName = data[0].Last.charAt(0).toUpperCase() + data[0].Last.slice(1).toLowerCase();

        var data = { 
            UID: data[0].uid,
            First: fName,
            Last: lName,
            Conversations: []
        };
          
          var setDoc = db.collection('users').doc(plate).set(data);
          console.log('New user created!')
    });

    socket.on('disconnect', function (data) {
        connections.splice(connections.indexOf(socket), 1);
        console.log('Disconnected: %s sockets connected', connections.length);
    });
});