# Working in this repository

These instructions are for anyone who changes this repository, people and
coding agents alike.

## Build and test

```sh
make check   # bash -n and shellcheck
```

`make check` touches no network and installs nothing. To test a change end
to end, run `./granola-linux install` with `GRANOLA_LINUX_HOME`,
`GRANOLA_LINUX_CACHE` and `GRANOLA_LINUX_BIN_DIR` pointed at a scratch
directory, so a broken build never replaces a working install. Run
`make check` before every commit.

## Writing the script

- `granola-linux` is one bash script with no dependencies beyond what the
  README lists. Keep it that way; do not add a second language or a package
  manager.
- Every patch to Granola's bundle has a comment that says what breaks
  without it. A reader must be able to redo the conversion by hand from the
  comments alone.
- Nothing runs as root. Where root is unavoidable, print the command and
  let the person run it.
- Everything downloaded is verified against a published checksum, or a
  checksum pinned in the script.

## Commits

- One step per commit. Each commit passes `make check` on its own.
- Sign every commit.
- Use a conventional subject with a scope: `fix(install): verify the image`.
  Types: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`,
  `revert`, `style`, `test`.
- Do not put `#<number>` in a subject or body.
- Do not add `Co-authored-by` lines.
- Do not leave `fixup!`, `squash!` or `amend!` commits, or "address review"
  and "fix typo" commits, on a branch you send for review. Fold them into the
  commit they fix with `git commit --fixup` and `git rebase --autosquash main`.

## Branches and pull requests

- Work on a branch and open a pull request. Nobody pushes `main`.
- Bring a branch up to date by rebasing it on `main`. Do not merge `main` or
  another branch into it.
- Pull requests land as merge commits whose subject is the PR title, so the
  title follows the same rules as a commit subject.

## Scope

Contributors use any distribution, shell and editor. Do not add files,
scripts or docs for one person's setup.
