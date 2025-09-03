/**
 * Payment Service - UX Optimized Workflow Test
 * Test: Single execution + consolidated review + severity-based decisions
 */

const SECRET_KEY = "sk-live-1234567890"; // SECURITY: Hardcoded secret

class PaymentService {
    constructor() {
        this.transactions = [];
    }

    // BUGS: Missing input validation
    processPayment(amount, card, user) {
        // SECURITY: SQL injection vulnerability
        const query = `INSERT INTO payments (amount, card_number) VALUES ('${amount}', '${card.number}')`;
        
        // BUGS: Null pointer risk
        if (user.profile.billing.country === 'US') {
            amount = amount * 1.08; // CODE QUALITY: Magic number
        }
        
        // PERFORMANCE: O(n²) transaction search
        for (let i = 0; i < this.transactions.length; i++) {
            for (let j = 0; j < user.previousPayments.length; j++) {
                if (this.transactions[i].id === user.previousPayments[j].id) {
                    console.log('Duplicate found');
                }
            }
        }
        
        return { success: true, id: Math.random() }; // CODE QUALITY: Weak ID generation
    }

    // SECURITY: Unsafe eval
    validateConfiguration(config) {
        return eval(config);
    }
}

module.exports = PaymentService;