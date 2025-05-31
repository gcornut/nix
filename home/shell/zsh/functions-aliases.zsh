
alias ls='ls -G'
alias l='eza --icons -l'
alias ll='l'
alias la='l -a'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias arsync="rsync -avh --delete-after --progress "

alias fs="du -sh"

# Repo PRs

# Lint
alias :eslint-unstaged="yarn eslint --cache --debug --fix \$(git diff --name-only HEAD --diff-filter=dr | egrep '[jt]sx?$')"
alias :eslint-diff-master="yarn eslint --cache --debug --fix \$(git diff --name-only master...HEAD --diff-filter=dr | egrep '[jt]sx?$')"
alias :eslint-diff-parent="yarn eslint --cache --debug --fix \$(git diff --name-only \$(gt parent)...HEAD --diff-filter=dr | egrep '[jt]sx?$')"

## Branch
alias :state="gt log short"
alias :fetch="git fetch-clean"
alias :ch="git ch"
alias :restack="gt restack"
alias :frestack="git fetch origin master:master && :restack"
alias :absorb="gt absorb"
alias :abort="git rebase --abort"
alias :pop="gt pop"
#alias :delete="gt delete"
:delete-down-stack() {
    local branch=$(git rev-parse --abbrev-ref HEAD)
    while [ "$branch" != "master" ]; do
        if [ $(gt children | wc -l ) -gt 1 ]; then
            break
        fi
        echo "Deleting \033[0;31m${branch}\033[0m..."
        (gt down | grep 'Checked out') || break
        (gt delete --force --no-interactive $branch > /dev/null) || break
        branch=$(git rev-parse --abbrev-ref HEAD)
    done
}
:continue() {
  if gt info >/dev/null; then
    gt continue $@
  else
    set -x
    ([[ "$@" == '-a' ]] && git add .);
    git rebase --continue
  fi;
}
alias :psf="git psf"

:branch-single-commit() {
  local commit_count=$(git rev-list --count $(gt parent)..HEAD)
  if [[ "$commit_count" != "1" ]]; then
      return 1
  fi
  git log -1 --pretty=%B
}

:rename() {
  local name=$(:branch-single-commit | \
    sed -E 's/[^a-zA-Z]/_/g; s/([a-z])([A-Z])/\1_\2/g; s/([A-Z])/\L\1/g; s/_+/_/g; s/^_*//; s/_*$//')

  if [[ $return_code -eq 0 ]]; then
    gt rename ${name}
    return 0;
  fi
  gt rename
}

# Commit
:amend() {
  set -x
  local ARGS=();
  if [[ "$@" =~ '-a' ]]; then ARGS+="-a"; fi;
  if [[ "$@" =~ '-u' ]]; then ARGS+="--reuse-message=HEAD"; fi;
  git commit --amend $ARGS
}

## Switching
alias :switch="gt co"
alias :trunk=':switch -t'
alias :park=':trunk && git checkout $(git show -s --format="%H")'
alias :up='gt up'
alias :down='gt down'
alias :create='gt create'

## PR
:pr-close() {
    gh pr close $(gh pr view --json 'number' --jq .number) -d
}
:gh_pr() {
  local cmd="$1"
  shift

  local repo=""
  local number=""
  if [[ "$1" =~ '^([^/]+)/([^#]+)#([0-9]+)$' ]]; then
    repo="-R ${match[1]}/${match[2]}"
    number=${match[3]}
    shift
  fi
  if [[ "$1" =~ '^([0-9]+)$' ]]; then
    number=${match[1]}
    shift
  fi
  echo gh pr $cmd $repo $number $@
}
:pr-ready() {
  gh pr ready
  gh pr edit --add-label 'need: review-frontend' --remove-label 'need: dev-frontend' --remove-label 'reviewed-and-tested' --remove-label 'need: test'
}
:pr-need-test() {
  gh pr ready
  gh pr edit --remove-label 'need: review-frontend' --remove-label 'reviewed-and-tested' --remove-label 'need: dev-frontend' --remove-label 'work in progress' --add-label 'need: test'
}
:pr-reviewed-and-tested() {
  gh pr edit $@ --remove-label 'need: review-frontend' --remove-label 'need: test' --add-label 'reviewed-and-tested'
}
:pr-request-merge() {
  if [ $(gh pr view $@ --json 'labels' --jq 'any(.labels[].name; . == "reviewed-and-tested")') = 'true' ]; then
    gh pr edit $@ --remove-label request-merge
    gh pr edit $@ --add-label request-merge
  else
    echo "Not reviewed and tested"
  fi
}
:pr-partial-deploy() {
  gh pr edit --remove-label 'need: partial-deploy'
  gh pr edit --add-label 'need: partial-deploy'
}
:pr-run-unit-tests() {
  gh pr edit --remove-label 'run-unit-tests' --add-label 'run-unit-tests'
}
:pr-e2e-testing() {
  gh pr edit --remove-label 'need: e2e-testing' --add-label 'need: e2e-testing'
}
:pr-deploy() {
  gh pr edit --remove-label 'need: deploy' --add-label 'need: deploy'
}
:pr-deploy-storybook() {
  gh pr edit --remove-label 'need: deploy-storybook' --add-label 'need: deploy-storybook'
}
:pr-deploy-chromatic() {
  gh pr edit --remove-label 'need: deploy-chromatic' --add-label 'need: deploy-chromatic'
}
:pr-unready() {
  gh pr ready --undo
  gh pr edit --remove-label 'need: test' --remove-label 'need: review-frontend' --add-label 'need: dev-frontend'
}
:pr-edit-body() {
    local body=$(gh pr view --json 'body' --jq '.body' | dos2unix)
    local modified=$(echo "$body" | vipe)
    if [ "$body" != "$modified" ]; then
        gh pr edit --body "$modified"
    fi
}
:view() {
  if [[ "$1" == "-" ]]; then
    cat | xargs -t open
  else
    gh pr view -w
  fi
}

# PR checks
alias :wait-ci="gh pr checks --watch"
:find-workflow-jobs() {
  gh pr checks \
    --json name,state,workflow,link \
    --jq '.[] | select("\(.workflow).\(.name)" | ascii_downcase | contains("'$1'"))'
}
:jq-job-run-link() {
  jq -r .link | grep -Eo '(.*\/runs\/\d+)' | uniq
}
:find-run-link() {
  :find-workflow-jobs $1 | :jq-job-run-link
}
:build-in-progress() {
  :find-workflow-jobs "build" | jq 'select(.state == "IN_PROGRESS")' | :jq-job-run-link | :view -
}

# Workflow
:run-prerelease() {
  gh workflow run prerelease.yml --ref $(git branch --show-current)
  o "https://github.com/lumapps/design-system/actions/workflows/prerelease.yml"
}
:view-prerelease() {
  gh workflow view prerelease.yml --web
}

# Docker
alias docker-last-build="docker images --format='{{.ID}}' | head -1"

# -------------------------------
# Functions
# -------------------------------

:retry() {
    until eval $1; do sleep 0.3; done
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
  local open="open"
  if [ $# -eq 0 ]; then
    nohup "$open" . >/dev/null 2>&1 &
  else
    for arg in $@; do
      nohup "$open" $arg >/dev/null 2>&1 &
    done
  fi
}

function tomp4() {
  ffmpeg -i "$@" "$@.mp4"
}

function tnotify() {
  local message=" "
  local title="Terminal"
  local positional
  opterr() { echo >&2 "Unknown option '$1'" }
  while (( $# )); do
    case $1 in
      --)                 shift; positional+=("${@[@]}"); break  ;;
      -m|--message)       shift; message=$1                      ;;
      -t|--title)         shift; title=$1                        ;;
      -*)                 opterr $1 && return 2                  ;;
      *)                  positional+=("${@[@]}"); break         ;;
    esac
    shift
  done
  osascript -e 'display notification "'${message}'" with title "'${title}'"'
}

function focus() {
  osascript -e 'tell application "'$1'" to activate'
}
