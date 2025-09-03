/**
 * Validation Test - Corrected Workflow Testing
 * Simple focused test for inline comment validation
 */

// Line 6: SECURITY - Hardcoded API key
const API_KEY = "sk-1234567890abcdef";

// Line 9: SECURITY - Hardcoded password
const PASSWORD = "admin123";

function validateUser(userData) {
    // Line 13: BUGS - Missing input validation
    const email = userData.email;
    
    // Line 16: SECURITY - SQL injection vulnerability  
    const query = `SELECT * FROM users WHERE email = '${email}'`;
    
    // Line 19: BUGS - Potential null pointer
    if (userData.profile.settings.theme === 'dark') {
        console.log('Dark theme enabled');
    }
    
    // Line 24: PERFORMANCE - O(n²) algorithm
    for (let i = 0; i < userData.tags.length; i++) {
        for (let j = 0; j < userData.categories.length; j++) {
            if (userData.tags[i] === userData.categories[j]) {
                console.log('Match found');
            }
        }
    }
    
    // Line 32: CODE QUALITY - Magic number
    const score = userData.rating * 42;
    
    // Line 35: SECURITY - Unsafe eval
    return eval(`(${userData.config})`);
}

// Line 39: CODE QUALITY - Poor function naming
function doStuff(x) {
    return x + 100; // Magic number
}

module.exports = { validateUser, doStuff };