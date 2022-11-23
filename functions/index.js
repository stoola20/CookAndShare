    const jwt = require("jsonwebtoken")
    const fs = require('fs')
  
    // Path to download key file from developer.apple.com/account/resources/authkeys/list
    let privateKey = fs.readFileSync('AuthKey_7GLPAGDN2H.p8');
  
    //Sign with your team ID and key ID information.
    let token = jwt.sign({ 
    iss: 'PDRVZ7DT2S',
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 12000,
    aud: 'https://appleid.apple.com',
    sub: 'com.jessica.CookAndShare'
    
    }, privateKey, { 
    algorithm: 'ES256',
    header: {
    alg: 'ES256',
    kid: '7GLPAGDN2H',
    } });
  console.log(token)  
    return token;

