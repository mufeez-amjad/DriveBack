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

let usersRef = db.collection('users');
let convosRef = db.collection('conversations');

io.sockets.on('connection', function (socket) {
    connections.push(socket);
    console.log('Connected: %s sockets connected', connections.length);

    socket.on('newMessage', function (data) {
        try {
            checkConvos(data, socket)
        } catch(err) {
            console.log('Error getting documents', err);
            socket.emit('messageStatus', "failed");
        }
    });

    socket.on('getConvos', function (data) {
        console.log("requested convos");

        try {
            getConvos(data, socket)
        } catch(err) {
            console.log('Error getting documents', err);
            socket.emit('messageStatus', "failed");
        }
    });

    socket.on('newUser', function (data) {

        //TODO: don't overwrite existing user with convos

        var plate = data[0].Plate.toUpperCase();
        
        //formats input correctly
        let fName = data[0].First.charAt(0).toUpperCase() + data[0].First.slice(1).toLowerCase();
        let lName = data[0].Last.charAt(0).toUpperCase() + data[0].Last.slice(1).toLowerCase();

        var dataNew = { 
            uid: data[0].uid,
            first: fName,
            last: lName,
            conversations: []
        };

        var getConvos = usersRef.doc(plate).get()
                .then(doc => {
                    if(!doc.exists){
                        var setDoc = usersRef.doc(plate).set(dataNew);
                    } else {
                        var updateMany = usersRef.doc(plate).update({
                            uid: data[0].uid,
                            first: fName,
                            last: lName
                        });
                    }
                    socket.emit('userStatus', 'created')
                    //console.log('New user created!')
                })
                .catch(err => {
                    console.log('Error getting document', err);
                });
    });

    socket.on('disconnect', function (data) {
        connections.splice(connections.indexOf(socket), 1);
        //console.log('Disconnected: %s sockets connected', connections.length);
    });
});

async function getConvos(data, socket){ //gets conversations to be displayed on the main screen
    var plate = data;
    
    let getConvoIds = await usersRef.doc(plate).get()
    var retrievedData = getConvoIds.data();

    var convos = retrievedData.conversations

    var messages = [];
    
    for (var i in convos) {
        var id = convos[i];
        //get last message, time and other plate
        let checkConvo = await convosRef.doc(id).get()
            
        var convoData = checkConvo.data();
        
        var other = "";
        if (convoData.from == plate){
            other = convoData.to;
        } else {
            other = convoData.from;
        }
        //adds a space between state and license plate number
        other = other.substring(0 , other.length - 2) + " " + other.substring(other.length - 2 );

        var time = convoData.time;
        //gets array of messages, retrieves message string from last message
        var lastMessage = convoData.messages.slice(-1)[0].message;

        var message = {
            with: other,
            time: time,
            message: lastMessage
        };

        messages.push(message)
    } 
    socket.emit('convos', messages);
}

async function checkConvos(data, socket){ //checks for existing conversations to add messages to, or make new

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

    let checkConvos = await usersRef.doc(from).get()
    
    data = checkConvos.data();
    var convos = data.conversations;

    var convoExists = false;

    for (var i in convos) {
        var id = convos[i];
        
        let checkConvo = await convosRef.doc(id).get()
            
        data = checkConvo.data();
        //if convo already exists with recipient
        if (data.to == to || data.to == from){
            convoExists = true;
            
            //update the messages and time in the conversation
            var messagesArray = data.messages;
            messagesArray.push(messageJSON);
            var updateMany = convosRef.doc(id).update({
                time: dateNTime,
                messages: messagesArray,
            });
            break;
        }
    }

    if (!convoExists) {
        addMessage(from, to, dateNTime, messageJSON);
        console.log('Created new conversation!')
    }

    socket.emit('messageStatus', "sent")
}

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