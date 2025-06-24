# 🐱 Cheshire Cat AI - Environment Generator (PowerShell)
# 🔐 Automatically generates secure API keys and JWT secrets

param(
    [switch]$Force
)

Write-Host "🐱 Cheshire Cat AI - Environment Setup" -ForegroundColor Cyan
Write-Host "🔐 Generating secure keys for your deployment..." -ForegroundColor Cyan
Write-Host ""

# Function to generate secure random string
function Generate-SecureKey {
    param(
        [int]$Length,
        [string]$Type = "base64"
    )
    
    try {
        # Generate random bytes
        $bytes = New-Object byte[] $Length
        $rng = [Security.Cryptography.RNGCryptoServiceProvider]::new()
        $rng.GetBytes($bytes)
        $rng.Dispose()
        
        if ($Type -eq "hex") {
            return [BitConverter]::ToString($bytes).Replace("-", "").ToLower()
        } else {
            # Convert to base64 and clean up
            $base64 = [Convert]::ToBase64String($bytes)
            return $base64.Replace("=", "").Replace("+", "").Replace("/", "").Substring(0, $Length)
        }
    }
    catch {
        Write-Host "Error generating key: $_" -ForegroundColor Red
        exit 1
    }
}

# Check if .env already exists
if (Test-Path ".env") {
    if (-not $Force) {
        Write-Host "⚠️  .env file already exists!" -ForegroundColor Yellow
        $response = Read-Host "Do you want to backup the existing .env and create a new one? (y/N)"
        
        if ($response -notmatch "^[Yy]$") {
            Write-Host "❌ Operation cancelled. Existing .env preserved." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Backup existing file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupName = ".env.backup_$timestamp"
    Copy-Item ".env" $backupName
    Write-Host "✅ Backed up existing .env to $backupName" -ForegroundColor Green
}

Write-Host "🔑 Generating secure keys..." -ForegroundColor Blue

# Generate keys with appropriate lengths
Write-Host "Generating JWT secret (64 characters)..."
$JWT_SECRET = Generate-SecureKey -Length 64

Write-Host "Generating API key (32 characters)..."
$API_KEY = Generate-SecureKey -Length 32

Write-Host "Generating WebSocket API key (32 characters)..."
$API_KEY_WS = Generate-SecureKey -Length 32

Write-Host "Generating Qdrant API key (32 characters)..."
$QDRANT_API_KEY = Generate-SecureKey -Length 32

# Create the .env file content
$envContent = @"
# 🐱 Cheshire Cat AI 
# 🔐 Security Settings
# Generated on: $(Get-Date)
# 
# WARNING: Keep this file secure and never commit it to version control!
# These keys provide access to your AI system.

# JWT Secret for authentication tokens
# Used by: Cheshire Cat Core for user authentication
JWT_SECRET=$JWT_SECRET

# Main API authentication key  
# Used by: REST API endpoints for request authentication
API_KEY=$API_KEY

# WebSocket API authentication key
# Used by: Real-time WebSocket connections (/ws endpoint)
API_KEY_WS=$API_KEY_WS

# Qdrant vector database API key
# Used by: Vector database for securing AI memory and embeddings
QDRANT_API_KEY=$QDRANT_API_KEY
"@

# Write to file
$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host ""
Write-Host "✅ Environment file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 File details:" -ForegroundColor Blue
Write-Host "   • Location: $(Get-Location)\.env"
Write-Host "   • Size: $((Get-Item ".env").Length) bytes"
Write-Host ""
Write-Host "🔐 Generated keys:" -ForegroundColor Blue
Write-Host "   • JWT_SECRET: 64 characters (base64)"
Write-Host "   • API_KEY: 32 characters (base64)"
Write-Host "   • API_KEY_WS: 32 characters (base64)"
Write-Host "   • QDRANT_API_KEY: 32 characters (base64)"
Write-Host ""
Write-Host "⚠️  Security reminders:" -ForegroundColor Yellow
Write-Host "   • Keep your .env file secure and private"
Write-Host "   • Never commit .env to version control"
Write-Host "   • Consider rotating keys periodically"
Write-Host "   • Use different keys for different environments"
Write-Host ""
Write-Host "🚀 Ready to deploy!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "   • Docker: cd docker && docker-compose up -d"
Write-Host "   • K3s: cd k3s && .\apply-secrets.sh && kubectl apply -f k3s-manifest.yaml"
Write-Host "" 