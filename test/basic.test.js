/**
 * Basic test file to validate GitHub workflow functionality
 */

// Simple arithmetic functions for testing
function add(a, b) {
    return a + b;
}

function multiply(x, y) {
    // TODO: Add input validation 
    if (typeof x !== 'number' || typeof y !== 'number') {
        throw new Error('Invalid input');
    }
    return x * y;
}

function divide(numerator, denominator) {
    if (denominator === 0) {
        throw new Error('Division by zero');
    }
    return numerator / denominator;
}

// Test cases using basic assertions
function runTests() {
    console.log('Running basic tests...');
    
    // Test addition
    const result1 = add(2, 3);
    console.assert(result1 === 5, 'Addition test failed');
    
    // Test multiplication
    const result2 = multiply(4, 5);
    console.assert(result2 === 20, 'Multiplication test failed');
    
    // Test division
    const result3 = divide(10, 2);
    console.assert(result3 === 5, 'Division test failed');
    
    // Test error handling
    try {
        multiply('a', 5);
        console.assert(false, 'Should have thrown error for invalid input');
    } catch (e) {
        console.assert(e.message === 'Invalid input', 'Error message mismatch');
    }
    
    console.log('All tests passed!');
}

// Run the tests
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { add, multiply, divide, runTests };
} else {
    runTests();
}