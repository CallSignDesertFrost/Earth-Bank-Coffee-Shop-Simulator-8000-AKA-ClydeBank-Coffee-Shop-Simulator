# Café progression

Start with $1,000 and 100 coffee-bean units. Choose a name (up to 24 characters), gender, one of four character outfits/hair styles, and one of four skin tones. Appearance is independent of gender. The selected avatar runs the café behind the counter. Profile choices and completed tutorial persist locally.

The tutorial covers pricing, revenue versus profit, investing while maintaining a repair reserve, and seasonal/equipment planning. Help reopens it; during service this pauses the game until the player resumes.

## Story and investment choices

Five chapters follow the café from a quiet inherited corner shop to a resilient neighborhood business. Goals are earning the first profitable day, adding products, replacing equipment and reaching $1,250 in cash. Level increases every 40 coffees sold.

The investment panel appears after a profitable day and can be reopened from the main panel. Expansions/replacements are limited by both available cash and cumulative positive profits less past investments. Repairs can use cash reserves. The UI recommends a $60 reserve; it does not force a spending decision.

| Stock purchase | Quantity | Cost | Selling price each |
|---|---:|---:|---:|
| Pastries | 12 | $18 | $3.50 |
| Iced coffees | 12 | $15 | $4 |
| Merchandise | 4 | $25 | $10 |

Coffee price is player-controlled. $0.50 serving cost is charged per coffee in addition to bean purchases. Advertising, inventory purchases, serving costs and repairs appear as expenses in a cash-based daily ledger. Costs paid before opening are included in the next day. This is an approachable cash-management simulation; it does not model tax, accrual accounting, rent or investment returns.

Stock does not expire in this version. Sales are probabilistic; warmer weather increases iced-coffee demand and colder weather favors coffee. Unaffected menu lines continue to sell during machine failures.

## Calendar

Each season lasts seven game days and repeats automatically.

| Season | Fahrenheit limits |
|---|---|
| Winter | 20–74°F |
| Spring | 40–85°F |
| Summer | 55–100°F |
| Fall | 35–85°F |

Fahrenheit is authoritative; the HUD also shows Celsius to one decimal place. These are configured game ranges, not real weather forecasts.

## Equipment

From level 2 onward, busy-day failures can affect espresso or (when pastries are stocked) the oven. One failure is considered per day. Failure risk increases with level and decreases with the affected machine's tier.

Espresso repairs cost $18; oven repairs cost $24. A paid repair takes one or two game hours during service (six seconds per hour), or completes immediately before opening. A paid repair unfinished at closing completes overnight. An unpaid fault persists. Repairs cannot be charged twice while a technician is working.

Between days, spend earned profits to replace espresso equipment for $80 or an oven for $65. Replacement clears that machine's fault and raises its reliability tier.

## Persistence and validation

Save version 3 stores profile, seasons, inventory, profit budgets, expenses, advertising, equipment and tutorial progress. Versions 1 and 2 migrate to current defaults. Each customer transaction and repair booking is checkpointed. After an interrupted session the saved active day is closed once, preserving completed transactions and advancing the calendar without repeating sales.

Run `godot --headless --path game --script res://scripts/test_game.gd` for gameplay checks. Rendered review of 3D lighting, character preview, scrolling panels, mobile keyboard/notches and Android performance remains a release step.
