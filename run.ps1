<#
.SYNOPSIS
    GIS805 NexaMart - Windows build script (PowerShell equivalent of Makefile)

.DESCRIPTION
    Provides the same 4 targets as the Makefile: generate, load, check, clean.
    Computes TEAM_SEED from git username (deterministic, unique per student).

.EXAMPLE
    .\run.ps1 generate
    .\run.ps1 load
    .\run.ps1 check
    .\run.ps1 clean
#>
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet("generate", "load", "check", "clean")]
    [string]$Target
)

$ErrorActionPreference = "Stop"
$env:PYTHONIOENCODING = "utf-8"

# -- Compute TEAM_SEED via the cross-platform Python helper --
# Same logic as Makefile on Linux/macOS/Codespace; avoids drift.
function Get-TeamSeed {
    $seed = (& python scripts/datagen/_compute_seed.py).Trim()
    if (-not $seed) {
        Write-Warning "Could not compute team seed. Using default 1."
        return 1
    }
    $userName = & git config user.name 2>$null
    Write-Host "  TEAM_SEED = $seed  (from git user '$userName')"
    return [int64]$seed
}

# -- Targets --

switch ($Target) {

    "generate" {
        $seed = Get-TeamSeed
        Write-Host "`n-- Generating NexaMart data --`n"
        & python scripts/datagen/gen_all.py --team-seed $seed
        if ($LASTEXITCODE -ne 0) { throw "gen_all.py failed (exit $LASTEXITCODE)" }
    }

    "load" {
        Write-Host "`n-- Loading into DuckDB --`n"
        & python src/run_pipeline.py
        if ($LASTEXITCODE -ne 0) { throw "run_pipeline.py failed (exit $LASTEXITCODE)" }
    }

    "check" {
        Write-Host "`n-- Validating warehouse integrity --`n"
        & python src/run_checks.py
        if ($LASTEXITCODE -ne 0) { throw "Some checks failed. See validation\results\check_results.txt" }
    }

    "clean" {
        Write-Host "`n-- Cleaning generated files --`n"
        Remove-Item -Path "db\nexamart.duckdb" -ErrorAction SilentlyContinue
        if (Test-Path "data\synthetic") { Remove-Item -Path "data\synthetic" -Recurse -Force }
        if (Test-Path "data\raw\*.csv")  { Remove-Item -Path "data\raw\*.csv" -Force }
        if (Test-Path "data\staged")     { Remove-Item -Path "data\staged\*" -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path "data\exports")    { Remove-Item -Path "data\exports\*" -Recurse -Force -ErrorAction SilentlyContinue }
        if (Test-Path "validation\results") { Remove-Item -Path "validation\results\*" -Force -ErrorAction SilentlyContinue }
        Write-Host "  OK - Clean complete"
    }
}
