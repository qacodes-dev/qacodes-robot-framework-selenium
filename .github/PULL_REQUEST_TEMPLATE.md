## What & why

<!-- What does this change do, and why is it needed? Link any related issue. -->

## Type of change

- [ ] New test / coverage
- [ ] Resource / Page Object change (keywords, locators)
- [ ] Framework / config change (variables, CI, requirements)
- [ ] Docs
- [ ] Bug fix
- [ ] Other:

## Verification

<!-- How did you verify this? Paste relevant output. -->

- [ ] `robot --dryrun tests/` passes (suites and imports resolve)
- [ ] `robot --variable HEADLESS:true --outputdir results tests/` passes locally
- [ ] New/changed tests are tagged (`smoke` / `regression` / `slow`) for the right CI gate
- [ ] No hard-coded locators, URLs, or credentials in `.robot` suites (kept in resources/variables)
- [ ] Explicit `Wait Until ...` keywords used instead of `Sleep`

## Notes

<!-- Screenshots, trade-offs, follow-ups, anything a reviewer should know. -->
