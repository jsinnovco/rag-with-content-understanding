"""Create an Azure AI Foundry agent."""

import os
from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.ai.projects import AIProjectClient

# --- Configuration ---
# Prefer env var (set by GitHub ENV secret); fall back to .env file
if not os.environ.get("AZURE_AI_PROJECT_ENDPOINT"):
    for path in [".env", "notebooks/.env"]:
        if os.path.exists(path):
            load_dotenv(path)
            break

AZURE_AI_PROJECT_ENDPOINT = os.environ["AZURE_AI_PROJECT_ENDPOINT"]
MODEL = "gpt-4o"
AGENT_NAME = "financial-10k-10q-analyst"

SYSTEM_INSTRUCTIONS = (
    "You are a financial analyst agent which analyzes quarterly 10-K and 10-Q "
    "documents and provides accurate information relevant to the company name "
    "asked in the query. You aggregate information from all available quarterly "
    "10-K or 10-Q statements for that company. Show some numbers you used to "
    "come up with the output."
)

# --- Main ---
credential = DefaultAzureCredential()
project = AIProjectClient(endpoint=AZURE_AI_PROJECT_ENDPOINT, credential=credential)

existing_agent = None
for agent in project.agents.list_agents():
    if getattr(agent, "name", None) == AGENT_NAME:
        existing_agent = agent
        break

if existing_agent:
    print(f"Using existing agent: {existing_agent.name} (id={existing_agent.id})")
else:
    agent = project.agents.create_agent(
        model=MODEL,
        name=AGENT_NAME,
        instructions=SYSTEM_INSTRUCTIONS,
    )
    print(f"Created agent: {agent.name} (id={agent.id})")
