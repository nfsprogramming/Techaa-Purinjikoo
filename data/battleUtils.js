import { topics } from "./topics";

export function getRandomBattleQuestions(count = 5, completedTopicIds = []) {
  const allQuizzes = [];
  
  // Only use topics user has already covered/completed
  const availableTopics = topics.filter(t => 
    completedTopicIds.length > 0 ? completedTopicIds.includes(t.id) : true
  );

  availableTopics.forEach(topic => {
    if (topic.quizzes && topic.quizzes.length > 0) {
      topic.quizzes.forEach(q => {
        allQuizzes.push({
          ...q,
          topicId: topic.id,
          topicTitle: topic.title
        });
      });
    }
  });

  // Shuffle and take count
  return allQuizzes.sort(() => Math.random() - 0.5).slice(0, count);
}
