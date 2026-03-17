
const { topics } = require('./data/topics.js');

for (let i = 1; i <= 7; i++) {
    const levelTopics = topics.filter(t => t.level === i);
    console.log(`Level ${i}: ${levelTopics.length} topics`);
}
