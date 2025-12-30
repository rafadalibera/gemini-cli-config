# Function to wrap the Gemini CLI and handle gcloud authentication
function gemini {
    # Try to print the token silently. The 'if' checks if the command SUCCEEDED.
    gcloud auth application-default print-access-token >$null 2>$null
    if ($LASTEXITCODE -eq 0) {   
        Write-Host "ADC authentication active." -ForegroundColor Green
    } else {
        Write-Host "Credentials expired or not found." -ForegroundColor Yellow
        Write-Host "Starting Google Cloud authentication..."
        gcloud auth application-default login
    }

    # Execute the real Gemini CLI, passing all arguments
    # Find the actual gemini executable, excluding the function itself.
    $geminiExecutable = (Get-Command gemini -ErrorAction SilentlyContinue | Where-Object { $_.CommandType -ne 'Function' } | Select-Object -First 1).Source

    if ($geminiExecutable) {
         # Execute the real Gemini CLI, passing all arguments
        & $geminiExecutable $args
    } else {
        # Fallback for safety, though it shouldn't be reached if CLI is installed.
        Write-Host "Could not find the Gemini CLI executable." -ForegroundColor Red
    }
}
