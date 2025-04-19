# .mongoshrc.js
 -  the js file that can be set to run on start of mongosh
 - useful for setting system wide defaults, checking on something etc
 > example db.adminCommand() is used by the dbas to check status of dbs
 > the following command checks for server compatibility. 
   db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})

 we can edit the .mongoshrc.js file and add the following to check the server compatibily at startup. doing this way, we are also shortening the command typing size.
  const fcv = () => db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})

# change the prompt by modifying the .mongoshrc.js file

 prompt = () => {
 let returnString = "";
 const dbName = db.getName();
 const isEnterprise = db.serverBuildInfo().modules.includes("enterprise");
 const mongoURL = db.getMongo()._uri.includes("mongodb.net");
 const nonAtlasEnterprise = isEnterprise && !mongoURL;
 const usingAtlas = mongoURL && isEnterprise;
 const readPref = db.getMongo().getReadPrefMode();
 const isLocalHost = /localhost|127\.0\.0\.1/.test(db.getMongo()._uri);
 const currentUser = db.runCommand({ connectionStatus: 1 }).authInfo
   .authenticatedUsers[0]?.user;
 if (usingAtlas) {
   returnString += `Atlas || ${dbName} || ${currentUser} || ${readPref} || =>`;
 } else if (isLocalHost) {
   returnString += `${
     nonAtlasEnterprise ? "Enterprise || localhost" : "localhost"
   } || ${dbName} || ${readPref} || =>`;
 } else if (nonAtlasEnterprise) {
   returnString += `Enterprise || ${dbName} || ${currentUser} || ${readPref} || =>`;
 } else {
   returnString += `${dbName} || ${readPref} || =>`;
 }
 return returnString;
}; 

