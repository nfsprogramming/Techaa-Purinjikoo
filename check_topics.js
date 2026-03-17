
const fs = require('fs');
const path = require('path');

const content = fs.readFileSync('e:\\Techaa Purinjikoo\\techah-purinjiko\\data\\topics.js', 'utf8');

// Use a regex to extract the topics array
// This regex will capture the ID and the conversation block
const regex = /id:\s*"([^"]+)"[\s\S]*?conversation:\s*\[([\s\S]*?)\]/g;
let match;
let count = 0;
let shortConvo = [];

while ((match = regex.exec(content)) !== null) {
    const id = match[1];
    const convoContent = match[2];
    // Count the number of { speaker: ... } objects
    const msgCount = (convoContent.match(/speaker:/g) || []).length;
    if (msgCount < 5) {
        shortConvo.push({ id, length: msgCount, index: count });
    }
    count++;
}

console.log(`Total topics found: ${count}`);
console.log(`Topics with < 5 messages: ${shortConvo.length}`);
shortConvo.forEach(s => {
    console.log(`ID: ${s.id}, Length: ${s.length}, Index: ${s.index}`);
});
