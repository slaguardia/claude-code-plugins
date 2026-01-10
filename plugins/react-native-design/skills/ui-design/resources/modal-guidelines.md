# Modal Design Guidelines

## Close Button Standards

All modals show X button by default. Only hide for:
- Legal/compliance modals requiring explicit action
- Loading/processing states
- Blocking modals that must be acknowledged

## Cancel Button Rules

**DO NOT add Cancel buttons to:**
- Options/menu modals (use X)
- Success/info modals (use X)
- Form modals (use X)

**DO add Cancel buttons to:**
- Destructive confirmation modals
- Two-step confirmations requiring explicit choice

## Button Configuration

Always use on modal buttons:
- `size="modal"`
- `fullWidth={true}`

Never use:
- Custom `style` props
- `backgroundColor`, `borderColor`, `textColor` overrides

## Spacing

- Button container: `gap: 16`
- Icon container: `marginBottom: 16` only
- Message text: `fontSize: 16`, `lineHeight: 22`, `marginBottom: 24`

## Modal Sizes

- `sm` - Confirmations, simple actions (75%)
- `md` - Forms with moderate content (17%)
- `lg` - Help content, detailed info (8%)
