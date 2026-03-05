# Documentation Feature

The Documentation feature provides a user-facing browser for AACT database schema and CTGov API metadata. Users can search, filter, and explore all database tables and columns with their associated CTGov mappings.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     External Database (aact-core)               │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐ │
│  │ support.         │ │ support.         │ │ support.         │ │
│  │ ctgov_schema     │ │ ctgov_mapping    │ │ ctgov_metadata   │ │
│  └────────┬─────────┘ └────────┬─────────┘ └────────┬─────────┘ │
└───────────│─────────────────────│─────────────────────│─────────┘
            │                     │                     │
            └──────────────┬──────┴─────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │  SyncDocumentationJob  │  (Joins + denormalizes)
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │   documentation_items  │  (Local table)
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ DocumentationController│
              │   index / show / csv   │
              └────────────────────────┘
```

## Data Model

### DocumentationItem

Denormalized table combining schema, mapping, and metadata into a single queryable record.

| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `active` | boolean | Whether the field is currently active |
| `table_name` | string | AACT table name (e.g., `studies`) |
| `column_name` | string | Column name (e.g., `nct_id`) |
| `data_type` | string | PostgreSQL data type |
| `nullable` | boolean | Whether NULL values are allowed |
| `description` | text | Field description |
| `ctgov_name` | string | CTGov API field name |
| `ctgov_label` | string | Human-readable CTGov label |
| `ctgov_path` | string | Full API path (e.g., `protocolSection.identificationModule.nctId`) |
| `ctgov_section` | string | CTGov section (e.g., `Protocol`) |
| `ctgov_module` | string | CTGov module (e.g., `Identification`) |
| `ctgov_url` | string | Link to CTGov documentation |

**Indexes:**
- `table_name` - For table filter queries
- `active` - For active/inactive filtering
- `(table_name, column_name)` - Unique constraint

### Source Models (External DB)

These models connect to the external `aact-core` database via `establish_connection :external`:

- **`Ctgov::V1Schema`** (`support.ctgov_schema`) - Table/column definitions
- **`Ctgov::V1Mapping`** (`support.ctgov_mapping`) - Links AACT fields to CTGov API paths
- **`Ctgov::V1ApiMetadata`** (`support.ctgov_metadata`) - CTGov API field metadata

## Data Synchronization

### Rake Task

```bash
bin/rails documentation:sync
```

Triggers `SyncDocumentationJob` synchronously. Use for manual syncs or in deployment scripts.

### SyncDocumentationJob

Performs a full sync from external database to local `documentation_items` table:

1. Fetches all records from `V1Schema`, `V1Mapping`, and `V1ApiMetadata`
2. Joins data in memory using hash lookups (efficient for ~600 records)
3. Truncates `documentation_items` and bulk inserts new records
4. Runs in a transaction for atomicity

**When to run:**
- After `aact-core` updates schema/mapping data
- During deployment if data may have changed
- Manually when debugging data issues

**Performance:** ~1-2 seconds for full sync (~600 records)

## Controller Actions

### `GET /documentation` (index)

Lists all documentation items with search and filtering.

**Parameters:**
- `search` - Text search across table, column, description, CTGov fields
- `table[]` - Filter by table names (multi-select)
- `active` - Filter by active status (not yet exposed in UI)
- `page` - Pagination

**Features:**
- Turbo Frame for seamless filtering without full page reload
- URL updates via `turbo_action: "advance"` for bookmarkable filters
- Pagy pagination (20 items per page)

### `GET /documentation/:id` (show)

Displays full details for a single documentation item including all CTGov metadata.

### `GET /documentation/download_csv` (download_csv)

Exports filtered results as CSV. Respects current search/filter params.

**Columns exported:** Active, Table, Column, Data Type, Nullable, Description, CTGov Section, CTGov Module, CTGov Data Point

**Safety limit:** 10,000 records max

## UI Components

### Multi-select Table Filter

Custom Stimulus controller (`multiselect_controller.js`) providing:
- Tag-based selection display
- Searchable dropdown
- Auto-submit on selection change
- Click-outside to close
- Zero external dependencies (~80 lines)

### Search with Clear

- Text search with form submission
- Clear button resets search only (preserves table filters)
- Inline JS handler (documented for future consolidation)

### Results Table

Responsive table with:
- Active status badges (green/gray)
- Clickable column names → detail view
- CTGov links open in new tab
- Truncated descriptions with full text in detail view

## File Structure

```
app/
├── controllers/
│   └── documentation_controller.rb
├── jobs/
│   └── sync_documentation_job.rb
├── models/
│   ├── documentation_item.rb
│   └── ctgov/
│       ├── v1_schema.rb
│       ├── v1_mapping.rb
│       └── v1_api_metadata.rb
├── views/
│   └── documentation/
│       ├── index.html.erb
│       └── show.html.erb
└── javascript/
    └── controllers/
        └── multiselect_controller.js

lib/
└── tasks/
    └── documentation.rake

db/
└── migrate/
    └── 20251126135835_create_documentation_items.rb
```

---

## Future Development

### Admin Editing (Planned)

**Route:** `/admin/documentation`

**Features:**
- Edit field descriptions
- Toggle active/inactive status
- Bulk actions (activate/deactivate multiple)
- Audit log for changes
- Admin-only authentication


### Additional Filtering Options

#### Show Inactive Checkbox
- Default: show active only
- Checkbox: "Show inactive columns"
- When checked: include inactive fields in results

#### Data Type Filter
- Dropdown or multi-select for common types (varchar, integer, boolean, text, timestamp)
- Useful for developers querying specific field types

#### CTGov Section/Module Filter
- Filter by CTGov API sections (Protocol, Results, etc.)
- Helps users find fields by CTGov organization

### Search Improvements

#### Full-text Search Index
- Add PostgreSQL `tsvector` column for faster search
- GIN index on combined searchable fields
- Would improve performance at scale

#### Search Highlighting
- Highlight matching terms in results
- Show context around matches in description

### UI Enhancements

#### Expanded Table View (Eliminate Show Page)
- Add all CTGov columns to main table (section, module, path, URL)
- Expandable row for full description instead of separate detail page
- Reduces navigation, keeps users in context
- Consider horizontal scroll or responsive column hiding

#### Sortable Columns
- Click column headers to sort
- Support multi-column sort (Shift+click)
- Preserve sort in URL params

#### User Column Customization
- Let users choose which columns to display
- Drag-and-drop column reordering
- Save preferences per user (database) or localStorage (anonymous)
- Reset to default option

#### Table Grouping
- Group rows by table name with collapsible sections
- Useful when filtering multiple tables

#### Keyboard Navigation
- Arrow keys to navigate results
- Enter to expand row details
- Escape to close modals/dropdowns

### UX Improvements

#### User Guidance & Contextual Help
- Tooltip on CSV button: "Downloads current filtered results"
- Info banner when filters applied: "Showing X of Y records (filtered by: studies, designs)"
- Empty state messaging: "No results found. Try adjusting your search or filters."
- First-time user hints or onboarding tooltips (like start with "studies" table, etc)

#### Feedback & Confirmation
- Toast notification after CSV download: "Downloaded X records"
- Visual indicator when filters are active (badge count, colored border)
- Loading states for search/filter operations
- Success/error messages for all actions

#### Accessibility
- ARIA labels for all interactive elements
- Screen reader announcements for dynamic content updates
- Keyboard-accessible dropdowns and modals
- Focus management after filter changes

#### Help & Documentation
- "?" icon linking to documentation guide
- Inline explanations for CTGov fields (what is section/module/path?)
- Link to full AACT schema documentation
- Glossary of terms

### Export Improvements

#### Additional Export Formats
- JSON export for programmatic use
- Markdown table format for documentation


### Documentation Stimulus Controller

Consolidate inline JS behaviors into a dedicated controller:
- Clear search functionality
- Keyboard shortcuts
- Copy-to-clipboard for code values
- Future interactive features

### Scheduled Sync

#### Background Job Auto-Sync
- Sidekiq recurring job using `sidekiq-scheduler` or `sidekiq-cron`
- Configurable frequency (daily recommended, hourly if data changes frequently)
- Run during off-peak hours to minimize impact
- Slack/email notification on sync completion or failure
- Dashboard showing last sync time and record count

---

## Architecture Ideas & Improvements

_Collection of potential improvements to consider. Not prioritized or planned._

### Sync Strategy Improvements

Current approach: truncate + insert all records on every sync. Ideas to improve:

- **Upsert instead of truncate** - Use `upsert_all` with `(table_name, column_name)` unique key to preserve IDs and only update changed records
- **Diff-based sync** - Compare checksums/timestamps, only sync changed records
- **Soft deletes** - Mark records as deleted instead of removing, preserve history
- **Versioning** - Track sync versions, allow rollback to previous state
- **Incremental updates** - Only fetch records modified since last sync (requires timestamp in source)

### Data Ownership

Currently, source data lives in external `aact-core` database (`support.*` tables). Ideas:

- **Local source of truth** - Migrate tables to aact-v2, remove external DB dependency
- **Dual-write** - Admin edits update both local and external DB during transition
- **Read-only sync + local overrides** - Sync from external, but allow local description overrides that persist
- **CTGov API direct sync** - Fetch metadata directly from CTGov API instead of via aact-core

### Benefits of Local Data
- Faster queries (no cross-database connections)
- Simplified deployment and testing
- Full control over schema and migrations
- Easier local development without external DB access

### API Endpoint for Documentation

- `GET /api/v2/documentation` with modern JSON:API format
- Filterable, paginated, includes relationships
- Versioned separately from v1 for flexibility
