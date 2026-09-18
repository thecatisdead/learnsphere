# LearnSphere

**LearnSphere** is an AI-powered study application built with Flutter that turns PDF learning materials into interactive study resources.

Users can upload PDF materials, generate AI summaries, quizzes, and flashcards, chat with their documents using a Retrieval-Augmented Generation (RAG) pipeline, organize study materials, and maintain persistent chat and study data locally.

> Built as a personal project to explore Flutter application development, AI integration, RAG, local persistence, API integration, and automation-oriented software development.

---

## Features

### PDF Study Materials

* Upload PDF learning materials
* Extract text directly from PDF files
* Track uploaded documents locally
* Detect documents using content hashing
* Maintain a collection of study materials
* Open previously uploaded materials without re-uploading them

### AI Summary Generation

LearnSphere can generate summaries from uploaded PDF content.

The application:

1. Extracts the PDF text
2. Splits the text into manageable chunks
3. Sends each chunk to the AI backend
4. Generates a summary for each chunk
5. Combines the generated summaries
6. Saves the result locally

Generated summaries are stored in SQLite so they remain available after navigating between screens.

### AI Quiz Generation

LearnSphere can generate quizzes from uploaded study materials.

The quiz generation pipeline:

```text
PDF
 ↓
Text Extraction
 ↓
Text Chunking
 ↓
AI Generation
 ↓
Question Parsing
 ↓
SQLite
 ↓
Riverpod
 ↓
Quiz UI
```

Generated questions are converted into application models and stored locally for later access.

### AI Flashcards

Users can generate flashcards from their PDF materials.

Generated flashcards are:

* Parsed into application models
* Stored in SQLite
* Loaded into Riverpod for immediate access
* Associated with the corresponding document

### AI PDF Chat

LearnSphere includes a ChatGPT-style interface for asking questions about uploaded PDFs.

Users can:

* Select a PDF
* Start a conversation about the document
* Create multiple conversations for the same PDF
* Navigate between previous conversations
* Continue conversations without losing their in-memory state
* Persist messages to SQLite

The chat system keeps conversations associated with their respective documents.

### Retrieval-Augmented Generation

The PDF chat system uses a RAG architecture rather than sending the entire document directly to the AI model.

The general pipeline is:

```text
PDF
 ↓
Text Extraction
 ↓
Chunking
 ↓
Embedding Generation
 ↓
Vector Storage
 ↓
User Question
 ↓
Relevant Chunk Retrieval
 ↓
Context + Question
 ↓
Gemini
 ↓
AI Response
```

The backend uses:

* Cloudflare Workers
* Cloudflare Workers AI
* Cloudflare Vectorize
* Embeddings
* Gemini API

Document metadata such as the filename, chunk index, and chunk text is associated with stored vectors.

Chat requests are filtered using the selected document so retrieved context comes from the appropriate PDF.

### Persistent Chat History

Chat sessions are stored locally using SQLite/Drift.

The database stores information including:

```text
Document
 ├── Chat Session
 │    ├── User Message
 │    ├── AI Message
 │    ├── User Message
 │    └── AI Message
```

This allows users to leave the chat screen and return later without losing their previous conversations.

Chat state is also maintained in Riverpod while the application is running, reducing unnecessary database reads during navigation.

### Study Planner

LearnSphere includes a study planner where users can add existing uploaded PDFs as upcoming study tasks.

Selecting a planned study material opens the corresponding study material screen.

### Local Persistence

LearnSphere uses SQLite through Drift for persistent application data.

The database is responsible for storing data such as:

* Documents
* Chat sessions
* Chat messages
* Summaries
* Quizzes
* Flashcards
* Planner-related data

Riverpod is used as the application's in-memory state layer.

This gives the application two levels of state:

```text
SQLite / Drift
      ↓
Persistent State
      ↓
Riverpod
      ↓
Runtime State
      ↓
Flutter UI
```

### Error Handling

AI generation requests include handling for common failures such as:

* No internet connection
* Request timeouts
* HTTP 429 rate limits
* HTTP 500 server errors
* HTTP 502/503 server availability errors
* General request failures

Errors are converted into user-friendly messages instead of exposing raw backend errors directly.

Example:

```text
NO_INTERNET
    ↓
"No internet connection. Please check your network."
```

```text
429
    ↓
"Rate limit reached. Please try again later."
```

```text
500 / 502 / 503
    ↓
"The AI server is temporarily unavailable. Please try again."
```

---

## Architecture

LearnSphere follows a layered architecture built around Flutter, Riverpod, local persistence, and a remote AI backend.

```text
                    Flutter UI
                       │
                       ▼
                  Riverpod State
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
    Local Database              AI Services
     SQLite / Drift                  │
          │                          ▼
          │                  Cloudflare Worker
          │                          │
          │              ┌───────────┼───────────┐
          │              ▼           ▼           ▼
          │          Vectorize   Workers AI   Gemini
          │
          ▼
     Persistent Data
```

---

## Tech Stack

### Frontend

* Flutter
* Dart
* Material 3
* Riverpod

### Local Database

* SQLite
* Drift

### AI / Backend

* Cloudflare Workers
* Cloudflare Workers AI
* Cloudflare Vectorize
* Gemini API
* REST APIs
* Retrieval-Augmented Generation (RAG)

### Document Processing

* PDF text extraction
* SHA-256 content hashing
* Text chunking

### Development

* Git
* GitHub
* Linux
* VS Code

---

## Project Structure

The project is organized into separate layers for screens, providers, services, database access, models, and shared UI components.

```text
lib/
├── app/
│   └── main_navigation.dart
│
├── database/
│   ├── app_database.dart
│   ├── database_provider.dart
│   ├── document_repository.dart
│   └── chat_repository.dart
│
├── models/
│   ├── chat_message.dart
│   ├── chat_session.dart
│   ├── flashcard.dart
│   ├── flashcarddeck.dart
│   ├── question.dart
│   ├── quiz.dart
│   ├── study_session.dart
│   └── summary.dart
│
├── providers/
│   ├── ai_loading_provider.dart
│   ├── ai_material_provider.dart
│   ├── chat_session_provider.dart
│   ├── document_provider.dart
│   ├── flashcard_provider.dart
│   ├── pdf_text_provider.dart
│   ├── quiz_provider.dart
│   ├── study_session_provider.dart
│   └── summary_provider.dart
│
├── screens/
│   ├── ai/
│   ├── chat/
│   ├── planner/
│   └── study_material/
│
├── services/
│   ├── ai_service.dart
│   └── error_service.dart
│
└── shared/
    └── widgets/
```

---

## AI Generation Flow

AI-generated study materials follow a common processing pattern.

### Summary

```text
PDF
 ↓
Extract Text
 ↓
Split Into Chunks
 ↓
Generate Summary Per Chunk
 ↓
Combine Summaries
 ↓
Save to SQLite
 ↓
Update Riverpod
 ↓
Display
```

### Quiz

```text
PDF
 ↓
Extract Text
 ↓
Split Into Chunks
 ↓
Generate Questions
 ↓
Parse JSON
 ↓
Create Question Models
 ↓
Save Quiz to SQLite
 ↓
Update Riverpod
 ↓
Display Quiz
```

### Flashcards

```text
PDF
 ↓
Extract Text
 ↓
Split Into Chunks
 ↓
Generate Flashcards
 ↓
Parse JSON
 ↓
Create Flashcard Models
 ↓
Save to SQLite
 ↓
Update Riverpod
 ↓
Display Flashcards
```

---

## State Management

Riverpod manages runtime application state.

For example, AI generation maintains independent states for:

```text
Summary
 ├── idle
 ├── generating
 ├── ready
 └── error

Quiz
 ├── idle
 ├── generating
 ├── ready
 └── error

Flashcards
 ├── idle
 ├── generating
 ├── ready
 └── error
```

This allows the UI to independently display loading and error states for each AI generation task.

The selected PDF is also associated with the AI generation state so that state belonging to one document does not accidentally appear for another document.

---

## Chat State

Chat state is divided between persistent storage and runtime state.

### While the application is running

Riverpod keeps loaded chat sessions in memory.

```text
SQLite
   ↓
ChatSessionProvider
   ↓
StudyChatScreen
```

When the user navigates away from the chat screen, the Riverpod state remains available while the application is running.

Returning to the chat can therefore restore the existing runtime state without reconstructing the entire conversation from scratch.

### After closing the application

SQLite becomes the source of persistent chat data.

When the application starts again:

```text
SQLite
 ↓
Load chat sessions
 ↓
Riverpod
 ↓
Chat UI
```

This allows previous conversations to be recovered after restarting the application.

---

## Document Identity

Uploaded PDFs use SHA-256 content hashing to identify document contents.

The general process is:

```text
PDF
 ↓
SHA-256
 ↓
Content Hash
 ↓
Find Existing Document
        │
   ┌────┴────┐
   │         │
 Exists    New
   │         │
   ▼         ▼
Reuse     Create
Document  Document
```

This helps distinguish documents based on their actual file contents rather than relying only on filenames.

---

## API Communication

The Flutter application communicates with the backend through HTTP requests.

The AI service centralizes requests such as:

```text
/quiz
/summary
/flashcards
/chat
/index-pdf
```

Requests use JSON payloads and responses are converted into strongly typed Dart models.

A shared request handler is used for common HTTP error handling, including timeout, network, rate-limit, and server errors.

---

## UI

LearnSphere uses Flutter's Material 3 components and supports both:

* Light mode
* Dark mode

UI state is dynamically adapted to the active theme so text, cards, icons, and other components remain readable in both modes.

---

## Getting Started

### Prerequisites

You will need:

* Flutter SDK
* Dart SDK
* Android SDK or another supported Flutter platform
* Git

### Clone the Repository

```bash
git clone <repository-url>
cd learnsphere
```

### Install Dependencies

```bash
flutter pub get
```

### Generate Drift Files

If database code generation is required:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the Application

```bash
flutter run
```

---

## Backend

LearnSphere requires a backend for AI-powered functionality.

The backend is responsible for:

* Receiving PDF chunks
* Generating embeddings
* Indexing document content
* Retrieving relevant document context
* Generating summaries
* Generating quizzes
* Generating flashcards
* Generating AI chat responses

The Flutter application communicates with the backend through REST endpoints.

---

## Security Notes

API secrets should **not** be stored directly in the Flutter application.

Sensitive AI credentials are handled on the backend rather than being embedded into the client application.

For local development, environment-specific configuration should be kept outside version control.

---

## Current Limitations

LearnSphere is still an actively developed project.

Current limitations may include:

* AI generation depends on network connectivity.
* AI generation is subject to API rate limits.
* Large documents require multiple AI requests because text is processed in chunks.
* AI-generated content depends on the quality and structure of the source material.
* Vector retrieval quality depends on the generated embeddings and retrieved context.
* The application currently focuses primarily on PDF-based study materials.

---

## Future Improvements

Potential future improvements include:

* User authentication
* Cloud synchronization
* Cross-device chat synchronization
* More advanced planner functionality
* Improved RAG retrieval and ranking
* More configurable quiz generation
* Study progress tracking
* Automated testing
* Better offline support
* Additional document formats
* More detailed AI generation progress
* Improved database synchronization

---

## Why I Built This

LearnSphere started as a project for experimenting with Flutter and AI integration and evolved into a larger application involving several areas of software development.

The project allowed me to work with:

* Flutter application architecture
* State management
* Local databases
* REST APIs
* AI APIs
* RAG
* Vector databases
* Document processing
* Persistent chat systems
* Error handling
* Asynchronous programming
* UI/UX
* Git and GitHub

Rather than building a simple AI wrapper, the goal was to build an application where AI functionality is integrated into an actual persistent application architecture.

##

Built with Flutter, Dart, SQLite, Cloudflare, and AI technologies.
