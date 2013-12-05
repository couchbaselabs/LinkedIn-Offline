var follow = require("follow"),
  request = require("request-json"),
  docstate = require("docstate").control();

var syncGatewayAdminDb = "http://localhost:4985/linkedin";
var linkedInClient = request.newClient("https://api.linkedin.com");
var adminClient = request.newClient("http://localhost:4985/linkedin");


// download company data visible to different users
// var linkedInUserProfileUrl = "/v1/people/~:(id,email-address,first-name,last-name,headline,current-share,summary,picture-url,public-profile-url,specialties,positions)?format=json&oauth2_access_token="+accessToken;


var feed = new follow.Feed({db:syncGatewayAdminDb, include_docs:true, filter : "sync_gateway/bychannel", query_params : {channels : "new-users"}});

// handle new users
docstate.safe("user", "new", function(doc){
  console.log("new user", doc)
  var userID = doc._id.substr(2);
  // fetch the users contacts
  var connectionsURL = "/v1/people/~/connections?format=json&oauth2_access_token="+doc.accessToken
  linkedInClient.get(connectionsURL, function(err, res, body){
    if (err) {
      console.error("error with user", doc._id, err)
    } else {
      insertProfiles(doc, body.values, function(err) {
        if (err) {
          console.error("error insertProfiles", err)
        } else {
          grantAccessToContacts(userID, body.values.map(function(v){return v.id;}), function(err){
            if (err) {
              throw err;
            }
              // doc.state = "gotConnections";
              // adminClient.post("/linkedin/", doc, function(err) {
              //   console.log("imported user's contacts")
              // })
          });
        }
      })
    }
  })
})

function grantAccessToContacts(userID, contactIDs, done) {
  adminClient.get("/linkedin/_user/"+userID, function(err, res, body) {
    if (err) {return done(err)}
    console.log("grantAccessToContacts", body)
  });
}

function insertProfiles(user, profiles, done) {
  var p = profiles.pop();
  if (!p) {return done()}
  if (p["private"]) {return insertProfiles(user, profiles, done)}
  var docID = "p:"+p.id;
  adminClient.put("/linkedin/"+docID, p, function(err) {
    if (err) {return done(err)}
    insertProfiles(user, profiles, done);
  })
}


// handle new companies
docstate.safe("company", "new", function(doc){
  console.log("new company", doc)
})

docstate.start()

feed.on('change', function(change) {
  docstate.handle(change.doc);
})

feed.on('error', function(err) {
  console.error('Since Follow always retries on errors, this must be serious');
  throw err;
})

feed.follow();
