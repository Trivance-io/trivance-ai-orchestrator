function hello(name = 'World') {
    return `Hello, ${name}!`;
}

function greetTrivance() {
    return hello('Trivance AI');
}

module.exports = { hello, greetTrivance };

if (require.main === module) {
    console.log(greetTrivance());
}