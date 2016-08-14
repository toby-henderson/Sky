# Search for individual user details
cbq> select * from `users` a where META(a).id  = "users:fred.flintstone@gmail.com"

# Search for all messages to a user, grouped by from user
cbq> select m.msg, l.key 
       from `messages` m, UNNEST META(a).id l 
      where m.ToUsr = "users:ted.bear@yahoo.com"
and EXISTS (select 1 
              from `messages` a 
             USE KEY l.key 
             where a.FmUsr = "users:fred.flintstone@gmail.com");

#Search for all messages from a user, grouped by to user
cbq> select m.msg, l.key 
       from `messages` m, UNNEST META(a).id l 
      where m.FmUsr = "users:fred.flintstone@gmail.com")
and EXISTS (select 1 
              from `messages` a 
             USE KEY l.key 
             where m.ToUsr = "users:ted.bear@yahoo.com";

#Search for all messages between 2 users
cbq> select * 
       from `messages` m
      where  ((m.FmUsr = "users:fred.flintstone@gmail.com" 
              And m.ToUsr = "users:ted.bear@yahoo.com")
              Or
              (m.FmUsr = "users:ted.bear@yahoo.com" 
              And m.ToUsr = "users:fred.flintstone@gmail.com" ))
      Order by MsgCreateDate;