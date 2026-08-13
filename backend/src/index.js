// ------------------------------------------
// Call Gemini through the fixed-region proxy
// instead of calling Google directly.
// This avoids the "User location is not
// supported" error caused by Cloudflare's
// edge picking a random data center.
// ------------------------------------------
async function generateViaProxy(env, model, contents) {
	const res = await fetch(`${env.PROXY_URL}/generate`, {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			"x-proxy-key": env.PROXY_SECRET,
		},
		body: JSON.stringify({ model, contents }),
	});

	if (!res.ok) {
		const errText = await res.text();
		throw new Error(`Proxy error (${res.status}): ${errText}`);
	}

	return res.json(); // { text: "..." }
}

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

			const result = await env.AI.run("@cf/baai/bge-base-en-v1.5", {
				text: [body.question],
			});

			const matches = await env.VECTORIZE.query(result.data[0], {
				topK: 5,
				returnMetadata: "all",
				filter: { fileName: body.fileName },
			});

			return Response.json(matches);
		}

		if (request.method !== "POST") {
			return new Response("Method Not Allowed", { status: 405 });
		}

		try {
			const body = await request.json();

			// =========================
			// CHAT
			// =========================
			if (url.pathname === "/chat") {
				const question = body.question;
				const fileName = body.fileName;
				const history = body.history || [];

				if (!question || !fileName) {
					return Response.json(
						{ error: "Question and fileName are required." },
						{ status: 400 }
					);
				}

				const totalStart = Date.now();

				function withTimeout(promise, ms, name) {
					return Promise.race([
						promise,
						new Promise((_, reject) =>
							setTimeout(() => {
								reject(new Error(`${name} timed out after ${ms}ms`));
							}, ms)
						),
					]);
				}

				try {
					const embedding = await withTimeout(
						env.AI.run("@cf/baai/bge-base-en-v1.5", { text: [question] }),
						10000,
						"Embedding"
					);

					const matches = await withTimeout(
						env.VECTORIZE.query(embedding.data[0], {
							topK: 5,
							returnMetadata: "all",
							filter: { fileName: fileName },
						}),
						10000,
						"Vectorize"
					);

					const conversationHistory = history
						.slice(-6)
						.map((message) => {
							return `${message.role === "user" ? "User" : "Assistant"}: ${message.text}`;
						})
						.join("\n");

					const context = matches.matches
						.map((match) => match.metadata?.text)
						.filter(Boolean)
						.join("\n\n---\n\n");

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

					const response = await withTimeout(
						generateViaProxy(env, "gemini-3.5-flash-lite", prompt),
						15000,
						"Gemini"
					);

					return Response.json({
						answer: response.text || "I couldn't generate an answer right now.",
					});
				} catch (error) {
					console.error("❌ /chat FAILED:", error);
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
				const questionsForThisChunk = body.questionsForThisChunk;

				if (!chunk) {
					return Response.json({ error: "Chunk is required." }, { status: 400 });
				}

				const prompt = `
You are an AI that generates study quizzes.

Based on the following document, generate exactly ${questionsForThisChunk} multiple-choice questions.

- Generate a fresh and varied set of questions.
- Each question must test a different concept, fact, definition, relationship, or important detail from the document.
- Avoid duplicate or near-duplicate questions.
- Avoid repeatedly focusing on the same part of the document when other important information is available.

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
    "options": ["...", "...", "...", "..."],
    "correctAnswer": "..."
  }
]

Document:

${chunk}
`;

				const response = await generateViaProxy(env, "gemini-3.5-flash-lite", prompt);
				const text = response.text ?? "[]";

				let questions;
				try {
					questions = JSON.parse(text);
				} catch (e) {
					console.error("QUIZ JSON ERROR:", text);
					return Response.json(
						{ error: "Gemini returned invalid JSON.", raw: text },
						{ status: 500 }
					);
				}

				return Response.json({ questions });
			}

			// =========================
			// SUMMARY
			// =========================
			if (url.pathname === "/summary") {
				const context = body.context ?? "";

				if (!context) {
					return Response.json({ error: "Context is required." }, { status: 400 });
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

				const response = await generateViaProxy(env, "gemini-3.5-flash-lite", prompt);

				return Response.json({ summary: response.text });
			}

			// =========================
			// FLASHCARDS
			// =========================
			if (url.pathname === "/flashcards") {
				const context = body.context ?? "";

				if (!context) {
					return Response.json({ error: "Context is required." }, { status: 400 });
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
  { "front": "...", "back": "..." }
]

STUDY MATERIAL SECTION:

${context}
`;

				const response = await generateViaProxy(env, "gemini-3.5-flash-lite", prompt);

				let flashcards;
				try {
					flashcards = JSON.parse(response.text);
				} catch (e) {
					console.error("FLASHCARD JSON ERROR:", response.text);
					return Response.json({ error: "Gemini returned invalid JSON." }, { status: 500 });
				}

				return Response.json({ flashcards });
			}

			return Response.json({ error: "Endpoint not found." }, { status: 404 });
		} catch (error) {
			console.error("GEMINI ERROR:", error);
			return Response.json({ error: error.message || String(error) }, { status: 500 });
		}
	},
};
