# Running the sample

Using the devcontainer, run through the following steps:

1. Login to Azure using the Azure CLI (`az login`).
2. Run `./scripts/deploy.sh` to deploy the Azure OpenAI infrastructure to the Azure subscription. 
3. Assign yourself either the `Cognitive Services OpenAI User` or `Cognitive Services OpenAI Contributor` role to your account to make Azure OpenAI inference calls.
4. Upload the `sprint-stories.json` to the deployed Azure storage account under the container `search-content` and folder `stories`. 
5. Run `./scripts/update-templates.sh` to create the `data-source.json` file from the template.
6. Use the json files in the `./data` folder to configure the index, indexer and datasource for the Azure Search service. Once the indexer is created, note that it runs and indexes 10 documents (one per row), due to the `parsingMode` setting.
7. Run `source ./scripts/env.sh` to set the environment variables.
8. Run `python main.py` to run the sample code.

## Sample output

Running the sample, should give output similar to:

```
Getting bearer token...
Creating client...
Calling API...
Response:
Based on the titles provided in the retrieved documents, the user stories that are specifically about 'configuration' are:

1. "Persist config to ephemeral volume" 
2. "Allow custom integration endpoints to be configured." 

These titles suggest that the user stories involve tasks related to setting up or modifying configurations.
```

# Troubleshooting

## Principal does not have access to API/Operation.

Make sure your account has the role in step 3 assigned to it.
