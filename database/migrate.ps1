# Rizervitoo Database Migration Script
# This PowerShell script helps migrate the database schema to Supabase

Write-Host "=== Rizervitoo Database Migration Helper ===" -ForegroundColor Green
Write-Host ""

# Check if Supabase CLI is installed
Write-Host "Checking Supabase CLI installation..." -ForegroundColor Yellow
try {
    $supabaseVersion = supabase --version
    Write-Host "✓ Supabase CLI found: $supabaseVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Supabase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "  npm install -g supabase" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Migration Options:" -ForegroundColor Cyan
Write-Host "1. Initialize new Supabase project"
Write-Host "2. Link to existing Supabase project"
Write-Host "3. Push schema files to Supabase"
Write-Host "4. Show migration instructions"
Write-Host "5. Exit"
Write-Host ""

$choice = Read-Host "Select an option (1-5)"

switch ($choice) {
    "1" {
        Write-Host "Initializing new Supabase project..." -ForegroundColor Yellow
        supabase init
        Write-Host "✓ Supabase project initialized" -ForegroundColor Green
        Write-Host "Next: Create a project at https://app.supabase.com and run option 2" -ForegroundColor Cyan
    }
    
    "2" {
        $projectId = Read-Host "Enter your Supabase project ID"
        Write-Host "Linking to Supabase project: $projectId" -ForegroundColor Yellow
        supabase link --project-ref $projectId
        Write-Host "✓ Linked to Supabase project" -ForegroundColor Green
    }
    
    "3" {
        Write-Host "Copying schema files to Supabase migrations..." -ForegroundColor Yellow
        
        # Create migrations directory if it doesn't exist
        if (!(Test-Path "supabase/migrations")) {
            Write-Host "Creating supabase/migrations directory..." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path "supabase/migrations" -Force
        }
        
        # Copy schema files with proper naming
        $schemaFiles = @(
            "01_profiles.sql",
            "02_accommodations.sql", 
            "03_bookings.sql",
            "04_reviews.sql",
            "05_messages.sql",
            "06_travel_guides.sql"
        )
        
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        
        foreach ($file in $schemaFiles) {
            $sourcePath = "database/schema/$file"
            $destPath = "supabase/migrations/${timestamp}_$file"
            
            if (Test-Path $sourcePath) {
                Copy-Item $sourcePath $destPath
                Write-Host "✓ Copied $file" -ForegroundColor Green
            } else {
                Write-Host "✗ Schema file not found: $sourcePath" -ForegroundColor Red
            }
        }
        
        Write-Host "Pushing migrations to Supabase..." -ForegroundColor Yellow
        supabase db push
        Write-Host "✓ Database schema migrated successfully!" -ForegroundColor Green
    }
    
    "4" {
        Write-Host ""
        Write-Host "=== Manual Migration Instructions ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Go to https://app.supabase.com" -ForegroundColor White
        Write-Host "2. Create a new project or select existing one" -ForegroundColor White
        Write-Host "3. Go to SQL Editor" -ForegroundColor White
        Write-Host "4. Copy and run each schema file in order:" -ForegroundColor White
        Write-Host "   - database/schema/01_profiles.sql" -ForegroundColor Gray
        Write-Host "   - database/schema/02_accommodations.sql" -ForegroundColor Gray
        Write-Host "   - database/schema/03_bookings.sql" -ForegroundColor Gray
        Write-Host "   - database/schema/04_reviews.sql" -ForegroundColor Gray
        Write-Host "   - database/schema/05_messages.sql" -ForegroundColor Gray
        Write-Host "   - database/schema/06_travel_guides.sql" -ForegroundColor Gray
        Write-Host "5. Update your Flutter app with Supabase credentials" -ForegroundColor White
        Write-Host ""
        Write-Host "For detailed instructions, see database/README.md" -ForegroundColor Cyan
    }
    
    "5" {
        Write-Host "Goodbye!" -ForegroundColor Green
        exit 0
    }
    
    default {
        Write-Host "Invalid option. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "=== Migration Complete ===" -ForegroundColor Green
Write-Host "Don't forget to:" -ForegroundColor Yellow
Write-Host "1. Update your Flutter app with Supabase credentials" -ForegroundColor White
Write-Host "2. Test the authentication flow" -ForegroundColor White
Write-Host "3. Verify database operations" -ForegroundColor White
Write-Host ""
Write-Host "For help, see database/README.md" -ForegroundColor Cyan