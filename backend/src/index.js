import { GoogleGenAI } from "@google/genai";

export default {
	async fetch(request, env) {
		if (request.method !== "POST") {
			return new Response("Method Not Allowed", {
				status: 405,
			});
		}

		const url = new URL(request.url);

		try {
			const body = await request.json();

			const ai = new GoogleGenAI({
				apiKey: env.GEMINI_API_KEY,
			});

			// =========================
			// CHAT
			// =========================
			if (url.pathname === "/chat") {
				const question = body.question;
				const context = body.context ?? "";

				if (!question) {
					return Response.json(
						{ error: "Question is required." },
						{ status: 400 }
					);
				}

				const prompt = `
You are an AI study assistant.

Answer the user's question using ONLY the information contained in the provided study material.

Rules:
- Do not use outside knowledge.
- If the answer cannot be found in the study material, say:
  "I couldn't find the answer in the provided study material."
- Be clear and concise.
- Explain the answer in a way that helps the student understand it.
- At every end of your respond add this a_c put this at the very bottom right. 

DOCUMENT SECTION:
${context}

USER QUESTION:
${question}
`;

				const response = await ai.models.generateContent({
					model: "gemini-3.5-flash-lite",
					contents: prompt,
				});

				return Response.json({
					answer: response.text,
				});
			}

			// =========================
			// QUIZ
			// =========================
			if (url.pathname === "/quiz") {
				const chunk = body.chunk;
				const questionsForThisChunk =
					body.questionsForThisChunk;

				if (!chunk) {
					return Response.json(
						{ error: "Chunk is required." },
						{ status: 400 }
					);
				}

				const prompt = `
You are an AI that generates study quizzes.

Based on the following document, generate exactly ${questionsForThisChunk} multiple-choice questions.

Rules:
- Return ONLY valid JSON.
- Do NOT use markdown.
- Do NOT explain anything.
- Each question must have exactly 4 options.
- Only one option is correct.
- The correctAnswer must exactly match one option.

Return this format:

[
  {
    "question": "...",
    "options": [
      "...",
      "...",
      "...",
      "..."
    ],
    "correctAnswer": "..."
  }
]

Document:

${chunk}
`;

				const response = await ai.models.generateContent({
					model: "gemini-3.5-flash-lite",
					contents: prompt,
				});

				const text = response.text ?? "[]";

				let questions;

				try {
					questions = JSON.parse(text);
				} catch (e) {
					console.error("QUIZ JSON ERROR:", text);

					return Response.json(
						{
							error: "Gemini returned invalid JSON.",
							raw: text,
						},
						{ status: 500 }
					);
				}

				return Response.json({
					questions: questions,
				});
			}

			if (url.pathname === "/summary") {


				const context = body.context ?? "";

				if (!context) {
					return Response.json(
						{ error: "Context is required." },
						{ status: 400 }
					);
				}

				const prompt = `
You are an expert study assistant.

Summarize the following study material into concise bullet points.

Rules:
- Focus on the important concepts.
- Keep the summary clear and useful for studying.
- Do not invent information that is not present in the study material.
- Use concise bullet points.

STUDY MATERIAL:
${context}
`;

				const ai = new GoogleGenAI({
					apiKey: env.GEMINI_API_KEY,
				});

				const response = await ai.models.generateContent({
					model: "gemini-3.5-flash-lite",
					contents: prompt,
				});

				return Response.json({
					summary: response.text,
				});
			}


			if (url.pathname === "/flashcards") {
				const context = body.context ?? "";

				if (!context) {
					return Response.json(
						{ error: "Context is required." },
						{ status: 400 }
					);
				}

				const prompt = `
You are an AI study assistant that creates high-quality flashcards from study material.

Your goal is to identify the key concepts in the provided section and turn them into useful flashcards for studying.

Rules:

- Return ONLY valid JSON.
- Do NOT use markdown.
- Do NOT explain anything outside the JSON.
- Each flashcard must contain exactly:
  - "front"
  - "back"
- Keep the front short and clear.
- Keep the back concise but complete enough to understand the concept.
- Cover the major concepts found in this section.
- Prioritize:
  - Important definitions
  - Core concepts and principles
  - Important processes or steps
  - Cause-and-effect relationships
  - Important formulas or rules
  - Important differences between related concepts
  - Key facts that a student is likely to be tested on
- Avoid:
  - Minor or trivial details
  - Repeated information
  - Unnecessary examples
  - Administrative information
  - Facts that are unlikely to help a student understand or review the material
- Do not invent information that is not present in the study material.
- Each flashcard should test one clear idea.
- If the section contains several major concepts, create enough flashcards to cover them.
- Do not create duplicate or nearly identical flashcards.

Return this exact format:

[
  {
    "front": "...",
    "back": "..."
  }
]

STUDY MATERIAL SECTION:

${context}
`;

				const ai = new GoogleGenAI({
					apiKey: env.GEMINI_API_KEY,
				});

				const response = await ai.models.generateContent({
					model: "gemini-3.5-flash-lite",
					contents: prompt,
				});

				let flashcards;

				try {
					flashcards = JSON.parse(response.text);
				} catch (e) {
					console.error("FLASHCARD JSON ERROR:", response.text);

					return Response.json(
						{ error: "Gemini returned invalid JSON." },
						{ status: 500 }
					);
				}

				return Response.json({
					flashcards: flashcards,
				});
			}

			return Response.json(
				{ error: "Endpoint not found." },
				{ status: 404 }
			);
		} catch (error) {
			console.error("GEMINI ERROR:", error);

			return Response.json(
				{
					error: error.message || String(error),
				},
				{ status: 500 }
			);
		}
	},
};



//a_c