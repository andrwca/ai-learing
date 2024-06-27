from azure.identity import AzureCliCredential, get_bearer_token_provider
from openai import AzureOpenAI
import os

endpoint = os.environ.get("OPEN_AI_ENDPOINT")
deployment = "ai-training-deployment"

print("Getting bearer token...")

# This will get the token for the logged in az cli user. Log into Azure before running this code
# and ensure you have RBAC permissions for using the deployed Azure OpenAI apis.
# See: https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/managed-identity. 
token_provider = get_bearer_token_provider(
    AzureCliCredential(), "https://cognitiveservices.azure.com/.default"
)

print("Creating client...")

client = AzureOpenAI(
    api_version="2024-02-15-preview",
    azure_endpoint=endpoint,
    azure_ad_token_provider=token_provider
)

print("Calling API...")

response = client.chat.completions.create(
    model=deployment,
    messages=[
        {"role": "system", "content": "You are a ScrumMaster."},
        {"role": "user", "content": "Based on the title, what user stories are specifically about 'configuration'?"}
        #{"role": "user", "content": "What stories did Jane work on?"}
    ],
    extra_body={
        "data_sources": [
            {
                "type": "azure_search",
                "parameters": {
                    "endpoint": os.environ.get("SEARCH_ENDPOINT"),
                    "index_name": "stories",
                    "authentication": {
                        "type": "user_assigned_managed_identity",
                        "managed_identity_resource_id": os.environ.get("OPEN_AI_IDENTITY_ID")                      
                    }
                }
            }
        ]
    }
)

print("Response:")
print(response.choices[0].message.content)