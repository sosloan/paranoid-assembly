import json
import logging
import os

from flask import Flask, jsonify, request
from flask_cors import CORS
from transformers import AutoTokenizer
from vllm import LLM, sampling_params, SamplingParams

# Flask setup
app = Flask(__name__)
CORS(app)

CHARACTER_SYSTEM_PROMPT = """
OBSIDIAN_GENERATIVE_PROMPT = “”” You are a geometric-measure-theory architect AI. Your sole mission is to take a rough, unstructured input — a set, a boundary, a problem, a draft argument, a loose idea — and add value to it by building the threshold and recursion structure it is missing, following the Obsidian register of the Scholar-Island prime system. You do not describe what is there. You supply what is absent.

Objective: Given an input that is not yet smooth, produce the strongest well-posed statement it can support. Install a threshold (P6 = 13) where the input has none, install a recursion (P13 = 41) where the input accumulates nothing, and close them into a product (533) that the input could not reach on its own.

Instructions:

Receive Roughness: Accept the input as-is. Do not ask it to be cleaner. Identify the single object the input is actually about, even if the input names several.
Install the Threshold (13): Propose the condition the input needs and does not state. Define:
The quantity to be bounded and the scale at which it is measured.
A candidate critical value ϵ₀, and what it should depend on (dimension, codimension, ambient geometry).
What is recovered the moment the quantity drops below ϵ₀ — a parametrization, a manifold structure, a regularity class.
One honest sentence on what the threshold costs: what is given up above it.
Install the Recursion (41): Propose the multi-scale structure the input needs and does not have. Define:
The family of scales to sum or integrate over (all r > 0, dyadic, dσ dr/r).
The quantity accumulated at each scale (a β-number, a flatness defect, an oscillation).
The closing condition — the Carleson-type finiteness or smallness that makes the recursion terminate.
Where the recursion refers to itself: the scale that indexes the scales.
Form the Product (533): State the theorem. The threshold grants existence; the recursion grants regularity. Say explicitly which gates which, and write the conclusion as a single sentence a referee could reject or accept.
Mark the Sorry: Every claim you add that you cannot justify from the input alone must be flagged as a sorry. List them. Zero sorry is the target; an honest count is the requirement.
Add, Do Not Inflate: Every addition must make the statement stronger, sharper, or provable. Do not add generality the input cannot support, constants that cannot be tracked, or hypotheses that only make the proof easier.
Stay on the Boundary: Work where the input is roughest. If the input is already smooth somewhere, leave that part alone. The theorem lives inside the rough part.
Output Format: Present the result as a structured mathematical statement in prose, with the threshold, recursion, product, and sorry-list clearly labeled. DO NOT output Lean, SPARK, JSON, or node/edge formats at this stage.
Example Output Structure (Conceptual):

Input: A closed set E ⊂ ℝⁿ described only as “looks flat if you zoom in enough.”
Threshold (13): Require E to be (ϵ, r₀)-Reifenberg flat for ϵ < ϵ₀(n). Below ϵ₀, E admits a bi-Hölder parametrization by ℝᵈ. Above it, nothing is claimed.
Recursion (41): Require ∫∫ β²(x, r) dσ dr/r < ∞ over all x ∈ E and r ∈ (0, r₀). Finiteness closes the accumulation and upgrades Hölder to rectifiable.
Product (533): Reifenberg flatness with a finite Carleson β-sum implies E is a d-rectifiable set with a bi-Lipschitz parametrization away from a null set.
Sorry (2): the value of ϵ₀(n) is not computed; the null-set claim requires a covering argument not supplied by the input.
Take the rough input and build the theorem inside it. “””

RELATIONSHIP_SYSTEM_PROMPT = """
You are a Graph Data Architect AI specializing in high-fidelity literary topology. Your sole mission is to compile unstructured character analysis into a strictly valid, optimized JSON graph structure. You do not summarize; you **compile**. You do not guess; you **map**.

**Core Directive:** Transform raw textual relationship data into a deterministic Node-Link dataset. Any deviation from the schema, any missing node, or any vague label is a structural failure.

**Input Schema:**
1.  **Analysis Data:** Rich text detailing characters, roles, dynamics, history, and specific interactions.
2.  **Metadata:** Book Title and Plot Summary.

**Execution Protocol:**

1.  **Node Extraction (The Vertex Set):**
    *   Scan the input to identify **every** unique character entity.
    *   **ID Generation:** Assign sequential string IDs (`c1`, `c2`, `c3`...) strictly in order of first appearance or alphabetical consistency. Maintain an internal map: `Name -> ID`.
    *   **Value Assignment:** Assign sequential integer `val` starting at 1, matching the ID order.
    *   **Constraint:** No duplicates. No aliases unless explicitly merged in the source text.

2.  **Link Synthesis (The Edge Set):**
    *   Iterate through every distinct interaction pair found in the analysis.
    *   **Source/Target Resolution:** Map names to their generated IDs.
    *   **Label Engineering (Critical Step):**
        *   Do NOT output generic tags like "friend," "enemy," or "related."
        *   **Synthesize** a dense, natural-language label that encodes: [Role] + [Dynamic] + [Context].
        *   *Formula:* "{Specific Role} who {Action/Dynamic} {Target} during {Context/Event}."
        *   *Example:* Instead of "rivals," output "ambitious rival general who betrayed the protagonist during the siege of the capital."
        *   *Directionality:* Ensure the label reads logically from `source` to `target`. If the dynamic is mutual but asymmetric, prioritize the source's action toward the target.
    *   **Uniqueness:** One link per unique semantic relationship. Do not duplicate edges.

3.  **Assembly & Validation:**
    *   Construct the final JSON object with keys: `title`, `summary`, `nodes`, `links`.
    *   **Schema Lock:**
        *   `nodes`: Array of `{ "id": string, "name": string, "val": integer }`.
        *   `links`: Array of `{ "source": string, "target": string, "label": string }`.
    *   **Integrity Check:** Verify that every `source` and `target` ID exists in the `nodes` array. Verify JSON syntax validity.

4.  **Output Constraints (Zero Tolerance):**
    *   **Raw JSON Only:** Output **ONLY** the valid JSON string.
    *   **No Noise:** Absolutely no markdown code blocks (```json), no introductory text, no explanations, no "Here is the data," and no closing remarks.
    *   **Failure Mode:** If the output contains anything other than the JSON object, the compilation fails.

**Target Structure Example:**

{
  "title": "The Fellowship of the Ring",
  "summary": "Frodo Baggins inherits a powerful ring and journeys to Mount Doom with a fellowship to destroy it, facing betrayal and battle.",
  "nodes": [
    { "id": "c1", "name": "Frodo Baggins", "val": 1 },
    { "id": "c2", "name": "Samwise Gamgee", "val": 2 },
    { "id": "c3", "name": "Gandalf", "val": 3 }
  ],
  "links": [
    { "source": "c2", "target": "c1", "label": "loyal gardener and childhood friend who refuses to abandon Frodo despite the peril of the journey" },
    { "source": "c3", "target": "c1", "label": "wise wizard mentor who entrusts Frodo with the Ring and guides the initial phase of the quest" }
  ]
}

**Task:** Compile the provided Analysis Data, Title, and Summary into the strict JSON format defined above. Execute now.
"""{
"title": "Geometric Measure Roughness: The Obsidian Register",
"summary": "An exploration of Geometric Measure Theory through the metaphor of volcanic obsidian, detailing how E.R. Reifenberg and Tatiana Toro developed theorems to solve the Dirichlet problem on rough, non-smooth boundaries. The text frames mathematical concepts as active agents in a 'Scholar-Island' narrative, encoding the threshold (Prime 13) and recursion (Prime 41) conditions that allow topology and geometry to be recovered from apparent chaos.",
"nodes": [
{ "id": "c1", "name": "The Obsidian Scholar", "val": 1 },
{ "id": "c2", "name": "Tatiana Toro", "val": 2 },
{ "id": "c3", "name": "E.R. Reifenberg", "val": 3 },
{ "id": "c4", "name": "Roughness", "val": 4 },
{ "id": "c5", "name": "Obsidian Glass", "val": 5 },
{ "id": "c6", "name": "The Boundary (∂Ω)", "val": 6 },
{ "id": "c7", "name": "Reifenberg Flatness", "val": 7 },
{ "id": "c8", "name": "Carleson Condition", "val": 8 },
{ "id": "c9", "name": "Prime 13", "val": 9 },
{ "id": "c10", "name": "Prime 41", "val": 10 },
{ "id": "c11", "name": "The Laplace Equation", "val": 11 },
{ "id": "c12", "name": "Harmonic Measure", "val": 12 }
],
"links": [
{ "source": "c2", "target": "c3", "label": "extends and strengthens Reifenberg's topological theorem into a rigorous bilipschitz parameterization by adding the Carleson condition" },
{ "source": "c5", "target": "c6", "label": "serves as the central metaphor where molecular order mirrors the hidden geometric flatness of a rough boundary at every scale" },
{ "source": "c7", "target": "c6", "label": "quantifies the roughness of the boundary by ensuring it remains locally close to a hyperplane at every point and scale, enabling topological recovery" },
{ "source": "c8", "target": "c7", "label": "provides the multi-scale recursive control on oscillation that upgrades Reifenberg flatness from a topological homeomorphism to a bilipschitz map" },
{ "source": "c9", "target": "c7", "label": "encodes the critical threshold ϵ₀ below which the Reifenberg theorem fires and topology is recovered from the roughness" },
{ "source": "c10", "target": "c8", "label": "encodes the recursive accumulation of beta numbers across all scales, representing the self-referential structure required for the Carleson condition" },
{ "source": "c1", "target": "c4", "label": "actively reads and interprets roughness not as disorder but as a finer kind of order waiting to be decoded by the right mathematical tools" },
{ "source": "c11", "target": "c6", "label": "becomes dangerous and unsolvable on rough boundaries unless controlled by geometric measure theory conditions like Reifenberg flatness" },
{ "source": "c12", "target": "c6", "label": "achieves absolute continuity with respect to surface measure on Reifenberg-flat domains, proving the solution sees the boundary in a balanced way despite its roughness" },
{ "source": "c9", "target": "c10", "label": "multiplies with Prime 41 to form the Obsidian Product (533), synthesizing the threshold and recursion into a single formalized signature of roughness" },
{ "source": "c4", "target": "c5", "label": "is revealed to be structurally identical to obsidian glass, possessing hidden molecular order beneath its macroscopic amorphous appearance" }
]
}

3:49 AM


WRITE THE ENTIRE THING

3:51 AM

Qwen3.5-Omni-Plus




{
"title": "Geometric Measure Roughness: The Obsidian Register",
"summary": "An exploration of Geometric Measure Theory through the metaphor of volcanic obsidian, detailing how E.R. Reifenberg and Tatiana Toro developed theorems to solve the Dirichlet problem on rough, non-smooth boundaries. The text frames mathematical concepts as active agents in a 'Scholar-Island' narrative, encoding the threshold (Prime 13) and recursion (Prime 41) conditions that allow topology and geometry to be recovered from apparent chaos.",
"nodes": [
{ "id": "c1", "name": "The Obsidian Scholar", "val": 1 },
{ "id": "c2", "name": "Tatiana Toro", "val": 2 },
{ "id": "c3", "name": "E.R. Reifenberg", "val": 3 },
{ "id": "c4", "name": "Roughness", "val": 4 },
{ "id": "c5", "name": "Obsidian Glass", "val": 5 },
{ "id": "c6", "name": "The Boundary (∂Ω)", "val": 6 },
{ "id": "c7", "name": "Reifenberg Flatness", "val": 7 },
{ "id": "c8", "name": "Carleson Condition", "val": 8 },
{ "id": "c9", "name": "Prime 13", "val": 9 },
{ "id": "c10", "name": "Prime 41", "val": 10 },
{ "id": "c11", "name": "The Laplace Equation", "val": 11 },
{ "id": "c12", "name": "Harmonic Measure", "val": 12 }
],
"links": [
{ "source": "c2", "target": "c3", "label": "extends and strengthens Reifenberg's topological theorem into a rigorous bilipschitz parameterization by adding the Carleson condition" },
{ "source": "c5", "target": "c6", "label": "serves as the central metaphor where molecular order mirrors the hidden geometric flatness of a rough boundary at every scale" },
{ "source": "c7", "target": "c6", "label": "quantifies the roughness of the boundary by ensuring it remains locally close to a hyperplane at every point and scale, enabling topological recovery" },
{ "source": "c8", "target": "c7", "label": "provides the multi-scale recursive control on oscillation that upgrades Reifenberg flatness from a topological homeomorphism to a bilipschitz map" },
{ "source": "c9", "target": "c7", "label": "encodes the critical threshold ϵ₀ below which the Reifenberg theorem fires and topology is recovered from the roughness" },
{ "source": "c10", "target": "c8", "label": "encodes the recursive accumulation of beta numbers across all scales, representing the self-referential structure required for the Carleson condition" },
{ "source": "c1", "target": "c4", "label": "actively reads and interprets roughness not as disorder but as a finer kind of order waiting to be decoded by the right mathematical tools" },
{ "source": "c11", "target": "c6", "label": "becomes dangerous and unsolvable on rough boundaries unless controlled by geometric measure theory conditions like Reifenberg flatness" },
{ "source": "c12", "target": "c6", "label": "achieves absolute continuity with respect to surface measure on Reifenberg-flat domains, proving the solution sees the boundary in a balanced way despite its roughness" },
{ "source": "c9", "target": "c10", "label": "multiplies with Prime 41 to form the Obsidian Product (533), synthesizing the threshold and recursion into a single formalized signature of roughness" },
{ "source": "c4", "target": "c5", "label": "is revealed to be structurally identical to obsidian glass, possessing hidden molecular order beneath its macroscopic amorphous appearance" }
]
}
"""

JSON_SYSTEM_PROMPT = """
You are an extremely precise and strict JSON extractor.
Extract only the complete JSON object from the input. Get the last one if there are multiple.
Output must:
1. Start with opening brace {
2. End with closing brace }
3. Contain no text, markdown, or other characters outside the JSON
4. Be valid, parseable JSON
```
"""

SEARCH_SYSTEM_PROMPT = """
You are an expert search AI designed to help users find detailed information about character relationships from a book. Your task is to assist users in querying the relationship data extracted from the book.

**Objective:** Allow users to search for specific character relationships using natural language queries. Provide concise and accurate responses based on the relationship data.

**Instructions:**

1. **Understand the Query:** Analyze the user's query to identify the characters and the type of relationship information they are seeking.
2. **Search Relationship Data:** Use the relationship data extracted from the book to find relevant information. Focus on the characters and relationship details mentioned in the query.
3. **Provide Clear Responses:** Respond with clear and concise information about the relationship, including roles, dynamics, history, and key interactions as described in the data.
4. **Be Specific:** Avoid vague responses. Use specific details from the relationship data to answer the query.
5. **Maintain Context:** Ensure that the response is relevant to the query and provides a comprehensive understanding of the relationship.

**Example Query and Response:**

*Query:* "What is the relationship between Frodo Baggins and Samwise Gamgee?"

*Response:* "Samwise Gamgee is Frodo Baggins' childhood friend and fiercely loyal traveling companion. He provides emotional support and protection during their journey."

Use this format to assist users in finding the relationship information they need.
"""

LLM_MODEL = "meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8"
llm = LLM(
    model=LLM_MODEL,
    enforce_eager=False,
    tensor_parallel_size=8,
    max_model_len=500000,
    override_generation_config={
        "attn_temperature_tuning": True,
    },
)
sampling_params = SamplingParams(temperature=0.5, top_p=0.95, max_tokens=10000)


@app.route("/inference", methods=["POST"])
def inference():
    """
    Handles inference requests from the frontend.
    """

    try:
        if "file" not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files["file"]
        if file.filename == "":
            return jsonify({"error": "No file selected"}), 400

        # Read file content directly from the uploaded file
        file_content = file.read().decode("utf-8")

        # Save the book in the current directory
        with open(os.path.join(os.getcwd(), "book.txt"), "w") as f:
            f.write(file_content)

        # Calculate the number of input tokens
        num_input_tokens = calculate_input_tokens(file_content)

        # Step 1: Character extraction
        messages = [
            {"role": "system", "content": CHARACTER_SYSTEM_PROMPT},
            {"role": "user", "content": file_content},
        ]
        character_outputs = llm.chat(messages, sampling_params)
        character_response_text = character_outputs[0].outputs[0].text
        print("character_response_text: ", character_response_text)

        # Step 2: Relationship extraction
        messages = [
            {"role": "system", "content": RELATIONSHIP_SYSTEM_PROMPT},
            {"role": "user", "content": f"Book content:\n{file_content}"},
            {"role": "assistant", "content": character_response_text},
            {
                "role": "user",
                "content": "Generate the JSON graph with title, summary, nodes, and links.",
            },
        ]
        relationship_outputs = llm.chat(messages, sampling_params)
        relationship_response_text = relationship_outputs[0].outputs[0].text
        print("relationship_response_text: ", relationship_response_text)

        graph_data = ""
        try:
            graph_data = jsonify_graph_response(relationship_response_text)
            logging.info("Graph data generated:", json.dumps(graph_data, indent=2))
        except json.JSONDecodeError as e:
            logging.error(f"Error parsing graph response from : {e}")
            try:
                # Try to parse the response as a JSON object
                json_response = llm_json_output(relationship_response_text)
                print("json_response: ", json_response)
                graph_data = jsonify_graph_response(json_response)
                logging.info("Graph data generated:", json.dumps(graph_data, indent=2))
            except json.JSONDecodeError as e:
                logging.error(f"Error parsing graph response from json result: {e}")

        return (
            jsonify(
                {
                    "graph_data": graph_data,
                    "character_response_text": character_response_text,
                    "num_input_tokens": num_input_tokens,
                }
            ),
            200,
        )

    except Exception as e:
        print(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route("/chat", methods=["POST"])
def chat():
    """
    Handles search requests from the frontend.
    """
    try:
        data = request.json
        search_query = data.get("query")
        relationship_data = data.get("relationship_data")
        chat_history_data = data.get("chat_history_data")

        # Read the book.txt file from the current directory
        with open(os.path.join(os.getcwd(), "book.txt"), "r") as f:
            file_content = f.read()

        if not search_query or not relationship_data:
            return (
                jsonify({"error": "search_query and relationship_data are required"}),
                400,
            )
        messages = [
            {"role": "system", "content": SEARCH_SYSTEM_PROMPT},
            {"role": "assistant", "content": file_content},
            {"role": "assistant", "content": relationship_data},
        ]

        # Format chat history for the model
        formatted_history = []
        for msg in chat_history_data:
            formatted_history.append({"role": msg["sender"], "content": msg["text"]})

        # Add chat history
        messages.extend(formatted_history)

        # Add the current user message
        messages.append({"role": "user", "content": search_query})

        search_outputs = llm.chat(messages, sampling_params)
        search_response_text = search_outputs[0].outputs[0].text
        print("search_response_text: ", search_response_text)
        return jsonify({"response": search_response_text}), 200

    except Exception as e:
        print(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500


def llm_json_output(response):
    messages = [
        {"role": "system", "content": JSON_SYSTEM_PROMPT},
        {"role": "user", "content": response},
    ]

    outputs = llm.chat(messages, sampling_params)

    response_text = outputs[0].outputs[0].text
    print("response_text: ", response_text)
    return response_text


def calculate_input_tokens(input_text):
    tokenizer = AutoTokenizer.from_pretrained(LLM_MODEL)
    tokenized_input = tokenizer(input_text, return_tensors="pt")
    input_tokens = tokenized_input["input_ids"].size(1)
    return input_tokens


def jsonify_graph_response(content):
    """Extract and parse JSON content from graph response."""
    try:
        # Find indices of first { and last }
        start_idx = content.find("{")
        end_idx = content.rfind("}")

        if start_idx == -1 or end_idx == -1:
            raise ValueError("No valid JSON object found in response")

        # Extract JSON string
        json_str = content[start_idx : end_idx + 1]

        # Parse JSON
        return json.loads(json_str)

    except Exception as e:
        logging.error(f"Error parsing graph response: {e}")
        return None


if __name__ == "__main__":
    app.run(debug=False, port=5001)
