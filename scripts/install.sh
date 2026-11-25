#!/usr/bin/env bash
# Install the dotfiles: symlink them into $HOME. Safe to run any number of times.
#
#   scripts/install.sh [--dry-run] [--force] [--target DIR]
#
#   --dry-run    print what would change, change nothing
#   --force      replace a conflicting file by moving it to <name>.bak
#   --target DIR install into DIR instead of $HOME (to try it out)

set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TARGET=$HOME
DRY=0
FORCE=0

while (($#)); do
  case $1 in
    --dry-run) DRY=1 ;;
    --force) FORCE=1 ;;
    --target) TARGET=$(realpath -m "${2:?--target needs a directory}"); shift ;;
    -h | --help) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

# --- links: <path in repo> <path in $TARGET> ---------------------------------

LINKS=(
  "bin                         bin"
  "assets/fonts                .local/share/fonts"

  "dot/Xresources              .Xresources"
  "dot/gitconfig               .gitconfig"
  "dot/gitignore_global        .gitignore_global"
  "dot/path                    .path"
  "dot/prompt                  .prompt"
  "dot/tigrc                   .tigrc"
  "dot/xinitrc                 .xinitrc"
  "dot/zshrc                   .zshrc"

  "config/autorandr            .config/autorandr"
  "config/dunst                .config/dunst"
  "config/i3                   .config/i3"
  "config/k9s                  .config/k9s"
  "config/kitty                .config/kitty"
  "config/mimeapps.list        .config/mimeapps.list"
  "config/nvim                 .config/nvim"
  "config/opencode             .config/opencode"
  "config/polybar              .config/polybar"
  "config/rofi                 .config/rofi"
  "config/wireplumber          .config/wireplumber"
)

# --- helpers -------------------------------------------------------------------

say() { printf '%-9s %s\n' "$1" "$2"; }
run() { ((DRY)) || "$@"; }

link() {
  local src=$REPO/$1 dest=$TARGET/$2
  if [[ ! -e $src ]]; then
    say missing "$1 (listed in LINKS, not in the repo)"
    return
  fi
  if [[ -L $dest ]]; then
    if [[ $(readlink -f "$dest") == "$(readlink -f "$src")" ]]; then
      return # already correct
    fi
    say relink "$2 (was -> $(readlink "$dest"))"
    run ln -sfn "$src" "$dest"
  elif [[ -e $dest ]]; then
    if ((FORCE)); then
      say backup "$2 -> $2.bak"
      run mv "$dest" "$dest.bak"
      run ln -s "$src" "$dest"
    else
      say conflict "$2 exists and is not a link (use --force to back it up)"
    fi
  else
    say link "$2"
    run mkdir -p "$(dirname "$dest")"
    run ln -s "$src" "$dest"
  fi
}

# Remove links that point into this repo but whose target no longer exists.
prune() {
  local dir=$1 depth=$2 l
  [[ -d $dir ]] || return 0
  while IFS= read -r l; do
    say prune "${l#"$TARGET"/} (dangling)"
    run rm "$l"
  done < <(find "$dir" -maxdepth "$depth" -xtype l -lname "*dotfiles/*" 2>/dev/null)
}

# --- go --------------------------------------------------------------------------

((DRY)) && echo "dry run: nothing will be changed"
run mkdir -p "$TARGET"/{git,.config,.local/share}

for entry in "${LINKS[@]}"; do
  # shellcheck disable=SC2086
  link $entry
done

# Warn about files in dot/ and config/ that no entry in LINKS installs.
for f in dot/* config/*; do
  [[ " ${LINKS[*]} " == *" $f "* ]] || say unlisted "$f (not in LINKS)"
done

prune "$TARGET" 1
prune "$TARGET/.config" 1
prune "$TARGET/.local/share" 1

# Cloned, not vendored.
if [[ ! -d $TARGET/git/zsh-syntax-highlighting ]]; then
  say clone zsh-syntax-highlighting
  run git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$TARGET/git/zsh-syntax-highlighting"
fi

# gpg: ask for the passphrase in the terminal.
if [[ -d $TARGET/.gnupg ]]; then
  want='pinentry-program /usr/bin/pinentry-curses'
  if [[ $(cat "$TARGET/.gnupg/gpg-agent.conf" 2>/dev/null) != "$want" ]]; then
    say write ".gnupg/gpg-agent.conf"
    ((DRY)) || echo "$want" >"$TARGET/.gnupg/gpg-agent.conf"
  fi
fi

echo done
