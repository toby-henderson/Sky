#Data model

#bucket /users

#User data
Key: users:fred.flintstone@gmail.com
{ fname: "Fred",
  sname: "Flintstone", 
     pw: "fg&6lnmv543",
systopt: {font: "Courier New", 
          fontSize: 10, bgcolour: blue}


#User data
Key: ted.bear@yahoo.com
{    fname: "Ted",
     sname: "Bear", 
        pw: "867gjvgfdFHG",
   systopt:  {
              font: "Courier New", 
          fontSize: 11, 
          bgcolour: pink
}

#bucket /messages

#Message data
key: UUID
{FmUsr: "fred.flintstone@gmail.com",
 ToUsr: "users:ted.bear@yahoo.com"
   Msg: "hello there",
   MsgCreateDate: 1471090901,
   MsgReadDate: 1471090919
}


#Message data
key: UUID
{FmUsr: "users:ted.bear@yahoo.com",
 ToUsr: "users:fred.flintstone@gmail.com"
   Msg: "hello to you",
   MsgCreateDate: 1471091039,
   MsgReadDate: 1471091132
}

cbq> CREATE INDEX IX_MESSAGE_FMUSR_MSGCREATEDATE ON `CHATAPP:MESSAGES`(FmUsr) USING GSI "defer_build":true;
cbq> CREATE INDEX IX_MESSAGE_TOUSR_MSGCREATEDATE ON `CHATAPP:MESSAGES`(ToUsr) USING GSI "defer_build":true;