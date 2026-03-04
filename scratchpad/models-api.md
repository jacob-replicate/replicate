# Data Models

Model: Conversation
- Rails ID is a UUID
- session_id: text (index)
- invariant: text (index)
- template_id: uuid (nullable, index) - self reference to Conversation table to fork
- template: boolean (default: false, index)
- has_many :messages
- Idk the correct index here, I'm gonna be querying against all of these often

Model: Message
- Rails ID is a UUID
- conversation_id: uuid (index)
- sequence: integer
- author_name: string
- author_avatar: string
- is_system: boolean (default: false)
- created_at: datetime
- has_many :components

Model: MessageComponent
- Rails ID is a UUID
- message_id: uuid (index)
- position: integer (ordering within message)
- data: jsonb

## Component Types

### text
```json
{
  "type": "text",
  "content": "the message text content"
}
```

### code
```json
{
  "type": "code",
  "language": "bash",
  "content": "$ aws rds describe-db-instances..."
}
```

Supported languages: bash, sql, hcl, javascript, ruby, etc.

### diff
```json
{
  "type": "diff",
  "filename": "internal/orders/repository.go",
  "lines": [
    { "type": "context", "text": "func (r *Repository) GetOrderForProcessing(...) {" },
    { "type": "remove", "text": "    return r.db.GetOrder(ctx, id)" },
    { "type": "add", "text": "    // Lock row to prevent double-processing" },
    { "type": "add", "text": "    return r.db.QueryRow(ctx, `SELECT * FROM orders WHERE id = $1 FOR UPDATE`, id)" },
    { "type": "context", "text": "}" }
  ]
}
```

Line types: `context` (unchanged), `add` (green), `remove` (red)

### multiple_choice
```json
{
  "type": "multiple_choice",
  "options": [
    "we should add a CI job that runs terraform plan on a schedule",
    "all infra changes should go through terraform PRs",
    "we need better alerting on replication lag"
  ]
}
```