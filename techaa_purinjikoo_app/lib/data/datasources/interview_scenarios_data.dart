class InterviewChoice {
  final String label;
  final String text;
  final bool isCorrect;
  final String feedback;

  const InterviewChoice({
    required this.label,
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}

class InterviewScenario {
  final String id;
  final String category;
  final String question;
  final String interviewerNote;
  final List<InterviewChoice> choices;
  final int xpReward;

  const InterviewScenario({
    required this.id,
    required this.category,
    required this.question,
    required this.interviewerNote,
    required this.choices,
    this.xpReward = 30,
  });
}

class InterviewScenariosData {
  static List<InterviewScenario> getScenarios() {
    return [
      const InterviewScenario(
        id: 'sc_intro',
        category: 'HR & First Impression',
        question: '“Tell me about yourself.”',
        interviewerNote: 'Interviewer checks your communication clarity, passion, and relevance in 90 seconds.',
        choices: [
          InterviewChoice(
            label: 'School Bio ❌',
            text: 'En name Karthik. Naan Chennai-la 10th-la 92%, 12th-la 88% eduthen. Family-la 4 members irukom. Hobbies playing cricket...',
            isCorrect: false,
            feedback: 'Adei! Resume-la irukkura school mark-ah paadaathae. Recruiter wants to know what tech you build and why you fit this role!',
          ),
          InterviewChoice(
            label: 'Slacker ❌',
            text: 'Sir naan fresh graduate. Neenga enna project kuduthalum padichu panren sir... please job kudunga.',
            isCorrect: false,
            feedback: 'Begging never works! Show confidence and proof of work you already built.',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: 'I am a Full Stack Developer specializing in Flutter and Node.js. Recently I built a live food delivery tracker serving 500 college users, optimizing API latency by 40% using Redis. I love solving scaling challenges and want to contribute to your engineering squad!',
            isCorrect: true,
            feedback: 'Semma! Name + Tech Stack + Real Deployed Project + Measurable Impact + Company Value in 90 seconds!',
          ),
        ],
      ),

      const InterviewScenario(
        id: 'sc_db_choice',
        category: 'Technical Architecture',
        question: '“Why did you choose PostgreSQL instead of MongoDB for your project?”',
        interviewerNote: 'Interviewer wants to see if you understand ACID compliance vs flexible schemas.',
        choices: [
          InterviewChoice(
            label: 'Bookish Jargon ❌',
            text: 'Because PostgreSQL is a Relational Database Management System with Edgar F. Codd 12 rules and ACID compliance.',
            isCorrect: false,
            feedback: 'Definition mattum sonna pathadhu! Un project-ku adhu yen theva pattuchunu explain pannanum.',
          ),
          InterviewChoice(
            label: 'Blind Choice ❌',
            text: 'YouTube tutorial-la PostgreSQL use pannanga bro... adhan naanum install pannen.',
            isCorrect: false,
            feedback: 'Tutorial copier mindset! Interviewers reject candidates who don\'t know why they chose a tool.',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: 'Namma app-la User Accounts, Orders, and Payment Transactions irukku. Strict Foreign Key relationships thevai to prevent duplicate charges and orphan orders. MongoDB-la schema loose-ah irukkum, but PostgreSQL ensures data integrity with ACID transactions!',
            isCorrect: true,
            feedback: 'Kattura da! Clear trade-off analysis between business logic and database architecture.',
          ),
        ],
      ),

      const InterviewScenario(
        id: 'sc_redis',
        category: 'System Design & Performance',
        question: '“Why does your application need Redis caching when you already have PostgreSQL?”',
        interviewerNote: 'Checking if you understand database load, disk I/O, and sub-10ms response times.',
        choices: [
          InterviewChoice(
            label: 'Textbook ❌',
            text: 'Redis is an in-memory key-value data structure store used as a database, cache, and message broker.',
            isCorrect: false,
            feedback: 'Google search definition solladha! Real performance benefit-ah explain pannu.',
          ),
          InterviewChoice(
            label: 'Confused ❌',
            text: 'PostgreSQL slow-ah irundhuchu, adhan total-ah Redis-ku switch pannitom.',
            isCorrect: false,
            feedback: 'Danger! Redis RAM-la irukkum; power off aana data poirum. Redis is a cache layer, not primary DB replacement!',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: 'PostgreSQL disk-la irundhu read pannuthu, so 10,000 users same home page hit panna DB CPU 100% spike aagum. Redis keeps trending data in RAM with 60-second TTL, dropping API latency from 450ms to 8ms!',
            isCorrect: true,
            feedback: 'Super da! Disk I/O vs RAM speed + TTL cache invalidation metrics sonnadhu recruiter-ku romba pudikkum.',
          ),
        ],
      ),

      const InterviewScenario(
        id: 'sc_docker',
        category: 'DevOps & Tooling',
        question: '“Docker use panni un project-la enna advantage kedaichudhu?”',
        interviewerNote: 'Testing developer environment hygiene and deployment consistency.',
        choices: [
          InterviewChoice(
            label: 'Slacker ❌',
            text: 'Docker whale logo nallarkum nu install pannen bro.',
            isCorrect: false,
            feedback: 'Adei comedy pannadha 😂',
          ),
          InterviewChoice(
            label: 'Textbook ❌',
            text: 'Docker provides OS-level virtualization to deliver software in packages called containers.',
            isCorrect: false,
            feedback: 'Correct definition, but where is your personal project experience?',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: 'En teammate laptop-la Node 18, en laptop-la Node 20 irundhadhala code crash aachu. Docker container-la Node + Postgres + Redis bundle panni `docker-compose up` potta udane, new teammate onboarding 5 minutes-la ready aachu!',
            isCorrect: true,
            feedback: 'Pinrita! "It works on my machine" problem-ku real solution explain pannita.',
          ),
        ],
      ),

      const InterviewScenario(
        id: 'sc_conflict',
        category: 'Git & Teamwork',
        question: '“Git-la merge conflict vantha epdi handle pannuve?”',
        interviewerNote: 'Checking team collaboration and version control conflict resolution.',
        choices: [
          InterviewChoice(
            label: 'Scared ❌',
            text: 'Conflict vantha repo-va delete pannitu marupadiyum clone panniduven bro.',
            isCorrect: false,
            feedback: 'Ha ha never do this in a company! You will lose your team\'s uncommitted work!',
          ),
          InterviewChoice(
            label: 'Careless ❌',
            text: 'Force push `git push -f` panni en code-ah override panniduven.',
            isCorrect: false,
            feedback: 'Massive red flag! Force push will delete your teammates\' production code!',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: '`git pull origin main` panni, VS Code merge editor-la incoming vs current changes line-by-line compare pannuven. Teammate kitta discuss panni conflict markers (`<<<<<<<`) clean panni, tests run panni aprom dhaan commit pannuven!',
            isCorrect: true,
            feedback: 'Flawless! Responsible engineer behavior that ensures zero code regression.',
          ),
        ],
      ),

      const InterviewScenario(
        id: 'sc_hire_you',
        category: 'HR & Value Proposition',
        question: '“Why should we hire you instead of other candidates with 9+ CGPA?”',
        interviewerNote: 'Evaluating practical capability, drive, and real builder mindset.',
        choices: [
          InterviewChoice(
            label: 'Arrogant ❌',
            text: 'Because toppers don\'t know coding sir, naan dhaan top hacker.',
            isCorrect: false,
            feedback: 'Never pull others down to lift yourself up. Show professional humility.',
          ),
          InterviewChoice(
            label: 'Slacker ❌',
            text: 'Enakku money thevai sir, romba kashtathula irukken...',
            isCorrect: false,
            feedback: 'Companies hire for value and skills, not charity.',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: 'CGPA shows academic consistency, but my GitHub shows proof of shipping. I have 2 live deployed full-stack products, contributed to open source, and can ship features from Day 1 with zero ramp-up time!',
            isCorrect: true,
            feedback: 'Gethu! Proof of work + immediate business value is the #1 hiring signal.',
          ),
        ],
      ),

      const InterviewScenario(
        id: 'sc_ai_tools_usage',
        category: 'Modern Engineering & AI',
        question: '“Do you use AI coding assistants like GitHub Copilot or Cursor while building software?”',
        interviewerNote: 'Checking if you use AI as a productivity multiplier vs relying on it blindly without understanding.',
        choices: [
          InterviewChoice(
            label: 'Outdated Denial ❌',
            text: 'No sir, AI use panna cheating sir. Naan only notepad-la pure memory vechu code ezhuthuven.',
            isCorrect: false,
            feedback: 'Companies want high productivity! Rejecting modern developer tools makes you 3x slower than modern engineers.',
          ),
          InterviewChoice(
            label: 'Blind Copy-Paster ❌',
            text: 'Yes sir, ChatGPT / Cursor kitta full code prompt panni copy-paste panniduven. Syntax padikave theva illa.',
            isCorrect: false,
            feedback: 'Immediate rejection! If you cannot explain edge cases or fix bugs without AI, you cannot be trusted with production systems.',
          ),
          InterviewChoice(
            label: 'Techaa Pro ✅',
            text: 'Yes, I actively use Cursor and Copilot to accelerate boilerplate code, generate unit test edge cases, and debug stack traces. However, I own the architecture, database normalization, and security audits — ensuring every AI diff is reviewed before merge!',
            isCorrect: true,
            feedback: 'Semma! The exact answer top engineering managers want to hear in 2026: AI as a co-pilot with human architectural ownership.',
          ),
        ],
      ),
    ];
  }
}
