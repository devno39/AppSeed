#!/bin/zsh
# Read-only SQL against the linked Supabase project (analytics / forensics).
#   Scripts/supabase_query.sh "select count(*) from users"
#
# Set PROJECT_REF to your project's ref (Supabase dashboard → Project Settings → General),
# or export SUPABASE_PROJECT_REF in your shell.
set -e

PROJECT_REF="${SUPABASE_PROJECT_REF:-SUPABASE_PROJECT_REF}"
SQL="$1"

if [ "$PROJECT_REF" = "SUPABASE_PROJECT_REF" ]; then
  print -u2 "supabase_query: set SUPABASE_PROJECT_REF (or edit PROJECT_REF in this script)"
  exit 1
fi

# Guard: the CLI token has full management rights — only reads are allowed through here.
case "${${SQL##[[:space:]]#}:l}" in
  select*|with*|explain*|show*|table*) ;;
  *) print -u2 "supabase_query: only SELECT/WITH/EXPLAIN/SHOW/TABLE allowed"; exit 1 ;;
esac

TOKEN=$(security find-generic-password -s "Supabase CLI" -w | sed 's/^go-keyring-base64://' | base64 -d)

curl -s -X POST "https://api.supabase.com/v1/projects/$PROJECT_REF/database/query" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "$(jq -Rs '{query: .}' <<< "$SQL")"
