
export const BADGES = [
  // MILESTONE BADGES
  { id: 'first-step', title: 'First Step', emoji: '🥉', desc: 'First topic complete! Welcome to the journey.', requirement: { type: 'count', value: 1 } },
  { id: 'apprentice', title: 'Apprentice', emoji: '📜', desc: '5 topics completed. You are learning fast!', requirement: { type: 'count', value: 5 } },
  { id: 'explorer', title: 'Explorer', emoji: '🥈', desc: '10 topics completed! Getting deep into tech.', requirement: { type: 'count', value: 10 } },
  { id: 'constant', title: 'Constant Learner', emoji: '🧱', desc: '15 topics completed. Building a solid base.', requirement: { type: 'count', value: 15 } },
  { id: 'tech-learner', title: 'Tech Learner', emoji: '🥇', desc: '25 topics completed! Consistency is your name.', requirement: { type: 'count', value: 25 } },
  { id: 'expert', title: 'Expert in Making', emoji: '🎓', desc: '35 topics completed. Almost a pro!', requirement: { type: 'count', value: 35 } },
  { id: 'tech-master', title: 'Tech Master', emoji: '💎', desc: '50 topics completed! You are a beast.', requirement: { type: 'count', value: 50 } },
  { id: 'veteran', title: 'Tech Veteran', emoji: '🛡️', desc: '75 topics completed. Respect.', requirement: { type: 'count', value: 75 } },
  { id: 'centurion', title: 'Centurion', emoji: '💯', desc: '100 topics completed! Legend level.', requirement: { type: 'count', value: 100 } },

  // LEVEL COMPLETION BADGES
  { id: 'internet-graduate', title: 'Net Graduate', emoji: '🌐', desc: 'Completed all Internet Basics (Level 1).', requirement: { type: 'levels', value: [1] } },
  { id: 'web-dev-basics', title: 'Web Architect', emoji: '🏗️', desc: 'Completed all Web Dev Basics (Level 2).', requirement: { type: 'levels', value: [2] } },
  { id: 'database-wizard', title: 'DB Wizard', emoji: '🗄️', desc: 'Completed all Database topics (Level 3).', requirement: { type: 'levels', value: [3] } },
  { id: 'cloud-deployer', title: 'Cloud Deployer', emoji: '☁️', desc: 'Completed all Cloud & Deploy (Level 4).', requirement: { type: 'levels', value: [4] } },
  { id: 'dev-tools-pro', title: 'Tools Pro', emoji: '⚒️', desc: 'Completed all Dev Tools (Level 5).', requirement: { type: 'levels', value: [5] } },
  { id: 'security-expert', title: 'Security Guard', emoji: '🛡️', desc: 'Completed all Security topics (Level 6).', requirement: { type: 'levels', value: [6] } },
  { id: 'ai-master', title: 'AI Master', emoji: '🤖', desc: 'Completed all AI topics (Level 7).', requirement: { type: 'levels', value: [7] } },

  // SPECIALTY BADGES
  { id: 'git-ninja', title: 'Git Ninja', emoji: '🥷', desc: 'Mastered the art of Version Control.', requirement: { type: 'ids', value: ['git-basics', 'git-commit', 'git-branching', 'git-fork'] } },
  { id: 'backend-badass', title: 'Backend Badass', emoji: '⚙️', desc: 'SQL and NoSQL mastered.', requirement: { type: 'ids', value: ['sql-vs-nosql', 'primary-key', 'crud-ops'] } },
  { id: 'ui-visualizer', title: 'UI Visualizer', emoji: '🎨', desc: 'Understand how browsers and UI work.', requirement: { type: 'ids', value: ['frontend-vs-backend', 'browser-loading'] } },
  { id: 'serverless-fan', title: 'Serverless Fan', emoji: '⚡', desc: 'Cloud and Serverless understood.', requirement: { type: 'ids', value: ['deployment-explained', 'serverless-basics'] } },

  // FUN/STREAK BADGES
  { id: 'early-bird', title: 'Early Bird', emoji: '🌅', desc: 'Login before 9 AM.', requirement: { type: 'special', id: 'early' } },
  { id: 'night-owl', title: 'Night Owl', emoji: '🦉', desc: 'Learn after 12 AM.', requirement: { type: 'special', id: 'late' } },
  { id: 'streak-3', title: 'Hot Start', emoji: '🔥', desc: '3-day learning streak.', requirement: { type: 'special', id: 'streak-3' } },
  { id: 'streak-7', title: 'On Fire', emoji: '🧨', desc: '7-day learning streak.', requirement: { type: 'special', id: 'streak-7' } },
  { id: 'streak-30', title: 'Unstoppable', emoji: '🎆', desc: '30-day learning streak.', requirement: { type: 'special', id: 'streak-30' } },

  // RANDOM FUN ONES (To reach near 50)
  { id: 'cookie-monster', title: 'Cookie Monster', emoji: '🍪', desc: 'Read about Cookies & Cache.', requirement: { type: 'ids', value: ['cookies-cache'] } },
  { id: 'locksmith', title: 'Locksmith', emoji: '🔐', desc: 'Read about HTTP vs HTTPS.', requirement: { type: 'ids', value: ['http-vs-https'] } },
  { id: 'api-traveler', title: 'API Traveler', emoji: '🎫', desc: 'Read about JWT and API Keys.', requirement: { type: 'ids', value: ['jwt-auth', 'api-keys-sec'] } },
  { id: 'package-handler', title: 'Package Handler', emoji: '📦', desc: 'Read about npm & Package Managers.', requirement: { type: 'ids', value: ['package-manager'] } },
  { id: 'prompt-pro', title: 'Prompt Pro', emoji: '🪄', desc: 'Read Prompt Engineering topic.', requirement: { type: 'ids', value: ['prompt-engineering'] } },
  { id: 'dictionary-buff', title: 'Dictionary Buff', emoji: '📖', desc: 'Read 20 dictionary terms.', requirement: { type: 'count', value: 20 } },
  { id: 'code-time-traveler', title: 'Time Traveler', emoji: '⏳', desc: 'Read about Git and History.', requirement: { type: 'ids', value: ['git-basics', 'git-commit'] } },
  { id: 'server-shaker', title: 'Server Shaker', emoji: '🖥️', desc: 'Read about Client vs Server.', requirement: { type: 'ids', value: ['client-server'] } },
  { id: 'json-junkie', title: 'JSON Junkie', emoji: '📎', desc: 'Read about JSON basics.', requirement: { type: 'ids', value: ['json-basics'] } },
  { id: 'terminal-pro', title: 'Terminal Pro', emoji: '💻', desc: 'Read about CLI basics.', requirement: { type: 'ids', value: ['cli-basics'] } },
  { id: 'ai-thinker', title: 'AI Thinker', emoji: '🧠', desc: 'Read about LLMs and ML.', requirement: { type: 'ids', value: ['llms-explained', 'machine-learning-simp'] } },
  { id: 'secure-path', title: 'Secure Path', emoji: '🛡️', desc: 'Read about Auth and Security.', requirement: { type: 'ids', value: ['jwt-auth', 'api-keys-sec'] } },
  { id: 'fast-loader', title: 'Fast Loader', emoji: '⚡', desc: 'Read about Browser Loading.', requirement: { type: 'ids', value: ['browser-loading'] } },
  { id: 'fork-master', title: 'Fork Master', emoji: '🍴', desc: 'Read about Git Forking.', requirement: { type: 'ids', value: ['git-fork'] } },
  { id: 'tree-builder', title: 'Tree Builder', emoji: '🌿', desc: 'Read about Git Branching.', requirement: { type: 'ids', value: ['git-branching'] } },
  { id: 'persistent-dev', title: 'Persistent Dev', emoji: '💾', desc: '5 days active login.', requirement: { type: 'special', id: 'days-5' } },
  { id: 'dedicated-pro', title: 'Dedicated Pro', emoji: '🥇', desc: '10 days active login.', requirement: { type: 'special', id: 'days-10' } },
  { id: 'knowledge-king', title: 'Knowledge King', emoji: '👑', desc: 'Reach Level 5.', requirement: { type: 'special', id: 'lvl-5' } },
  { id: 'legendary-dev', title: 'Legendary Dev', emoji: '🤴', desc: 'Reach Level 7.', requirement: { type: 'special', id: 'lvl-7' } },
  { id: 'certificate-earner', title: 'Scholar', emoji: '📜', desc: 'Unlock your first certificate.', requirement: { type: 'special', id: 'cert-1' } },
  { id: 'multitasking', title: 'Multitasker', emoji: '🤹', desc: 'Unlock badges in 3 different categories.', requirement: { type: 'special', id: 'cats-3' } },
  { id: 'share-master', title: 'Social Star', emoji: '🌟', desc: 'Share 5 tech cards.', requirement: { type: 'special', id: 'shares-5' } },
  { id: 'pixel-perfect', title: 'Pixel Perfect', emoji: '✨', desc: 'Explore all the UI topics.', requirement: { type: 'ids', value: ['frontend-vs-backend', 'browser-loading'] } },
  { id: 'data-scientist', title: 'Data Scientist', emoji: '📉', desc: 'Explore all AI and Data topics.', requirement: { type: 'levels', value: [3, 7] } },
  { id: 'marathon', title: 'Marathon Runner', emoji: '🏃', desc: 'Stay for 1 hour learning total.', requirement: { type: 'special', id: 'time-1h' } }
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
