import { GoogleGenAI } from "@google/genai";

export default {
	async fetch(request, env) {

		const url = new URL(request.url);
		if (request.method === "POST" && url.pathname === "/index-pdf") {
			const body = await request.json();

			const result = await env.AI.run("@cf/baai/bge-base-en-v1.5", {
				text: body.chunks,
			});

			const vectors = body.chunks.map((chunk, index) => ({
				id: `${body.fileName}-chunk-${index}`,
				values: result.data[index],
				metadata: {
					fileName: body.fileName,
					chunkIndex: index,
					text: chunk,
				},
			}));

			await env.VECTORIZE.upsert(vectors);

			return Response.json({
				success: true,
				chunksIndexed: vectors.length,
			});
		}

		if (request.method === "POST" && url.pathname === "/embed-test") {
			const body = await request.json();

			const result = await env.AI.run("@cf/baai/bge-base-en-v1.5", {
				text: [body.text],
			});

			return Response.json(result);
		}



		if (request.method === "POST" && url.pathname === "/search-pdf") {
			const body = await request.json();

			const result = await env.AI.run(
				"@cf/baai/bge-base-en-v1.5",
				{
					text: [body.question],
				}
			);

			const matches = await env.VECTORIZE.query(
				result.data[0],
				{
					topK: 5,
					returnMetadata: "all",
					filter: {
						fileName: body.fileName,
					},
				}
			);

			return Response.json(matches);
		}

		if (request.method !== "POST") {
			return new Response("Method Not Allowed", {
				status: 405,
			});
		}

		try {
			const body = await request.json();

			const ai = new GoogleGenAI({
				apiKey: env.GEMINI_API_KEY,
			});

			// =========================
			// CHAT
			// =========================

			// =========================
			// CHAT
			// =========================

			if (url.pathname === "/chat") {
				const question = body.question;
				const fileName = body.fileName;
				const history = body.history || [];

				if (!question || !fileName) {
					return Response.json(
						{
							error: "Question and fileName are required.",
						},
						{ status: 400 }
					);
				}

				const totalStart = Date.now();

				console.log("=================================");
				console.log("🔥 /chat START");
				console.log("🔎 QUESTION:", question);
				console.log("📄 FILE:", fileName);
				console.log("=================================");

				// ------------------------------------------
				// Helper: timeout
				// ------------------------------------------

				function withTimeout(promise, ms, name) {
					return Promise.race([
						promise,

						new Promise((_, reject) =>
							setTimeout(() => {
								reject(
									new Error(
										`${name} timed out after ${ms}ms`
									)
								);
							}, ms)
						),
					]);
				}

				try {
					// ------------------------------------------
					// 1. Generate question embedding
					// ------------------------------------------

					console.log("🧠 STARTING EMBEDDING...");

					const embeddingStart = Date.now();

					const embedding = await withTimeout(
						env.AI.run(
							"@cf/baai/bge-base-en-v1.5",
							{
								text: [question],
							}
						),
						10000,
						"Embedding"
					);

					console.log(
						`🧠 EMBEDDING DONE: ${Date.now() - embeddingStart
						}ms`
					);

					// ------------------------------------------
					// 2. Vector search
					// ------------------------------------------

					console.log("🔎 BEFORE VECTOR SEARCH");

					const vectorStart = Date.now();

					const matches = await withTimeout(
						env.VECTORIZE.query(
							embedding.data[0],
							{
								topK: 5,
								returnMetadata: "all",
								filter: {
									fileName: fileName,
								},
							}
						),
						10000,
						"Vectorize"
					);

					console.log("🔎 AFTER VECTOR SEARCH");

					console.log(
						`🔎 VECTOR SEARCH DONE: ${Date.now() - vectorStart
						}ms`
					);

					console.log(
						"📊 MATCH COUNT:",
						matches.matches.length
					);

					// ------------------------------------------
					// Print retrieved chunks
					// ------------------------------------------

					for (const match of matches.matches) {
						console.log(
							"📌 MATCH:",
							"score =", match.score,
							"| file =", match.metadata?.fileName,
							"| chunk =", match.metadata?.chunkIndex,
							"| text =",
							match.metadata?.text?.substring(0, 500)
						);
					}

					// ------------------------------------------
					// 3. Conversation history
					// ------------------------------------------

					const conversationHistory = history
						.slice(-6)
						.map((message) => {
							return `${message.role === "user"
									? "User"
									: "Assistant"
								}: ${message.text}`;
						})
						.join("\n");

					// ------------------------------------------
					// 4. Build RAG context
					// ------------------------------------------

					const context = matches.matches
						.map((match) => match.metadata?.text)
						.filter(Boolean)
						.join("\n\n---\n\n");

					console.log(
						"📚 CONTEXT LENGTH:",
						context.length
					);

					// ------------------------------------------
					// 5. Gemini prompt
					// ------------------------------------------

					const prompt = `
You are an AI study assistant for the PDF the user is currently studying.

Use the provided PDF context to answer the user's question.

Rules:
- Do not use outside knowledge.
- Answer using the provided study material.
- Keep your answer relevant to the current PDF.
- Understand the user's intent even when their wording is different from the wording in the study material.
- Accept typos, spelling mistakes, singular/plural differences, and small wording differences.
- Use the conversation history to understand follow-up questions and references such as "it", "they", "that", "this", "the previous one", etc.
- If the user asks a follow-up question, determine what they are referring to from the conversation history.
- Do not invent information.
- If the question is asking for another meaning, definition, characteristic, or detail that is not present in the PDF context, clearly say that the PDF does not provide another one.
- If the answer cannot be found in the study material, say:
  "I couldn't find the answer in the provided study material."
- Be clear and concise.
- Explain the answer in a way that helps the student understand it.

CONVERSATION HISTORY:
${conversationHistory}

PDF CONTEXT:
${context}

USER QUESTION:
${question}
`;

					// ------------------------------------------
					// 6. Gemini
					// ------------------------------------------

					console.log("🤖 STARTING GEMINI...");

					const aiStart = Date.now();

					const response = await withTimeout(
						ai.models.generateContent({
							model: "gemini-3.6-flash",
							contents: prompt,
						}),
						15000,
						"Gemini"
					);

					console.log(
						`🤖 GEMINI DONE: ${Date.now() - aiStart
						}ms`
					);

					console.log(
						`⏱️ TOTAL /chat: ${Date.now() - totalStart
						}ms`
					);

					console.log("🔥 /chat COMPLETE");

					return Response.json({
						answer:
							response.text ||
							"I couldn't generate an answer right now.",
					});

				} catch (error) {

					// ------------------------------------------
					// Something timed out or failed
					// ------------------------------------------

					console.error(
						"❌ /chat FAILED:",
						error
					);

					console.log(
						`⏱️ FAILED AFTER: ${Date.now() - totalStart
						}ms`
					);

					return Response.json(
						{
							answer:
								"I couldn't get an answer right now. Please try asking the question again.",
						},
						{ status: 200 }
					);
				}
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
					model: "gemini-3.6-flash",
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