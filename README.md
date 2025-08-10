RULES
#### THIS IS A FEATURE FIRST ARCHITURE, WE BUILD EACH FEATURE AND DEPLOY AS BRANCHES 

# QuizSnap

QuizSnap is an AI-powered quiz generation and gameplay app that allows users to upload documents and automatically generate multiple-choice questions (MCQs). Users can play quizzes solo or challenge friends in real-time multiplayer rooms.  
The app is designed for students, teachers, and professionals who want a fast, engaging way to revise or test knowledge from any document.

---

## Goals & Objectives
- Upload documents in various formats (PDF, Word, Images with OCR).
- Automatically generate high-quality MCQs from the uploaded content.
- Provide both solo and multiplayer quiz modes.
- Offer smooth, real-time multiplayer gameplay.
- Ensure secure storage and management of user data and files.

---

## Tech Stack
**Frontend:** Flutter (Riverpod for state management)  
**Backend & Realtime:** Supabase (Auth, Storage, Database, Realtime)  
**AI Processing:** External AI API for question generation  
**Design:** Responsive with `flutter_screenutil`, `google_fonts`

---

## Folder Structure
lib/
├── core/
│ ├── constants/
│ ├── routes/
│ ├── services/
│ ├── utils/
│ └── theme/
├── features/
│ ├── auth/
│ │ ├── models/
│ │ ├── provider/
│ │ └── ui/
│ ├── onboarding/
│ │ ├── models/
│ │ ├── provider/
│ │ └── ui/
│ ├── upload/
│ │ ├── models/
│ │ ├── provider/
│ │ └── ui/
│ ├── solo_quiz/
│ ├── multiplayer/
│ ├── profile/
├── main.dart
 
---

## MVP Screens
1. **Onboarding Screen** – First-time intro and call-to-action.
2. **Auth Screen** – Email/password sign in and sign up.
3. **Home/Dashboard Screen** – Upload documents, quick links to solo/multiplayer.
4. **Upload & Generate Screen** – Pick file, upload progress, MCQ preview.
5. **Solo Quiz Screen** – Timed questions, navigation, results summary.
6. **Multiplayer Lobby Screen** – Create/join rooms, see players.
7. **Multiplayer Quiz Screen** – Live play with scoreboard.


## Installation & Setup
1. Clone the repository:   git clone "repo link"
2. Go to directory: cd quizsnap
3. Install dependencies: flutter pub get

RULES
#### THIS IS A FEATURE FIRST ARCHITURE, WE BUILD EACH FEATURE AND DEPLOY AS BRANCHES 
