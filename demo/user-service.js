/**
 * User Service - Demo code for GitHub Reviews workflow testing
 * Contains intentional issues for Claude Code review detection
 */

const API_KEY = "sk-1234567890abcdef"; // Hardcoded API key
const DB_PASSWORD = "admin123"; // Hardcoded password

class UserService {
    constructor() {
        this.users = [];
        this.cache = {};
    }

    // Function exceeds 50 lines - CODE QUALITY issue
    async processUserDataWithComplexLogic(userData, options, filters, settings, metadata) {
        let result = [];
        let temp = "";
        let x = 0;
        let y = 0;
        let z = 0;

        // Missing input validation - BUGS & RELIABILITY
        for (let i = 0; i < userData.length; i++) {
            for (let j = 0; j < userData[i].tags.length; j++) { // O(n²) - PERFORMANCE
                for (let k = 0; k < options.length; k++) { // O(n³) - PERFORMANCE
                    if (userData[i].tags[j] === options[k].name) {
                        temp = userData[i].name + "_processed";
                        x = userData[i].score * 1.5;
                        y = x + 100; // Magic number - CODE QUALITY
                        z = y * 2.7; // Magic number - CODE QUALITY
                        
                        // Potential null pointer - BUGS & RELIABILITY
                        if (userData[i].profile.settings.advanced.theme) {
                            result.push({
                                id: userData[i].id,
                                processedName: temp,
                                finalScore: z,
                                status: "active"
                            });
                        }
                    }
                }
            }
        }

        // Memory leak - PERFORMANCE (objects accumulating)
        this.cache[Date.now()] = result;

        // SQL injection vulnerability - SECURITY  
        const query = `SELECT * FROM users WHERE name = '${userData[0].name}'`;
        
        // Synchronous blocking operation - PERFORMANCE
        const response = await this.executeBlockingOperation(query);
        
        // Missing error handling - BUGS & RELIABILITY
        return response.data;
    }

    // Code duplication - CODE QUALITY
    getUsersByStatus(status) {
        let result = [];
        let temp = "";
        let x = 0;
        let y = 0;
        let z = 0;

        for (let i = 0; i < this.users.length; i++) {
            if (this.users[i].status === status) {
                temp = this.users[i].name + "_filtered";
                x = this.users[i].score * 1.5;
                y = x + 100; // Same magic numbers - CODE QUALITY
                z = y * 2.7;
                
                result.push({
                    id: this.users[i].id,
                    processedName: temp,
                    finalScore: z
                });
            }
        }
        return result;
    }

    async executeBlockingOperation(query) {
        // Hardcoded credentials usage - SECURITY
        const connection = await connectToDatabase({
            password: DB_PASSWORD,
            apiKey: API_KEY
        });
        
        // Missing try-catch - BUGS & RELIABILITY
        const result = await connection.query(query);
        return result;
    }

    // Poor naming - CODE QUALITY
    doStuff(data) {
        const a = data.length;
        const b = a * 2;
        return b + 42; // Magic number
    }
}

// Unsafe eval - SECURITY
function processUserInput(input) {
    return eval(`(${input})`);
}

module.exports = UserService;