#!/usr/bin/env bats

load test_helper

# git checkpoint ##############################################################

@test "'git checkpoint' with no message and clean repo does not create new commit." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    printf "New content.\\n" >> "${NB_DIR}/home/${_filename}"
    [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ New\ content ]]
  }

  run "${_NB}" git checkpoint

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q -v '\[nb\] Commit'
}

@test "'git checkpoint' with no message and dirty repo creates a new commit with the default message." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    printf "New content.\\n" >> "${NB_DIR}/home/${_filename}"
    [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ New\ content ]]
  }

  run "${_NB}" git checkpoint

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Commit'
}

@test "'git checkpoint <message>' with dirty repo creates a new commit with <message>." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    printf "New content.\\n" >> "${NB_DIR}/home/${_filename}"
    [[ "$(cat "${NB_DIR}/home/${_filename}")" =~ New\ content ]]
  }

  run "${_NB}" git checkpoint "Unique message."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  git log
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q 'Unique message.'
}

# git dirty ###################################################################

@test "'git dirty' with dirty repo returns 0 and does not create commit." {
  {
    "${_NB}" init
    touch "${NB_DIR:?}/home/example.md"

    [[ -n "$(git -C "${NB_DIR:?}/home" status --porcelain)" ]]
  }

  run "${_NB}" git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Does not create git commit
  sleep 1
  git log | grep -v -q 'Commit'
}

@test "'<notebook>:git dirty' with dirty repo returns 0 and does not create commit." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    touch "${NB_DIR:?}/one/example.md"

    [[ -n "$(git -C "${NB_DIR:?}/one" status --porcelain)" ]]
  }

  run "${_NB}" one:git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Does not create git commit
  sleep 1
  git log | grep -v -q 'Commit'
}

@test "'git dirty' with clean repo returns 1 and does not create commit." {
  {
    "${_NB}" init

    [[ -z "$(git -C "${NB_DIR:?}/home" status --porcelain)" ]]
  }

  run "${_NB}" git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not create git commit
  sleep 1
  git log | grep -v -q 'Commit'
}

@test "'<notebook>:git dirty' with clean repo returns 1 and does not create commit." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"

    [[ -z "$(git -C "${NB_DIR:?}/one" status --porcelain)" ]]
  }

  run "${_NB}" one:git dirty

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not create git commit
  sleep 1
  git log | grep -v -q 'Commit'
}
