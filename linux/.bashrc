gemini() {
    # Tries to print the token silently (&> /dev/null discards the output)
    # The 'if !' checks if the command FAILED
    if ! gcloud auth application-default print-access-token &> /dev/null; then
        echo "⚠️  Credentials expired or not found."
        echo "Starting Google Cloud authentication..."
        gcloud auth application-default login
    else
        echo "✅ ADC authentication active."
    fi

    # Executes the Gemini CLI passing all arguments
    command gemini "$@"
}
