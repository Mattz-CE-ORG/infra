# Available Tools

## Vector Database Tools

### Matt Info Vector DB
Location: `tools/vector_db/`
Purpose: Vector database for storing and retrieving Matt's information using Qdrant (both local and cloud options)

Components:
- `matt_info_db.py`: Core database functionality
- `matt_info_cli.py`: Command-line interface
- `qdrant_cloud_setup.py`: Cloud deployment setup
- `import_data.py`: Data import utilities
- `test_db.py` & `test_cloud.py`: Test suites

CLI Usage:
```bash
# Query uncompleted tasks from life.md
./matt_info_cli.py query "What are my current tasks?" --source life.md --uncompleted

# Add a new task
./matt_info_cli.py add "New task" --source life.md --section "Today/Timely" --type todo

# Store a file with tags and description
./matt_info_cli.py store path/to/file.pdf --tags "document,important" --description "Important document"

# Find files by query
./matt_info_cli.py retrieve "important document" --limit 5

# List all stored files
./matt_info_cli.py list-files --limit 10

# Get collection info
./matt_info_cli.py info matt_info
```

## agent_memory
Memory system for agents to log and learn from past actions. Features vector similarity search, relationship tracking, and pattern analysis.