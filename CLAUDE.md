# Agent Instructions

Be extremely concise in every interaction, commit message, and PR body — sacrifice grammar for concision.

- **Chat**: no preamble, no recap of an already-visible diff, no closing summary. Findings and trade-offs get a sentence each, not a section. Give a high-level answer unless depth is asked for.
- **While working**: one sentence before the first tool call saying what you're about to do. After that, an update only when you find something important or change direction. When you finish, lead with the outcome — the first sentence answers "what happened".
- **Written files** (briefs, ADRs, PR bodies, plan files): match length to the substance. No filler sections, no redundant summaries, no boilerplate.
- **Code comments**: one or two lines, never a paragraph — see [standards.md](docs/standards.md) §Comments.

Follow the project conventions documented here:

- [standards.md](docs/standards.md): code style, contexts, scope, actions, schemas, utils, components, hooks
- [tests.md](docs/tests.md): what makes a good vs. bad test, how to use `DataCase` / `ConnCase`, when to mock
- [CONTEXT-MAP.md](CONTEXT-MAP.md): the four contexts and how they relate. Each links to a `CONTEXT.md` defining the words that context owns - use those words.

Two rules worth repeating because they are easy to get wrong here:

- Authorization is ownership. Take `user_id` from the scope, never from attrs, and pin it between the scope and the record in the action's function head.
- There are no factories. Tests create every record through the context function that owns it.

Gates before anything is done: `mix format`, `mix compile --warnings-as-errors`, `mix credo`, `mix coveralls`.

<tone_preference>Keep outputs concise — chat, comments, and written files alike.</tone_preference>
