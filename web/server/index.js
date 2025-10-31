//
// WD Server  
//

import { serve } from 'bun';
import { redis } from 'bun';

import { createHmac } from 'node:crypto';

const PATH_ASSETS = "../assets/";
const LOC_ASSET = PATH_ASSETS + 'loc.json';

const PATH_CLIENT = "../client";


function isNumber(n) { return !isNaN(parseFloat(n)) && !isNaN(n - 0) }

const EIDUSR = 101;
const EIDMSGADD = 201;
const ALLEIDS = [EIDUSR, EIDMSGADD];

const NONCEKEY = 'nonce';
const USERKEY = 'user:';
const EVENTKEY = 'event:';

const EKUSR = EVENTKEY+`${EIDUSR}`;
const EKMSGADD = EVENTKEY+`${EIDMSGADD}`;
const ALLEKS = [EKUSR, EKMSGADD];

const genAddNonce = (nonce) => [NONCEKEY, Date.now(), nonce];
const genRankNonce = (nonce) => [NONCEKEY, nonce];

const genUserAddEvent = (galn) => [EKUSR, "*", 'd', `${galn}+`];
const genUserRemEvent = (galn) => [EKUSR, "*", 'd', `${galn}-`];
const getFromUserEvent = (e) => [e[0], e[1][1]];

const genMsgAddEvent = (from, msg, nonce, to) => [
    EKMSGADD, "*", 'f',from, 'm',msg, 'n',nonce, 't',to
];
const getFromMsgEvent = (e) => [e[0], [e[1][1], e[1][3], e[1][5], e[1][7]]];

const genAddUser = (galn) => [USERKEY, Date.now(), galn];
const genRemUser = (galn) => [USERKEY, galn];

const cleanupInterval = 120000;
var cleanupTimerID = 0;

var locations = {};

// cleanup
async function cleanup() {

    console.log("WD: running cleanup ... ");
    var res = 0;

    // clean up events
    // message add event queue should not be longer than 100000 events
    const MAXMSGEVENTS = 100000;
    res = await redis.send('XTRIM', [EKMSGADD, 'MAXLEN', '~', MAXMSGEVENTS]);
    // user add/rem event queue should not be longer than 5000 events
    const MAXUSREVENTS = 5000;
    res = await redis.send('XTRIM', [EKUSR, 'MAXLEN', '~', MAXUSREVENTS]);

    // clean up users
    // users who are inactive for more than 30 mins (now - u > 1800*1000)
    const MINUSER = Date.now() - 1800000;
    res = await redis.send('ZREMRANGEBYSCORE', [USERKEY, '-inf', MINUSER]);

    // clean up nonce
    // any nonce older than  5 mins (now - 5*60*1000)
    const MINNONCE = Date.now() - 300000;
    res = await redis.send('ZREMRANGEBYSCORE',[NONCEKEY, '-inf', MINNONCE]);

    return;
}

// jwt sign
async function jwt_sign(payload, secret = process.env.JWT_SECRET) {
    // Create JWT header
    const header = {
        alg: 'HS256',
        typ: 'JWT'
    };

    // Base64Url encode header
    const encodedHeader = Buffer.from(JSON.stringify(header))
        .toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');

    // Base64Url encode payload
    const encodedPayload = Buffer.from(JSON.stringify(payload))
        .toString('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');

    // Create signature
    const signatureInput = `${encodedHeader}.${encodedPayload}`;
    
    // Create HMAC SHA256 signature
    const signature = createHmac('sha256', secret)
        .update(signatureInput)
        .digest('base64')
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=/g, '');

    // Combine all parts
    return `${encodedHeader}.${encodedPayload}.${signature}`;
}
// jwt verify
async function jwt_verify(token, secret = process.env.JWT_SECRET) {
    try {
        // Split the token into parts
        const parts = token.split('.');
        if (parts.length !== 3) {
            throw new Error('Invalid token format');
        }

        const [encodedHeader, encodedPayload, providedSignature] = parts;

        // Verify signature
        const signatureInput = `${encodedHeader}.${encodedPayload}`;
        const expectedSignature = createHmac('sha256', secret)
            .update(signatureInput)
            .digest('base64')
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');

        if (providedSignature !== expectedSignature) {
            throw new Error('Invalid signature');
        }

        // Decode header (for algorithm verification)
        const header = JSON.parse(
            Buffer.from(encodedHeader, 'base64url').toString('utf-8')
        );

        // Verify algorithm
        if (header.alg !== 'HS256') {
            throw new Error('Invalid algorithm');
        }

        // Decode payload
        const payload = JSON.parse(
            Buffer.from(encodedPayload, 'base64url').toString('utf-8')
        );

        return {
            valid: true,
            payload
        };
    } catch (error) {
        return {
            valid: false,
            error: error.message
        };
    }
}

// check if id is a valid key in USERKEY
async function isValidUser(galn) {
    var res = await redis.send('ZRANK', [USERKEY, galn]);
    return res !== null ? true : false;
}

// get all users from user sorted set
async function getAllUsers() {
    var users = [];
    var users = await redis.send('ZRANGE', [USERKEY, '0', '-1']);
    return users;
}

// get all users as an event list 
async function getAllUsersAsEvents() {
    var users = await getAllUsers();
    var events = {};

    events[EIDUSR] = [];
    for(const galn of users) {
        events[EIDUSR].push(`${galn}+`);
    }

    return events;
}

// get all events from a time epoch
async function getAllEventsFrom(user, from) {
    const count = 10;
    const sids = Array(ALLEKS.length).fill(from);
    const events = ALLEIDS.reduce((acc, item) => {
        acc[item] = [];
        return acc;
    },{});
    var done = false;
    

    while(!done) {
        var cmdXread = ['COUNT', count, 'STREAMS', ALLEKS, sids].flat();
        var res = await redis.send('XREAD', cmdXread);

        if(res == null) {
            done = true;
            continue;
        }

        if(EKUSR in res) { 
            for (const e of res[EKUSR]) { 
                var f = getFromUserEvent(e);
                events[EIDUSR].push(f[1]);
                sids[0] = f[0];
            }
        }

        if(EKMSGADD in res) {
            for (const e of res[EKMSGADD]) {
                var f = getFromMsgEvent(e);
                var ts = parseInt(f[0].split('-')[0])/1000;
                if(f[1][0] === user || f[1][3] === user)
                    events[EIDMSGADD].push([ts, f[1], f[1][3] === user].flat());
                sids[1] = f[0];
            }
        }
    }
    
    return events;
}

// sync events
async function syncEvents(galn) {
    var last_sync = await redis.send('ZSCORE', [USERKEY, galn]);
    last_sync = last_sync + '-0';

    var events = await getAllEventsFrom(galn, last_sync);
    await redis.send('ZADD', genAddUser(galn));

    return events;
}

//
// Handlers
//

// login 
async function loginHandler(request) {
    // Parse request body
    const data = await request.json();
    
    // Validate input
    if (!data.name || !data.age || !data.gender || !data.location) {
        return Response.json({
            success: false,
            notification: 'Missing required fields',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }

    // Validate namevar usrs = await getAllUsers();
    if (!/^[A-Za-z0-9_]{5,12}$/.test(data.name)) {
        return Response.json({
            success: false,
            notification: 'Name must be 5-12 characters, alphanumeric and underscore only',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }
    
    // Validate age
    const age = parseInt(data.age);
    if ( isNaN(age) || age < 18 || age > 99 ) {
        return Response.json({
            success: false,
            notification: 'Age must be between 18 and 99',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }

    // Validate gender
    if (!['M', 'F'].includes(data.gender)) {
        return Response.json({
            success: false,
            notification: 'Gender must be M or F',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }

    // Validate location
    if (!data.location || data.location.length !== 5) {
        return Response.json({
            success: false,
            notification: 'Location code incorrect format',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }

    if (!(data.location in locations)) {
        return Response.json({
            success: false,
            notification: 'Invalid location code',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }

    // Check if location is valid from list 
    // TBD

    // Create GALN string
    const genderChar = data.gender === 'F' ? '+' : '-';
    const ageStr = age.toString().padStart(2, '0');
    const namePadded = data.name.padEnd(12, '.');
    const galn = `${genderChar}${ageStr}${data.location}${namePadded}`;

    //Check if hash exists with
    var res = await isValidUser(galn);
    if( res === true ) {
        return Response.json({
            success: false,
            notification: 'User already exists',
            token: "",
            events: {}
        }, {
            status: 400
        });
    }

    // Create JWT token
    const token = await jwt_sign({ 
        galn,
        timestamp: Date.now()
    });
    
    // console.log(galn);
    const events = await getAllUsersAsEvents();
    await redis.send('ZADD', genAddUser(galn));
    await redis.send('XADD', genUserAddEvent(galn));

    return Response.json({
        success: true,
        notification: 'Login successful',
        token,
        events
    }, {
        status: 200
    });
}

// logout
async function logoutHandler(auth, request) {
    
    var galn = auth['galn'];

    // remove hash from REDIS
    var res = await redis.send('ZREM', genRemUser(galn));
    if(res !== 1) {
        return Response.json({
            success: false,
            notification: 'Internal server error',
        }, {
            status: 500
        });
    }

    // add event to queue
    await redis.send('XADD', genUserRemEvent(galn));

    // send logout response as success
    return Response.json({
        success: true,
        notification: 'Successfully logged out',
    }, {
        status: 200
    });
}

// sync
async function syncHandler(auth, request) {
    
    var events = await syncEvents(auth['galn']);

    return Response.json({
            success: true,
            notification: 'Sync completed',
            events,
        }, {
            status: 200
        });
}

// message
async function messageHandler(auth, request) {
    
    const galn = auth['galn'];
    const data = await request.json();
    var res = "";

    // validate input
    if (!data.to || !data.nonce || !data.message ) {
        return Response.json({
            success: false,
            notification: 'Missing required fields',
            events: {}
        }, {
            status: 400
        });
    }

    // check if user exists
    res = await isValidUser(data.to);
    if(res === false) {
        return Response.json({
            success: false,
            notification: 'User does not exist',
            events: {}
        }, {
            status: 400
        });
    }

    // check if message already received.
    res = await redis.send('ZSCORE', genRankNonce(data.nonce));
    if(isNumber(res)) {
        return Response.json({
            success: false,
            notification: 'Message already received',
            events: {}
        }, {
            status: 400
        });
    }

    // TBD filter message for 
    // 1. URL
    // 2. slang
    // 3. unprintable characters
    // 4. anything else ?


    // add nonce to set    
    res = await redis.send('ZADD', genAddNonce(data.nonce));

    // add message to event queue
    res = await redis.send('XADD', genMsgAddEvent(galn, data.message, data.nonce, data.to));

    // sync events
    var events = await syncEvents(galn);

    return Response.json({
            success: true,
            notification: 'Message delivered',
            events,
        }, {
            status: 200
        });
}

// inject it to every API handler 
async function authAPIRequest(request, handler) {

    // Check for Authorization header
    const authHeader = request.headers.get('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return Response.json({
            success: false,
            notification: 'No valid token provided',
            error: 'Unauthorized'
        }, {
            status: 401
        });
    }

    const token = authHeader.split(' ')[1];

    // Verify the JWT token
    const verification = await jwt_verify(token);
    if (!verification.valid) {
        return Response.json({
            success: false,
            notification: verification.error,
            error: 'Unauthorized'
        }, {
            status: 401
        });
    }

    // Check if payload["galn"] is a valid key in 
    var res = await isValidUser(verification.payload['galn']);
    if(res === false){
        return Response.json({
            success: false,
            notification: 'User not registered!',
            error: 'Unauthorized'
        }, {
            status: 401
        });
    }

    // If authentication passes, call the handler
    try {
        return await handler(verification.payload, request);
    } catch (error) {
        return Response.json({
            success: false,
            notification: error.toString(),
            error: 'Internal Server Error'
        }, {
            status: 500
        });
    }
}

console.log("WD: starting server ... ");
await (async function initServer() {

    var res = 0;
    const pf = 'WD: '

    //clear keys in cac as list of event objectshe
    process.stdout.write(pf+"clear keys in cache ... ");
    res = await redis.send('DEL', [USERKEY, NONCEKEY, EKUSR, EKMSGADD]);
    console.log("done");

    
    console.log(pf+"loading assets ... ");

    process.stdout.write(pf+"loading locations ... ");
    locations = await Bun.file(LOC_ASSET).json();
    console.log("done");
    
    console.log(pf+"assets loaded");

    process.stdout.write(pf+"start periodic cleanup agent ... ");
    //tbd run cleanup with a periodic timer every 2 mins
    cleanupTimerID = setInterval(cleanup, cleanupInterval);
    console.log("done");

    // await redis.send('ZADD', genAddNonce('dodo'));
    // await redis.send('ZADD', genAddUser('abc'));
    // await redis.send('ZADD', genAddUser('def'));
    // var usrs = await getAllUsers();
    // console.log("\n", usrs);

    console.log(pf+"server startup complete!");
})();

const server = serve({
    port: 10000,
    routes: {
        '/': {
            GET: (request, server) => {
                return Response.json({
                    success: true,
                    notification: 'Welcome to the API',
                    version: '1.0'
                });
            }
        },
        '/api/login': {
            POST: async (request, server) => await loginHandler(request)
        },
        '/api/logout': {
            POST: async (request, server) => await authAPIRequest(request, logoutHandler)
        },
        '/api/sync': {
            POST: async (request, server) => await authAPIRequest(request, syncHandler)
        },
        '/api/message': {
            POST: async (request, server) => await authAPIRequest(request, messageHandler)
        }
    }
});

async function shutdownServer() {

    const pf = 'WD: '
    console.log(pf+"terminating server ... ");
    process.stdout.write(pf+"stop periodic cleanup agent ... ");
    clearInterval(cleanupTimerID);
    console.log("done");

    server.stop();
    console.log(pf+"server shutdown complete! ");

    process.exit(0);    
}

// register termination events
process.once("SIGTERM", shutdownServer);
process.once("SIGINT", shutdownServer);

console.log(`WD: server running at ${server.hostname}:${server.port}`);