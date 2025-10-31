import { fetch } from 'bun';

const API_URL = 'http://localhost:10000';
const tokens = {};

async function makeRequest(endpoint, method, body = null, token = null) {
    const headers = {
        'Content-Type': 'application/json'
    };
    
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${API_URL}${endpoint}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : null
    });

    return await response.json();
}

// Add this helper function after makeRequest
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function runTests() {
    console.log('Starting API Tests...\n');

    // 1. Login JohnDoe
    console.log('1. Login JohnDoe:');
    const johnResponse = await makeRequest('/api/login', 'POST', {
        name: 'JohnDoe',
        age: '25',
        gender: 'M',
        location: 'USNY.'
    });
    console.log(JSON.stringify(johnResponse, null, 2));
    if (johnResponse.token) {
        tokens.johnDoe = johnResponse.token;
    }

    await delay(2000); // 2 second delay

    // 2. Login MaryJane
    console.log('\n2. Login MaryJane:');
    const maryResponse = await makeRequest('/api/login', 'POST', {
        name: 'MaryJane',
        age: '23',
        gender: 'F',
        location: 'USCA.'
    });
    console.log(JSON.stringify(maryResponse, null, 2));
    if (maryResponse.token) {
        tokens.maryJane = maryResponse.token;
    }

    await delay(2000); // 2 second delay

    // 3. Sync JohnDoe
    console.log('\n3. Sync JohnDoe:');
    const johnSyncResponse = await makeRequest('/api/sync', 'POST', {}, tokens.johnDoe);
    console.log(JSON.stringify(johnSyncResponse, null, 2));

    await delay(2000); // 2 second delay

    // 4. JohnDoe sends message to MaryJane
    console.log('\n4. JohnDoe sends message to MaryJane:');
    const messageResponse = await makeRequest('/api/message', 'POST', {
        to: '+23USCA.MaryJane....',
        message: "Hello MaryJane!",
        nonce: "45-JMxVvY"
    }, tokens.johnDoe);
    console.log(JSON.stringify(messageResponse, null, 2));

    // 4.1 JohnDoe sends message to the other JohnDoe
    console.log('\n4.1. JohnDoe sends message to other:');
    const messageResponse2 = await makeRequest('/api/message', 'POST', {
        to: '-25US...JohnDoe.....',
        message: "Hello twin!",
        nonce: "45-Nki73E"
    }, tokens.johnDoe);
    console.log(JSON.stringify(messageResponse2, null, 2));

    await delay(2000); // 2 second delay

    // 5. Sync MaryJane (previously test #4)
    console.log('\n5. Sync MaryJane:');
    const marySyncResponse = await makeRequest('/api/sync', 'POST', {}, tokens.maryJane);
    console.log(JSON.stringify(marySyncResponse, null, 2));

    // Get user input and pause execution
    const userInput = prompt('Press Enter to continue...');
    await delay(2000); // 2 second delay

    // 6. Logout JohnDoe
    console.log('\n6. Logout JohnDoe:');
    const johnLogoutResponse = await makeRequest('/api/logout', 'POST', {}, tokens.johnDoe);
    console.log(JSON.stringify(johnLogoutResponse, null, 2));

    await delay(2000); // 2 second delay

    // 7. Logout MaryJane
    console.log('\n7. Logout MaryJane:');
    const maryLogoutResponse = await makeRequest('/api/logout', 'POST', {}, tokens.maryJane);
    console.log(JSON.stringify(maryLogoutResponse, null, 2));
}

// Run the tests
runTests()
    .then(() => console.log('\nTests completed.'))
    .catch(error => console.error('Test error:', error));