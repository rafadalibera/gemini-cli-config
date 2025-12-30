# Function to wrap the Gemini CLI and handle gcloud authentication
function gemini {
    # Try to print the token silently. The 'if' checks if the command SUCCEEDED.
    if ((gcloud auth application-default print-access-token >$null 2>$null) -and ($LASTEXITCODE -eq 0) ) {   
        Write-Host "✅ ADC authentication active." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Credentials expired or not found." -ForegroundColor Yellow
        Write-Host "Starting Google Cloud authentication..."
        gcloud auth application-default login
    }

    # Execute the real Gemini CLI, passing all arguments
    & "gemini" $args
}
