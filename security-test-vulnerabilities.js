/**
 * SECURITY TEST FILE - Contains intentional vulnerabilities for testing Claude Security Review
 * THIS FILE IS FOR TESTING ONLY - DO NOT USE IN PRODUCTION
 */

// VULNERABILITY 1: Hardcoded API Keys and Secrets
const API_SECRET = "sk-1234567890abcdef-HARDCODED-SECRET";
const DATABASE_PASSWORD = "super_secret_password_123";
const JWT_SECRET = "my-jwt-secret-key";

// VULNERABILITY 2: SQL Injection
function authenticateUser(username, password) {
    const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
    return database.query(query);
}

// VULNERABILITY 3: Command Injection
function executeCommand(userInput) {
    const command = `ls -la ${userInput}`;
    return require('child_process').exec(command);
}

// VULNERABILITY 4: XSS Vulnerability
function renderUserContent(userContent) {
    document.innerHTML = `<div>${userContent}</div>`; // Direct insertion without sanitization
}

// VULNERABILITY 5: Insecure Random Generation
function generateToken() {
    return Math.random().toString(36).substr(2, 9); // Weak randomness
}

// VULNERABILITY 6: Weak Cryptography
const crypto = require('crypto');
function weakEncryption(data) {
    const cipher = crypto.createCipher('des', 'weak-key'); // DES is deprecated and weak
    return cipher.update(data, 'utf8', 'hex') + cipher.final('hex');
}

// VULNERABILITY 7: Information Disclosure
function debugLog(error, userEmail) {
    console.log(`Error occurred for user ${userEmail}: ${error.stack}`); // Logs sensitive info
}

// VULNERABILITY 8: Insecure File Operations
function readUserFile(filename) {
    const fs = require('fs');
    return fs.readFileSync(`/uploads/${filename}`); // Path traversal vulnerability
}

// VULNERABILITY 9: Prototype Pollution
function merge(target, source) {
    for (let key in source) {
        target[key] = source[key]; // No prototype protection
    }
    return target;
}

// VULNERABILITY 10: LDAP Injection
function findUserByName(name) {
    const filter = `(cn=${name})`; // LDAP injection possible
    return ldapClient.search('ou=users,dc=company,dc=com', { filter });
}

module.exports = {
    authenticateUser,
    executeCommand,
    renderUserContent,
    generateToken,
    weakEncryption,
    debugLog,
    readUserFile,
    merge,
    findUserByName
};