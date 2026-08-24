
export const BADGES = [
  {
    id: 'first-step',
    title: 'First Step',
    emoji: '🥉',
    desc: 'First topic complete! Welcome to the journey.',
    requirement: { type: 'count', value: 1 }
  },
  {
    id: 'explorer',
    title: 'Explorer',
    emoji: '🥈',
    desc: '10 topics completed! You are getting deep into tech.',
    requirement: { type: 'count', value: 10 }
  },
  {
    id: 'tech-learner',
    title: 'Tech Learner',
    emoji: '🥇',
    desc: '25 topics completed! Consistency is your middle name.',
    requirement: { type: 'count', value: 25 }
  },
  {
    id: 'tech-master',
    title: 'Tech Master',
    emoji: '💎',
    desc: '50 topics completed! You are now a knowledge beast.',
    requirement: { type: 'count', value: 50 }
  },
  {
    id: 'centurion',
    title: 'Centurion',
    emoji: '💯',
    desc: '100 topics completed! Legend level reached.',
    requirement: { type: 'count', value: 100 }
  },
  {
    id: 'web-basics',
    title: 'Web Basics',
    emoji: '🌐',
    desc: 'All Level 1 & 2 basics topics completed.',
    requirement: { type: 'levels', value: [1, 2] }
  },
  {
    id: 'deployment-master',
    title: 'Deployment Master',
    emoji: '🚀',
    desc: 'All Level 4 hosting topics completed.',
    requirement: { type: 'levels', value: [4] }
  },
  {
    id: 'ai-beginner',
    title: 'AI Beginner',
    emoji: '🤖',
    desc: 'All Level 7 AI topics completed.',
    requirement: { type: 'levels', value: [7] }
  },
  {
    id: 'git-master',
    title: 'Git Master',
    emoji: '🧑‍💻',
    desc: 'Specific Git tools completed.',
    requirement: { type: 'ids', value: ['git-basics', 'github-basics', 'git-commit', 'git-branch'] }
  },
  {
    id: 'night-owl',
    title: 'Night Owl',
    emoji: '🦉',
    desc: 'Learn after 12 AM.',
    requirement: { type: 'time', value: '00-05' }
  }
];

export const XP_LEVELS = [
  { level: 1, name: 'Curious Beginner', minXP: 0 },
  { level: 2, name: 'Tech Explorer', minXP: 200 },
  { level: 3, name: 'Developer', minXP: 500 },
  { level: 4, name: 'Tech Pro', minXP: 1000 },
  { level: 5, name: 'Tech Architect', minXP: 2500 },
  { level: 6, name: 'CTO Level', minXP: 5000 },
  { level: 7, name: 'Tech Legend', minXP: 10000 },
];

export const XP_AWARDS = {
  READ_TOPIC: 10,
  QUIZ_CORRECT: 20,
  DAILY_LOGIN: 5,
  SHARE_TOPIC: 15
};
