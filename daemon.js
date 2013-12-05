var follow = require("follow"),
  request = require("./json-client"),
  docstate = require("docstate").control();

var adminDb = "http://localhost:4985/linkedin";


// download company data visible to different users
// var linkedInUserProfileUrl = "/v1/people/~:(id,email-address,first-name,last-name,headline,current-share,summary,picture-url,public-profile-url,specialties,positions)?format=json&oauth2_access_token="+accessToken;


var feed = new follow.Feed({db:adminDb, include_docs:true, filter : "sync_gateway/bychannel", query_params : {channels : "new-users"}});

// handle new users
docstate.safe("user", "new", function(doc){
  console.log("new user", doc)
  var userID = doc._id.substr(2);
  // fetch the users contacts
  var connectionsURL = "https://api.linkedin.com/v1/people/~/connections?format=json&oauth2_access_token="+doc.accessToken
  request.get(connectionsURL, function(err, res, body){
    if (err) {
      console.error("error with user", doc._id, err)
    } else {
      console.log(body.values.length)
      var contactIDs = body.values.map(function(v){return v.id;});
      insertProfiles(doc, body.values, function(err) {
        if (err) {
          console.error("error insertProfiles", err)
        } else {

          grantAccessToContacts(userID, contactIDs, function(err){
            if (err) {
              throw err;
            }
              doc.state = "gotConnections";
              console.log("doc", doc)
              request.put(adminDb+"/"+doc._id, {json:doc}, function(err) {
                if (err) {
                  throw err;
                }
                console.log("imported user's contacts")
              })
          });
        }
      })
    }
  })
})

function grantAccessToContacts(userID, contactIDs, done) {
  request.get(adminDb+"/_user/"+userID, function(err, res, body) {
    if (err) {return done(err)}
    body.admin_channels = body.admin_channels || [];
    var chans = {};
    for (var i = 0; i < body.admin_channels.length; i++) {
      chans[body.admin_channels[i]] = true;
    }
    for (i = 0; i < contactIDs.length; i++) {
      if (contactIDs[i] != "private") chans[contactIDs[i]] = true;
    }
    body.admin_channels = Object.keys(chans);
    console.log("grantAccessToContacts", contactIDs, body)
    request.put(adminDb+"/_user/"+userID, {json : body}, done)
  });
}

function insertProfiles(user, profiles, done) {
  var p = profiles.pop();
  if (!p) {return done()}
  if (p.id == "private") {return insertProfiles(user, profiles, done)}
  delete p.apiStandardProfileRequest;
  p.type = "profile"
  var docURL= adminDb+"/p:"+p.id;
  request.get(docURL, function(err, res, doc) {
    if (err == 404) {
      request.put(docURL, {json:p}, function(err) {
        if (err) {return done(err)}
        insertProfiles(user, profiles, done);
      })
    } else if (err) {
      done(err)
    } else {
      // todo merge any new info into the doc and save back
      // for now skip it
      insertProfiles(user, profiles, done);
    }

  })
}


// handle new companies
docstate.safe("company", "new", function(doc){
  console.log("new company", doc)
})

docstate.start()

feed.on('change', function(change) {
  if (change.doc) docstate.handle(change.doc);
})

feed.on('error', function(err) {
  console.error('Since Follow always retries on errors, this must be serious');
  throw err;
})

feed.follow();

